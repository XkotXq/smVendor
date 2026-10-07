import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/session_providers.dart';
import '../../i18n/gen/strings.g.dart';
import 'order_detail_page.dart';
import 'order_priority.dart';
// orderTypeLabel lives here, next to orderStatusLabel - the card dropped
// the status badge but still names its type.
import 'order_status.dart';
import 'order_types.dart';
import 'orders_api.dart';
import 'orders_providers.dart';

/// How often the working queue polls for changes while this page is on
/// screen - plain REST polling (GET /orders?scope=active again), not a
/// GraphQL subscription: wpsapi has no per-user auth yet for Hasura to key
/// a subscription off of, and Hasura's own subscriptions are themselves
/// short-interval polling under the hood (no LISTEN/NOTIFY), so a REST poll
/// on a similar cadence gets the same felt "live" behaviour without adding
/// a GraphQL-WS client to this app. Cheap enough at this scale (one small
/// query, a handful of concurrent users) - revisit only if that changes.
const _pollInterval = Duration(seconds: 5);

/// Same breakpoint as widgets/app_shell.dart's own `_kWideBreakpoint` (that
/// one's private to its file, so this is a plain copy, not a shared
/// constant) - phone width gets one column of full-width cards, tablet/
/// desktop gets a 3-across grid, same "wide enough for a side nav" cutoff
/// the rest of the shell already uses.
const _kWideBreakpoint = 600.0;

/// Which half of the working queue a page shows. Both fetch the same
/// scope: active list (one request, one poll loop per page) and differ only
/// in what they keep - the split is about what the operator is deciding,
/// not about what the server returns.
enum OrdersQueue {
  /// Free to take: status new, minus the ones being edited.
  available,

  /// Already in somebody's hands: in progress, whatever came back as a
  /// problem, and - under those - what has been dropped off and is waiting
  /// on the requester.
  mine,
}

/// The working queue (scope: active, i.e. new + in_progress + delivered -
/// same split as wps's own "Lista zamówień", see wpsapi's AGENTS.md
/// "Transport orders"), filtered to one [OrdersQueue]. Every card is a
/// summary - tap it to open OrderDetailPage, which owns the detail and
/// repeats every action the card offers.
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key, this.queue = OrdersQueue.available, this.onTaskTaken});

  final OrdersQueue queue;

  /// Called after a task taken from this queue has been opened and closed
  /// again. The shell uses it to land the operator on "Realizowane": the
  /// order they just took is no longer in "Zadania", so coming back to an
  /// empty-handed list - and the row they were just looking at gone from it
  /// - reads as if the take had failed.
  final VoidCallback? onTaskTaken;

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  Timer? _pollTimer;
  // Guards against two fetches overlapping if one ever takes longer than
  // _pollInterval - a plain periodic Timer doesn't wait for its callback.
  bool _polling = false;

  /// Orders with a take() in flight, so the button cannot be double-tapped
  /// into sending twice.
  final Set<String> _taking = {};

  /// deliver() in flight, per order - the button goes dead so a double tap
  /// cannot send it twice.
  final Set<String> _delivering = {};

  /// Seconds left before "Dostarczone" unlocks, per order id (goods_transport
  /// only - see wpsApi's deliverableInSeconds). Re-synced from the server on
  /// every poll and ticked down locally in between, so the number on a card
  /// moves by the second instead of jumping with the poll interval.
  final Map<String, int> _deliverableIn = {};
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    // No initial load: the provider fetches on first use and **keeps** the
    // list afterwards (see ordersProvider), so coming back to this tab
    // shows what is already known straight away and only refreshes behind
    // it. This page just owns the ticking.
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  /// The background tick behind "live" (see _pollInterval's own comment) -
  /// failures are silent and the screen keeps showing the last good list,
  /// and the loading state is never re-entered, so a poll never interrupts
  /// whatever the operator is doing (see OrdersNotifier.refresh).
  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      await ref.read(activeOrdersProvider.notifier).refresh();
    } finally {
      _polling = false;
    }
  }

  /// "Rozpocznij realizację" straight from the list card (new ->
  /// in_progress), which then **opens the order**: taking it is the start of
  /// the work, and the order's own page is where the rest of it happens
  /// (what to bring, the guideline, "Dostarczone"). Leaving the operator on
  /// the queue after a tap that commits them to a job meant a second tap to
  /// get anywhere.
  ///
  /// The page is seeded with the order the server just returned, so it opens
  /// already showing "W realizacji" rather than the stale "Nowe" for the
  /// moment before its first fetch lands.
  void _syncDeliverable(List<TransportOrder> orders) {
    _deliverableIn
      ..clear()
      ..addEntries(
        orders.where((o) => o.deliverableInSeconds != null).map((o) => MapEntry(o.id, o.deliverableInSeconds!)),
      );
  }

  void _tick() {
    if (_deliverableIn.values.every((v) => v <= 0)) return;
    setState(() {
      for (final id in _deliverableIn.keys.toList()) {
        final left = _deliverableIn[id]!;
        if (left > 0) _deliverableIn[id] = left - 1;
      }
    });
  }

  /// "Dostarczone" straight from the list (in_progress -> delivered). The
  /// order then leaves the queue - it is with the requester now - so there
  /// is nothing to navigate to and the list simply refreshes in place.
  ///
  /// wpsApi re-checks fulfilment server-side, so a card whose checklist has
  /// gone stale cannot mark delivery early even if this button is live.
  Future<void> _deliver(TransportOrder order) async {
    if (_delivering.contains(order.id)) return;
    setState(() => _delivering.add(order.id));
    try {
      await ref.read(ordersApiProvider).deliver(order.id, ref.read(sessionProvider)?.userId ?? '');
      if (mounted) await _poll();
    } on OrderActionFailure catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(ShadToast.destructive(description: Text(e.message)));
        await _poll();
      }
    } catch (_) {
      // Left to the next tick, same as _take: the order either moved or it
      // did not, and the list is the honest answer either way.
    } finally {
      if (mounted) setState(() => _delivering.remove(order.id));
    }
  }

  Future<void> _take(TransportOrder order) async {
    if (_taking.contains(order.id)) return;
    setState(() => _taking.add(order.id));
    TransportOrder? taken;
    try {
      taken = await ref.read(ordersApiProvider).take(order.id, ref.read(sessionProvider)?.userId ?? '');
    } on OrderActionFailure catch (e) {
      // Somebody else got there first (see wpsApi's takeOrder, which lets
      // exactly one of two simultaneous presses win). Say who has it - this
      // used to be swallowed, which left the loser tapping a button that
      // did nothing.
      if (mounted) {
        ShadToaster.of(context).show(ShadToast.destructive(description: Text(e.message)));
        await _poll();
      }
    } catch (_) {
      // A dropped connection: the order either moved or it did not, and the
      // list on the next tick is the honest answer either way. Nothing is
      // opened on a failure - the operator did not get the job.
    } finally {
      if (mounted) setState(() => _taking.remove(order.id));
    }
    if (!mounted || taken == null) return;
    await _open(taken);
    // Only after the order's own page is closed, and only for a take: the
    // tab switches under a list the operator has finished looking at, never
    // while they are still in the order.
    if (mounted) widget.onTaskTaken?.call();
  }

  Future<void> _open(TransportOrder order) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, _, _) => OrderDetailPage(orderId: order.id, initial: order),
      ),
    );
    // The detail page's own actions (take/deliver) may have changed this
    // order's status - refresh right away rather than waiting for the next
    // tick. In place, so the list the operator is looking at never blanks.
    if (mounted) _poll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.orders;

    final ordersAsync = ref.watch(activeOrdersProvider);
    // `.value` is whatever was last known, even while a refresh is in
    // flight or after one failed - so loading and error only ever show
    // when there is genuinely nothing to show yet. That is the whole point
    // of holding the list in a provider; see OrdersNotifier.
    final orders = ordersAsync.value;
    if (orders != null) _syncDeliverable(orders);

    Widget body;
    if (orders == null && ordersAsync.hasError) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.loadError,
                style: theme.textTheme.muted.copyWith(color: theme.colorScheme.destructive),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ShadButton.outline(onPressed: () => ref.invalidate(activeOrdersProvider), child: Text(t.retry)),
            ],
          ),
        ),
      );
    } else if (orders == null) {
      body = Center(child: Text(t.loading, style: theme.textTheme.muted));
    } else {
      final wide = MediaQuery.sizeOf(context).width >= _kWideBreakpoint;
      // Within a queue, grouped by what is to be done about each group. The
      // order inside a group stays the server's own (created_at DESC), and
      // an empty group is left out entirely rather than shown as a heading
      // with nothing under it.
      final sections = (switch (widget.queue) {
        // Not the ones being edited: the requester is rewriting them, and
        // wpsApi refuses a take on those anyway, so showing them would only
        // offer a button that fails.
        OrdersQueue.available => [
          (title: t.sectionNew, orders: orders.where((o) => o.status == 'new' && !o.editing).toList()),
        ],
        // Blocked first: it is the only group where somebody is waiting on
        // someone else, so it is the one worth seeing before anything else.
        // Delivered last, under the running work, because it is the group
        // with nothing left to do on it.
        OrdersQueue.mine => [
          (title: t.sectionProblem, orders: orders.where((o) => o.status == 'problem').toList()),
          (title: t.sectionInProgress, orders: orders.where((o) => o.status == 'inProgress').toList()),
          (title: t.sectionDelivered, orders: orders.where((o) => o.status == 'delivered').toList()),
        ],
      }).where((s) => s.orders.isNotEmpty).toList();

      // A heading per group only when there is more than one of them -
      // with a single group the nav button above already names it.
      final showHeaders = sections.length > 1;

      if (sections.isEmpty) {
        body = Center(
          child: Text(switch (widget.queue) {
            OrdersQueue.available => t.emptyAvailable,
            OrdersQueue.mine => t.emptyMine,
          }, style: theme.textTheme.muted),
        );
        return body;
      }

      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in sections) ...[
            if (showHeaders) _SectionHeader(title: section.title, count: section.orders.length),
            // Phone: a plain stacked column - each card sized to its own
            // natural content. Tablet: rows of three, each row as tall as
            // its own tallest card (see _CardRows) - never a fixed
            // aspect ratio, which forced every card into the same square
            // box whatever was in it.
            if (wide)
              _CardRows(
                orders: section.orders,
                onOpen: _open,
                onTake: _take,
                onDeliver: _deliver,
                taking: _taking,
                delivering: _delivering,
                deliverableIn: _deliverableIn,
              )
            else
              for (var i = 0; i < section.orders.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _OrderCard(
                  order: section.orders[i],
                  onTap: () => _open(section.orders[i]),
                  onTake: () => _take(section.orders[i]),
                  onDeliver: () => _deliver(section.orders[i]),
                  taking: _taking.contains(section.orders[i].id),
                  delivering: _delivering.contains(section.orders[i].id),
                  deliverableIn: _deliverableIn[section.orders[i].id],
                ),
              ],
            const SizedBox(height: 24),
          ],
        ],
      );
    }

    // No pull-to-refresh (RefreshIndicator is Material-only - this app stays
    // on widgets.dart + shadcn_ui, see login_screen.dart's own comment on
    // why) - re-selecting this tab already remounts the page (AppShell swaps
    // pages in directly, no IndexedStack keeping this alive underneath), so
    // that alone re-fetches.
    return body;
  }
}

/// Tablet layout: three cards per row, where **the row is as tall as its
/// own content needs and every card in it fills that height**.
///
/// Flutter has no grid that does this - `GridView`'s delegates all impose a
/// ratio or a fixed extent, which is what made these cards look like
/// squares with empty space in them (or, worse, clipped what did not fit).
/// So the rows are laid out by hand: `IntrinsicHeight` measures the tallest
/// card in the row, `CrossAxisAlignment.stretch` pulls the shorter ones up
/// to match. Two extra layout passes per row, which is nothing for three
/// cards, and the alternative (a `Wrap`) would leave ragged heights with
/// gaps between cards.
///
/// A last row with one or two cards keeps the same column widths - the
/// leftover slots are empty `Expanded`s rather than letting one card
/// stretch across the screen.
class _CardRows extends StatelessWidget {
  const _CardRows({
    required this.orders,
    required this.onOpen,
    required this.onTake,
    required this.onDeliver,
    required this.taking,
    required this.delivering,
    required this.deliverableIn,
  });

  final List<TransportOrder> orders;
  final void Function(TransportOrder) onOpen;
  final void Function(TransportOrder) onTake;
  final void Function(TransportOrder) onDeliver;

  /// Ids with a take() in flight - see _OrderCard.taking.
  final Set<String> taking;
  final Set<String> delivering;

  /// Seconds left per order id before "Dostarczone" unlocks - see
  /// _OrdersPageState._deliverableIn.
  final Map<String, int> deliverableIn;

  static const _perRow = 3;
  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final rows = <List<TransportOrder>>[];
    for (var i = 0; i < orders.length; i += _perRow) {
      rows.add(orders.sublist(i, (i + _perRow).clamp(0, orders.length)));
    }

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: _gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < _perRow; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Expanded(
                    child: c < rows[r].length
                        ? _OrderCard(
                            order: rows[r][c],
                            onTap: () => onOpen(rows[r][c]),
                            onTake: () => onTake(rows[r][c]),
                            onDeliver: () => onDeliver(rows[r][c]),
                            taking: taking.contains(rows[r][c].id),
                            delivering: delivering.contains(rows[r][c].id),
                            deliverableIn: deliverableIn[rows[r][c].id],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A group heading with how many orders are under it - the count is the
/// useful part ("two waiting" vs "eleven waiting" changes what you do), and
/// it saves counting cards.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title, style: theme.textTheme.p.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text('$count', style: theme.textTheme.muted),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onTake,
    required this.onDeliver,
    required this.taking,
    required this.delivering,
    required this.deliverableIn,
  });
  final TransportOrder order;
  final VoidCallback onTap;
  final VoidCallback onTake;
  final VoidCallback onDeliver;

  /// A take() is in flight for this order - the button goes dead so a
  /// double tap cannot send it twice.
  final bool taking;
  final bool delivering;

  /// Seconds this transport still has to run before it can be handed over
  /// (goods_transport only, null = no wait) - see wpsApi's
  /// deliverableInSeconds.
  final int? deliverableIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final rootT = context.t;
    final t = rootT.orders;
    // Whose order this is. The queue shows every operator's in-progress
    // work, so a card that is not mine must say who has it rather than
    // claiming I am on it.
    final mine = order.takenBy != null && order.takenBy == ref.watch(sessionProvider)?.userId;
    final left = deliverableIn ?? 0;
    final waiting = left > 0;
    final muted = theme.textTheme.small.copyWith(fontSize: 12, color: theme.colorScheme.mutedForeground);

    // Does this card offer something to press, or only something to read?
    // The two actions get a row of their own below the facts, full width
    // and 48dp tall - taking a task is why this screen exists and the
    // operator doing it is wearing a glove. A card with nothing to press
    // keeps its state inline and stays short, so a queue of delivered work
    // does not scroll like a queue of work to take.
    final canTake = order.status == 'new';
    final canDeliverNow = order.status == 'inProgress' && mine;

    // Facts first: where it goes, what kind of job it is, and the few
    // things that decide whether to take it. Everything else - the note,
    // who ordered it, the item checklist - is one tap away on the order's
    // own page. The status badge is gone for the same reason: a queue split
    // into "Zadania" and "Realizowane" already says it, and inside the
    // second queue the group heading does.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            // An open problem outlines the whole card: it is the one state
            // worth spotting before reading anything on it.
            color: order.hasOpenProblem ? theme.colorScheme.destructive : theme.colorScheme.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The type in its own colour, the same one wps and smOrder give
                // it - recognisable before the words are read, which is what a
                // queue of cards is scanned for.
                Icon(
                  orderTypeConfig(order.type).icon,
                  size: 22,
                  color: orderTypeConfig(order.type).iconColor(theme.brightness),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The job itself: from -> to.
                      Text(
                        order.route(),
                        style: theme.textTheme.p.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          // What kind of job this is, in words. The coloured
                          // icon on the left says it too, but only to somebody
                          // who already knows the colours - and the two are
                          // not interchangeable when deciding whether to take
                          // a task: a water refill and a machine transport need
                          // different equipment. Given more room than the order
                          // number beside it, which is the part worth losing
                          // first on a narrow screen.
                          Flexible(
                            flex: 3,
                            child: Text(
                              orderTypeLabel(rootT, order.type),
                              // Bigger than the rest of this line and in the
                              // foreground colour: what kind of job it is
                              // decides whether to take it, and at 12pt muted
                              // it read as a footnote beside the order number.
                              style: theme.textTheme.small.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(' · ', style: muted),
                          Flexible(
                            flex: 2,
                            child: Text(order.orderNo, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          // How much there is to bring - only for the orders
                          // that are a list of materials rather than one haul.
                          if (order.items.length > 1) ...[
                            Text(' · ', style: muted),
                            Text(t.card.itemsShort(n: order.items.length), style: muted),
                          ],
                          if (order.hasOpenProblem) ...[
                            const SizedBox(width: 6),
                            Icon(LucideIcons.triangleAlert, size: 13, color: theme.colorScheme.destructive),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                order.awaitingMyAnswer ? t.card.problemFromRequester : t.card.problemWithRequester,
                                style: muted.copyWith(
                                  color: theme.colorScheme.destructive,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (order.messageCount > 0) ...[
                            const SizedBox(width: 6),
                            Icon(
                              LucideIcons.messageCircle,
                              size: 13,
                              color: order.unreadCount > 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.mutedForeground,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              order.unreadCount > 0 ? '${order.unreadCount}' : '${order.messageCount}',
                              style: muted.copyWith(
                                color: order.unreadCount > 0 ? theme.colorScheme.primary : null,
                                fontWeight: order.unreadCount > 0 ? FontWeight.w700 : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Whose it is, when it is not this operator's to act on.
                // Stays on this line: it names a person, which is read, not
                // pressed, and a card you cannot act on should not grow a
                // row for the privilege.
                if (!canTake && !canDeliverNow && order.status != 'delivered' && order.takenBy != null) ...[
                  const SizedBox(width: 8),
                  // Somebody else's: name them instead of offering a button
                  // that is not this operator's to press.
                  Flexible(
                    child: Text(
                      t.card.takenBy(who: order.takenBy ?? '-'),
                      style: muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                // Top-right corner: how urgent the person who placed it said
                // it is (smOrder is where that is chosen), and when they
                // placed it. Three rising bars in green, amber or red - one
                // shape at every level, so it is recognised before it is
                // read - with the time under it, which is what turns "this
                // one is red" into "this one is red and has been waiting an
                // hour". Stacked rather than put on the line below, so the
                // card does not grow for them.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OrderPriorityBars(priority: order.priority),
                    const SizedBox(height: 2),
                    Text(_placedAtLabel(order.createdAt), style: muted),
                  ],
                ),
              ],
            ),
            if (canTake) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: ShadButton(
                  onPressed: taking ? null : onTake,
                  leading: const Icon(LucideIcons.play, size: 16),
                  child: Text(t.card.take),
                ),
              ),
            ] else if (canDeliverNow) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: ShadButton(
                  // Dead until every item is issued, and until a
                  // goods_transport has had time to happen - the same two
                  // gates the order's own page applies, and wpsApi
                  // re-checks the first one anyway.
                  onPressed: (delivering || !order.canDeliver || waiting) ? null : onDeliver,
                  leading: const Icon(LucideIcons.truck, size: 16),
                  // When it is dead the label says why: the transport's own
                  // minimum time, or how much of the order is still to be
                  // issued.
                  child: Text(
                    waiting
                        ? '${t.card.deliver}  $left s'
                        : order.canDeliver
                        ? t.card.deliver
                        : '${t.card.deliver}  '
                              '${order.items.where((i) => i.isFulfilled).length}/${order.items.length}',
                  ),
                ),
              ),
            ] else if (order.status == 'delivered') ...[
              const SizedBox(height: 10),
              // Handed over: nothing to press until the requester answers,
              // or the auto-accept fires. Dead on purpose and kept in the
              // same place and size as the button it replaces, so the card
              // reads as "this one is waiting" rather than as a card whose
              // button went missing.
              SizedBox(
                height: 48,
                child: ShadButton.outline(
                  onPressed: null,
                  leading: const Icon(LucideIcons.clock, size: 16),
                  child: Text(t.card.awaitingConfirm),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// When the order was placed, as a card shows it: the time alone, which is
/// all that matters for work raised on this shift, and the day in front of
/// it for anything older - a bare "07:15" on a card from yesterday would
/// read as fifteen minutes ago.
///
/// Hand-rolled like every other time in these apps (see history_page.dart,
/// order_chat_page.dart): there is no `intl` here and one date format is
/// not worth adding one.
String _placedAtLabel(DateTime createdAt) {
  final local = createdAt.toLocal();
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  final time = '${two(local.hour)}:${two(local.minute)}';
  final sameDay = local.year == now.year && local.month == now.month && local.day == now.day;
  return sameDay ? time : '${two(local.day)}.${two(local.month)} $time';
}
