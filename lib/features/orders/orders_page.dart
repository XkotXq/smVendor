import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/session_providers.dart';
import '../../i18n/gen/strings.g.dart';
import 'order_detail_page.dart';
import 'order_status.dart';
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

/// "Zamówienia" - the working queue (scope: active, i.e. new + in_progress +
/// delivered - same split as wps's own "Lista zamówień", see wpsapi's
/// AGENTS.md "Transport orders"). Every card is just a summary now - tap it
/// to open OrderDetailPage, which owns every action (Rozpocznij realizację,
/// Dostarczone) and shows live-updating detail.
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

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

  @override
  void initState() {
    super.initState();
    // No initial load: the provider fetches on first use and **keeps** the
    // list afterwards (see ordersProvider), so coming back to this tab
    // shows what is already known straight away and only refreshes behind
    // it. This page just owns the ticking.
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
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
  /// in_progress). The list then refreshes in place, so the card moves from
  /// "Nowe zamówienia" up into "W realizacji" by itself - nothing navigates
  /// anywhere, because taking an order is not a reason to leave the queue.
  Future<void> _take(TransportOrder order) async {
    if (_taking.contains(order.id)) return;
    setState(() => _taking.add(order.id));
    try {
      await ref.read(ordersApiProvider).take(order.id, ref.read(sessionProvider)?.userId ?? '');
      if (mounted) await _poll();
    } catch (_) {
      // Left to the next tick: the order either moved or it did not, and
      // the list is the honest answer either way. A failed take with no
      // message is a gap worth filling once there is somewhere on this
      // screen to put one.
    } finally {
      if (mounted) setState(() => _taking.remove(order.id));
    }
  }

  Future<void> _open(TransportOrder order) async {
    await Navigator.of(context).push(
      PageRouteBuilder(pageBuilder: (context, _, _) => OrderDetailPage(orderId: order.id, initial: order)),
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

    Widget body;
    if (orders == null && ordersAsync.hasError) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.loadError, style: theme.textTheme.muted.copyWith(color: theme.colorScheme.destructive), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ShadButton.outline(
                onPressed: () => ref.invalidate(activeOrdersProvider),
                child: Text(t.retry),
              ),
            ],
          ),
        ),
      );
    } else if (orders == null) {
      body = Center(child: Text(t.loading, style: theme.textTheme.muted));
    } else if (orders.isEmpty) {
      body = Center(child: Text(t.empty, style: theme.textTheme.muted));
    } else {

      final wide = MediaQuery.sizeOf(context).width >= _kWideBreakpoint;
      // Grouped by what the operator is supposed to do with each group,
      // in that order: what is already being hauled, what is free to take,
      // and what has been dropped off and is only waiting on the person who
      // ordered it. One flat list (what this was) made "mine, in progress"
      // indistinguishable from "nobody has taken this yet", which is the
      // one distinction that decides what to do next.
      //
      // The order within a group stays the server's own (created_at DESC).
      // An empty group is left out entirely rather than shown as a heading
      // with nothing under it.
      final sections = [
        // Blocked first: it is the only group where somebody is waiting on
        // someone else, so it is the one worth seeing before anything else.
        (title: t.sectionProblem, orders: orders.where((o) => o.status == 'problem').toList()),
        (title: t.sectionInProgress, orders: orders.where((o) => o.status == 'inProgress').toList()),
        (title: t.sectionNew, orders: orders.where((o) => o.status == 'new').toList()),
        (title: t.sectionDelivered, orders: orders.where((o) => o.status == 'delivered').toList()),
      ].where((s) => s.orders.isNotEmpty);

      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in sections) ...[
            _SectionHeader(title: section.title, count: section.orders.length),
            // Phone: a plain stacked column - each card sized to its own
            // natural content. Tablet: rows of three, each row as tall as
            // its own tallest card (see _CardRows) - never a fixed
            // aspect ratio, which forced every card into the same square
            // box whatever was in it.
            if (wide)
              _CardRows(orders: section.orders, onOpen: _open, onTake: _take, taking: _taking)
            else
              for (var i = 0; i < section.orders.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _OrderCard(
                  order: section.orders[i],
                  onTap: () => _open(section.orders[i]),
                  onTake: () => _take(section.orders[i]),
                  taking: _taking.contains(section.orders[i].id),
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
  const _CardRows({required this.orders, required this.onOpen, required this.onTake, required this.taking});

  final List<TransportOrder> orders;
  final void Function(TransportOrder) onOpen;
  final void Function(TransportOrder) onTake;

  /// Ids with a take() in flight - see _OrderCard.taking.
  final Set<String> taking;

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
                            taking: taking.contains(rows[r][c].id),
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
  const _OrderCard({required this.order, required this.onTap, required this.onTake, required this.taking});
  final TransportOrder order;
  final VoidCallback onTap;
  final VoidCallback onTake;

  /// A take() is in flight for this order - the button goes dead so a
  /// double tap cannot send it twice.
  final bool taking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final rootT = context.t;
    final t = rootT.orders;
    // Whose order this is. The queue shows every operator's in-progress
    // work, so a card that is not mine must say who has it rather than
    // claiming I am on it.
    final mine = order.takenBy != null && order.takenBy == ref.watch(sessionProvider)?.userId;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    orderTypeLabel(rootT, order.type),
                    style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                OrderStatusBadge(status: order.status, label: orderStatusLabel(rootT, order.status)),
              ],
            ),
            const SizedBox(height: 6),
            Text(order.orderNo, style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(order.route(), style: theme.textTheme.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (order.note != '-' && order.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(order.note, style: theme.textTheme.small, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            // An open problem, and - when the requester is the one who
            // rejected the delivery - that it is this operator's to put
            // right. The card is how they find out it came back at all.
            if (order.hasOpenProblem) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.triangleAlert, size: 14, color: theme.colorScheme.destructive),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.problemNote.isNotEmpty)
                          Text(
                            order.problemNote,
                            style: theme.textTheme.small.copyWith(
                              color: theme.colorScheme.destructive,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          order.awaitingMyAnswer ? t.card.problemFromRequester : t.card.problemWithRequester,
                          style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Text(
              '${t.card.employeeNo}: ${order.employeeNo.isEmpty ? '-' : order.employeeNo}',
              style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Taking an order straight from the list, without opening it
            // first - that is the one action worth having here, because it
            // is what an operator does to a queue of new orders. A card
            // that is already being hauled keeps the button, disabled and
            // relabelled, rather than dropping it: an empty space where a
            // button was on the card above reads as "this one is
            // different somehow" and invites a second look.
            if (order.status == 'new' || order.status == 'inProgress') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: order.status == 'new'
                    ? ShadButton(onPressed: taking ? null : onTake, child: Text(t.card.take))
                    : ShadButton.outline(
                        onPressed: null,
                        leading: Icon(mine ? LucideIcons.check : LucideIcons.user, size: 16),
                        child: Text(mine ? t.card.taken : t.card.takenBy(who: order.takenBy ?? '-')),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
