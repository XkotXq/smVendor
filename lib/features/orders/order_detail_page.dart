import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/session_providers.dart';
import '../../i18n/gen/strings.g.dart';
import 'order_status.dart';
import 'orders_api.dart';

const _pollInterval = Duration(seconds: 3);

/// One order's own page (reached by tapping a card on OrdersPage) - every
/// field live (polled - see _pollInterval), and every action this app has
/// for an order: "Rozpocznij realizację" (new -> in_progress) and, once
/// every item is fully issued (checked server-side too, not just trusted
/// from this screen's own poll - see wpsapi's deliverOrder), either
/// "Dostarczone" (in_progress -> delivered) or, if delivery itself can't
/// happen even though everything's issued, "Zgłoś problem"
/// (in_progress -> cancelled) - the two sit side by side at that point.
/// What happens *after* delivery (the requester accepting/reporting a
/// problem on what was actually delivered, or the 10-minute auto-accept)
/// is wps's own "Zgadza się"/"Zgłoś problem" (that app is the requester's
/// own "apka do zamawiania") - a delivered order here just shows that it's
/// awaiting that confirmation, nothing to press on this side any more.
class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({super.key, required this.orderId, this.initial});

  final String orderId;

  /// The order as the list already knew it, when it was opened from there.
  /// Rendered immediately, so opening an order is instant and stays
  /// readable on a weak connection instead of showing a spinner over data
  /// the device already has. The fetch and the poll then keep it live.
  final TransportOrder? initial;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

enum _LoadStatus { loading, ready, error }

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  late _LoadStatus _status = widget.initial == null ? _LoadStatus.loading : _LoadStatus.ready;
  late TransportOrder? _order = widget.initial;
  Timer? _pollTimer;
  bool _polling = false;
  bool _acting = false; // take()/deliver() in flight
  String? _actionError;


  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// The first real fetch. With an order already seeded from the list
  /// ([OrderDetailPage.initial]) this must not fall back to the loading or
  /// error screen - that would throw away data the operator can already
  /// read, which is the opposite of the point. It just leaves what is on
  /// screen and lets the poll try again.
  Future<void> _load() async {
    final seeded = _order != null;
    if (!seeded) setState(() => _status = _LoadStatus.loading);
    try {
      final order = await ref.read(ordersApiProvider).get(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _status = _LoadStatus.ready;
      });
    } catch (_) {
      if (!mounted || seeded) return;
      setState(() => _status = _LoadStatus.error);
    }
  }

  /// Silent on failure (stays on the last good state) and never re-shows
  /// the loading state, so a poll never interrupts a take()/deliver() the
  /// operator is mid-tap on.
  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final order = await ref.read(ordersApiProvider).get(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _status = _LoadStatus.ready;
      });
    } catch (_) {
      // Stay on whatever was last shown.
    } finally {
      _polling = false;
    }
  }

  Future<void> _take() async {
    setState(() {
      _acting = true;
      _actionError = null;
    });
    try {
      final updated = await ref.read(ordersApiProvider).take(widget.orderId, ref.read(sessionProvider)?.userId ?? '');
      if (!mounted) return;
      setState(() {
        _order = updated;
        _acting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _acting = false;
        _actionError = e.toString();
      });
    }
  }

  Future<void> _deliver() async {
    setState(() {
      _acting = true;
      _actionError = null;
    });
    try {
      final updated = await ref.read(ordersApiProvider).deliver(widget.orderId, ref.read(sessionProvider)?.userId ?? '');
      if (!mounted) return;
      setState(() {
        _order = updated;
        _acting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _acting = false;
        _actionError = context.t.orders.detail.deliverError;
      });
    }
  }

  /// "Zgłoś problem" next to "Dostarczone" - asks what is wrong, then flags
  /// the order as blocked (in_progress -> problem, see
  /// OrdersApi.reportProblem). It is **not** a cancellation: the order
  /// stays open, the requester is asked to sort it out, and once they mark
  /// it resolved this screen offers "Dostarczone" again.
  ///
  /// The description is required, so an empty dialog result is treated the
  /// same as dismissing it - nothing is reported.
  Future<void> _reportProblem() async {
    final reason = await showShadDialog<String>(context: context, builder: (_) => const _ReportProblemDialog());
    if (reason == null || reason.isEmpty || !mounted) return;
    setState(() {
      _acting = true;
      _actionError = null;
    });
    try {
      final updated = await ref.read(ordersApiProvider).reportProblem(
        widget.orderId,
        reportedBy: ref.read(sessionProvider)?.userId ?? '',
        note: reason,
      );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _acting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _acting = false;
        _actionError = context.t.orders.detail.reportProblemError;
      });
    }
  }

  /// "Problem rozwiązany" - the operator's answer to a delivery the
  /// requester rejected (problem -> in_progress). No dialog: this is the
  /// one tap that gets the transport moving again, and the operator then
  /// has to press "Dostarczone" a second time anyway.
  Future<void> _resolveProblem() async {
    setState(() {
      _acting = true;
      _actionError = null;
    });
    try {
      final updated = await ref
          .read(ordersApiProvider)
          .resolveProblem(widget.orderId, resolvedBy: ref.read(sessionProvider)?.userId ?? '');
      if (!mounted) return;
      setState(() {
        _order = updated;
        _acting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _acting = false;
        _actionError = context.t.orders.detail.resolveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t;

    Widget body;
    if (_status == _LoadStatus.loading) {
      body = Center(child: Text(t.orders.loading, style: theme.textTheme.muted));
    } else if (_status == _LoadStatus.error || _order == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.orders.loadError, style: theme.textTheme.muted.copyWith(color: theme.colorScheme.destructive), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ShadButton.outline(onPressed: _load, child: Text(t.orders.retry)),
            ],
          ),
        ),
      );
    } else {
      body = _OrderDetailBody(
        order: _order!,
        acting: _acting,
        actionError: _actionError,
        onTake: _take,
        onDeliver: _deliver,
        onReportProblem: _reportProblem,
        onResolveProblem: _resolveProblem,
      );
    }

    return ColoredBox(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  ShadButton.ghost(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(LucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _order?.orderNo ?? '...',
                      style: theme.textTheme.h3.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_order != null) OrderStatusBadge(status: _order!.status, label: orderStatusLabel(t, _order!.status)),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({
    required this.order,
    required this.acting,
    required this.actionError,
    required this.onTake,
    required this.onDeliver,
    required this.onReportProblem,
    required this.onResolveProblem,
  });

  final TransportOrder order;
  final bool acting;
  final String? actionError;
  final VoidCallback onTake;
  final VoidCallback onDeliver;
  final VoidCallback onReportProblem;
  final VoidCallback onResolveProblem;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.orders.detail;

    Widget infoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.muted)),
          Flexible(
            child: Text(value, style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.right),
          ),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(orderTypeLabel(context.t, order.type), style: theme.textTheme.h4),
              const SizedBox(height: 8),
              infoRow(t.line, order.route()),
              if (order.productionOrderNo != null) infoRow(t.productionOrderNo, order.productionOrderNo!),
              infoRow(t.employeeNo, order.employeeNo.isEmpty ? '-' : order.employeeNo),
              if (order.deliveredBy != null) infoRow(t.deliveredBy, order.deliveredBy!),
              if (order.fulfilledBy != '-') infoRow(t.fulfilledBy, order.fulfilledBy),
              infoRow(t.createdAt, _formatDateTime(order.createdAt)),
              if (order.note != '-' && order.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(order.note, style: theme.textTheme.p),
              ],
            ],
          ),
        ),
        // "Wytyczne do transportów" for the destination line, whatever is
        // being brought - set up in wps, resolved server-side (see
        // wpsApi's lineRuleNote). Right under the order's own details and
        // above the materials, because it is about *this drive* and the
        // operator should read it before loading anything. Amber, the same
        // colour wps marks a guideline with.
        if (order.lineRuleNote.isNotEmpty) ...[
          const SizedBox(height: 16),
          _GuidelineBanner(text: order.lineRuleNote),
        ],
        if (order.items.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(t.itemsTitle, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < order.items.length; i++) ...[
                  if (i > 0) Container(height: 1, color: theme.colorScheme.border),
                  _OrderItemTile(item: order.items[i]),
                ],
              ],
            ),
          ),
        ],
        if (actionError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.destructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              actionError!,
              style: theme.textTheme.small.copyWith(color: theme.colorScheme.destructive),
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (order.status == 'new')
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ShadButton(onPressed: acting ? null : onTake, child: Text(t.take)),
          )
        // An open problem. Which side reported it decides whether this
        // screen can do anything about it:
        //  - the operator reported it -> the requester's move, nothing to
        //    press here (and no "Dostarczone": the order cannot be handed
        //    over while it is stuck, which wpsApi refuses anyway).
        //  - the **requester** rejected what was delivered -> it is this
        //    operator who has to put it right, mark it corrected and
        //    deliver again. The rejection already un-delivered the order.
        else if (order.hasOpenProblem)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.triangleAlert, size: 18, color: theme.colorScheme.destructive),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.awaitingMyAnswer ? t.problemFromRequester : t.problemWaiting,
                            style: theme.textTheme.small.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                          if (order.problemNote.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(order.problemNote, style: theme.textTheme.p),
                          ],
                          if (order.awaitingMyAnswer) ...[
                            const SizedBox(height: 6),
                            Text(t.problemResolveHint, style: theme.textTheme.small.copyWith(fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (order.awaitingMyAnswer) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Chat is deferred, and shown-but-disabled on purpose:
                    // the pair is what makes marking it corrected the
                    // obvious choice rather than the only one.
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ShadButton.outline(
                          onPressed: null,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.chat),
                              Text(t.chatSoon, style: theme.textTheme.muted.copyWith(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 52,
                        child: ShadButton(
                          onPressed: acting ? null : onResolveProblem,
                          child: Text(t.problemResolve),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          )
        else if (order.status == 'inProgress' && order.canDeliver)
          Column(
            children: [
              // The requester has sorted the last problem out - said here
              // because the operator was waiting on exactly that, and
              // nothing else on screen would tell them it changed.
              if (order.problemResolvedAt != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.circleCheck, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.problemResolvedBy(who: order.problemResolvedBy ?? '-'),
                          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ShadButton.outline(onPressed: acting ? null : onReportProblem, child: Text(t.reportProblem)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ShadButton(onPressed: acting ? null : onDeliver, child: Text(t.deliver)),
                    ),
                  ),
                ],
              ),
            ],
          )
        else if (order.status == 'delivered')
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.clock, size: 18, color: theme.colorScheme.mutedForeground),
                const SizedBox(width: 8),
                Expanded(child: Text(t.awaitingAcceptance, style: theme.textTheme.small)),
              ],
            ),
          ),
      ],
    );
  }
}

/// A transport guideline ("Wytyczne do transportów", set up in wps) -
/// amber, the same colour wps marks one with, so an operator who has seen
/// the dashboard recognises it here. [compact] is the per-material variant
/// that sits inside an item row; the full one is for the line-wide note.
class _GuidelineBanner extends StatelessWidget {
  const _GuidelineBanner({required this.text, this.compact = false});
  final String text;
  final bool compact;

  // Tailwind amber-50/amber-800 and their dark counterparts - wps uses
  // exactly these for a guideline (bg-amber-50 / text-amber-800,
  // dark:bg-amber-500/15 / dark:text-amber-300).
  static const _bgLight = Color(0xFFFFFBEB);
  static const _fgLight = Color(0xFF92400E);
  static const _bgDark = Color(0x26F59E0B);
  static const _fgDark = Color(0xFFFCD34D);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final fg = dark ? _fgDark : _fgLight;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14, vertical: compact ? 5 : 12),
      decoration: BoxDecoration(
        color: dark ? _bgDark : _bgLight,
        borderRadius: BorderRadius.circular(compact ? 8 : 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.triangleAlert, size: compact ? 13 : 18, color: fg),
          SizedBox(width: compact ? 6 : 10),
          Expanded(
            child: Text(
              text,
              style: (compact ? theme.textTheme.small : theme.textTheme.p).copyWith(
                color: fg,
                fontSize: compact ? 12 : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.orders.detail;
    final fulfilled = item.isFulfilled;
    final required = '${item.quantity} ${item.unit}'.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(
            fulfilled ? LucideIcons.circleCheck : LucideIcons.circle,
            size: 20,
            color: fulfilled ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: fulfilled ? TextDecoration.lineThrough : null,
                    color: fulfilled ? theme.colorScheme.mutedForeground : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(item.itemNo, style: theme.textTheme.muted.copyWith(fontSize: 12)),
                // This material's own guideline on this line (e.g. "krótkie
                // odcinki najpierw") - the thing the operator has to know
                // *while loading this item*, so it sits on the item rather
                // than with the order's details.
                if (item.ruleNote.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _GuidelineBanner(text: item.ruleNote, compact: true),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(required, style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w700)),
              if ((double.tryParse(item.issuedQuantity) ?? 0) > 0) ...[
                const SizedBox(height: 2),
                Text(
                  t.issued(value: '${item.issuedQuantity} ${item.unit}'.trim()),
                  style: theme.textTheme.muted.copyWith(fontSize: 12, color: theme.colorScheme.primary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// The optional reason text for "Zgłoś problem" - pops the trimmed text
/// (possibly empty, cancelOrder's own reason is optional) on submit, or
/// null if dismissed without choosing either button (back/outside tap) -
/// _reportProblem's own null check treats that as "nothing to do".
class _ReportProblemDialog extends StatefulWidget {
  const _ReportProblemDialog();

  @override
  State<_ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<_ReportProblemDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.orders.detail;
    return ShadDialog(
      title: Text(t.reportProblemTitle),
      description: Text(t.reportProblemDescription),
      actions: [
        ShadButton.outline(onPressed: () => Navigator.of(context).pop(), child: Text(t.reportProblemCancel)),
        ShadButton.destructive(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(t.reportProblemSubmit),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: ShadInput(controller: _controller, placeholder: Text(t.reportProblemPlaceholder), maxLines: 3),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${pad(local.month)}-${pad(local.day)} ${pad(local.hour)}:${pad(local.minute)}';
}
