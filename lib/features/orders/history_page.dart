import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../i18n/gen/strings.g.dart';
import 'order_detail_page.dart';
import 'order_status.dart';
import 'orders_api.dart';
import 'orders_providers.dart';

/// "Historia" - orders that are finished (wpsApi's `history` scope: done +
/// cancelled), newest first, **grouped by the day they were closed on**:
/// "Dziś", "Wczoraj", then plain dates. A forklift operator's question here
/// is "what did I do today / yesterday", so the day is the structure rather
/// than a column to read off each row.
///
/// Cancelled ones are kept, not filtered out: an order that ended with a
/// reported problem is part of what happened on that shift, and hiding it
/// would quietly lose it. The status badge says which is which.
///
/// Shows **everyone's** history, not just this device's operator - the whole
/// app family runs on shared access and wpsApi has no per-employee filter
/// (listOrders takes only a scope). Filtering to `fulfilledBy == my
/// employee number` would be a one-line change here if that is wanted.
///
/// No polling: finished orders do not change. Re-selecting the tab remounts
/// this page (AppShell swaps pages in directly), and that re-fetches.
/// Also no paging - wpsApi returns the whole history scope, which is fine at
/// this warehouse's volume but is the thing to revisit first if this ever
/// gets slow.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  Future<void> _open(TransportOrder order) async {
    await Navigator.of(context).push(
      PageRouteBuilder(pageBuilder: (context, _, _) => OrderDetailPage(orderId: order.id, initial: order)),
    );
  }

  /// Groups into day buckets, newest day first and newest order first within
  /// a day. Keyed on the local calendar date, so "today" means the
  /// operator's today, not UTC's.
  List<(DateTime day, List<TransportOrder> orders)> _byDay(List<TransportOrder> all) {
    final buckets = <DateTime, List<TransportOrder>>{};
    for (final order in all) {
      final local = order.closedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      buckets.putIfAbsent(day, () => []).add(order);
    }
    final days = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final day in days) {
      buckets[day]!.sort((a, b) => b.closedAt.compareTo(a.closedAt));
    }
    return [for (final day in days) (day, buckets[day]!)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.orders.history;

    final historyAsync = ref.watch(historyOrdersProvider);
    // Whatever was last known stays on screen while a refresh runs or after
    // one fails - loading and error only show when there is nothing yet.
    final history = historyAsync.value;

    if (history == null && historyAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.loadError, style: theme.textTheme.muted.copyWith(color: theme.colorScheme.destructive), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ShadButton.outline(
                onPressed: () => ref.invalidate(historyOrdersProvider),
                child: Text(context.t.orders.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (history == null) {
      return Center(child: Text(context.t.orders.loading, style: theme.textTheme.muted));
    }
    if (history.isEmpty) {
      return Center(child: Text(t.empty, style: theme.textTheme.muted));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        for (final (day, orders) in _byDay(history)) ...[
          _DayHeader(day: day, count: orders.length),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < orders.length; i++) ...[
                  if (i > 0) Container(height: 1, color: theme.colorScheme.border),
                  _HistoryRow(order: orders[i], onTap: () => _open(orders[i])),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

/// "Dziś" / "Wczoraj" / "29.09.2026", with how many orders closed that day.
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.count});
  final DateTime day;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.orders.history;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    final label = switch (diff) {
      0 => t.today,
      1 => t.yesterday,
      // Named days read faster than a date for the two days anyone actually
      // asks about; everything older is just the date.
      _ => _formatDay(day),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.p.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text('$count', style: theme.textTheme.muted),
        ],
      ),
    );
  }
}

/// One finished order as a table row: when it closed, where it went and what
/// it was, and how it ended. Tabular rather than a card - a finished order is
/// a log entry to scan down a column, not something to act on (tapping still
/// opens the full order).
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.order, required this.onTap});
  final TransportOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rootT = context.t;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Fixed width so the times line up down the list, which is the
            // whole point of making this a table and not cards.
            SizedBox(
              width: 44,
              child: Text(_formatTime(order.closedAt), style: theme.textTheme.muted.copyWith(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.route(),
                    style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    orderTypeLabel(rootT, order.type),
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OrderStatusBadge(status: order.status, label: orderStatusLabel(rootT, order.status)),
          ],
        ),
      ),
    );
  }
}

String _two(int n) => n.toString().padLeft(2, '0');
String _formatDay(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';
String _formatTime(DateTime d) {
  final local = d.toLocal();
  return '${_two(local.hour)}:${_two(local.minute)}';
}
