import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../i18n/gen/strings.g.dart';
import 'frp_stock_api.dart';

/// "Stan FRP" - the live FRP list wps shows under Stock → Aktualna lista
/// (`frp_current`), on the operator's own phone.
///
/// Opened from an order that has FRP on it, which is the only moment this
/// app has any business showing stock: the operator has been asked to bring
/// a drum and needs to know which one and where it is standing.
///
/// **The order's own item numbers come first**, in their own group, with
/// everything else below. The whole list is here because a drum of the
/// ordered item may be missing, reserved or too short, and the next-best
/// drum is the thing the operator actually goes and looks for; putting the
/// ordered ones on top saves the scrolling without hiding that.
class FrpStockPage extends ConsumerStatefulWidget {
  const FrpStockPage({super.key, this.orderItemNos = const {}});

  /// The FRP item numbers this order asked for, if it was opened from one.
  final Set<String> orderItemNos;

  @override
  ConsumerState<FrpStockPage> createState() => _FrpStockPageState();
}

class _FrpStockPageState extends ConsumerState<FrpStockPage> {
  List<FrpStockRow>? _rows;
  bool _failed = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final rows = await ref.read(frpStockApiProvider).list();
      if (mounted) setState(() => _rows = rows);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.frpStock;
    final rows = _rows;

    final needle = _search.trim().toLowerCase();
    bool matches(FrpStockRow r) =>
        needle.isEmpty ||
        r.displayName.toLowerCase().contains(needle) ||
        r.itemNo.toLowerCase().contains(needle) ||
        r.drumNumber.toLowerCase().contains(needle) ||
        r.location.toLowerCase().contains(needle);

    final visible = (rows ?? const <FrpStockRow>[]).where(matches).toList();
    final ordered = visible.where((r) => widget.orderItemNos.contains(r.itemNo)).toList();
    final rest = visible.where((r) => !widget.orderItemNos.contains(r.itemNo)).toList();

    Widget body;
    if (_failed) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.loadError, style: theme.textTheme.muted, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ShadButton.outline(onPressed: _load, child: Text(t.retry)),
            ],
          ),
        ),
      );
    } else if (rows == null) {
      body = Center(child: Text(t.loading, style: theme.textTheme.muted));
    } else if (visible.isEmpty) {
      body = Center(child: Text(t.empty, style: theme.textTheme.muted));
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (ordered.isNotEmpty) ...[
            _GroupHeader(title: t.fromThisOrder, count: ordered.length),
            for (final row in ordered) ...[_FrpRow(row: row, highlight: true), const SizedBox(height: 8)],
            const SizedBox(height: 12),
          ],
          if (rest.isNotEmpty) ...[
            if (ordered.isNotEmpty) _GroupHeader(title: t.otherDrums, count: rest.length),
            for (final row in rest) ...[_FrpRow(row: row, highlight: false), const SizedBox(height: 8)],
          ],
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ShadInput(
            placeholder: Text(t.searchPlaceholder),
            leading: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(LucideIcons.search, size: 16)),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.mutedForeground),
          ),
          const SizedBox(width: 6),
          Text('$count', style: theme.textTheme.muted),
        ],
      ),
    );
  }
}

/// One drum. The two facts that send somebody walking - **which drum** and
/// **where** - lead; the item number and the note sit under them, because
/// they are what you check once you are standing in front of it.
class _FrpRow extends StatelessWidget {
  const _FrpRow({required this.row, required this.highlight});
  final FrpStockRow row;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.frpStock;
    final muted = theme.textTheme.small.copyWith(fontSize: 12, color: theme.colorScheme.mutedForeground);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: highlight ? theme.colorScheme.accent : theme.colorScheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? theme.colorScheme.primary.withValues(alpha: 0.4) : theme.colorScheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  row.displayName,
                  style: theme.textTheme.p.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                row.lengthKmLabel,
                style: theme.textTheme.p.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(LucideIcons.disc3, size: 14, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 4),
              Text(
                row.drumNumber.isEmpty ? '-' : row.drumNumber,
                style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Icon(LucideIcons.mapPin, size: 14, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 4),
              Text(
                row.location.isEmpty ? '-' : row.location,
                style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
              ),
              if (row.type.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(row.type, style: muted),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(child: Text(row.itemNo, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis)),
              // Spoken for by another order: worth knowing before carrying
              // it across the hall.
              if (row.reserved) ...[
                const SizedBox(width: 8),
                Icon(LucideIcons.lock, size: 13, color: theme.colorScheme.destructive),
                const SizedBox(width: 3),
                Text(t.reserved, style: muted.copyWith(color: theme.colorScheme.destructive)),
              ],
            ],
          ),
          if (row.remark.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(row.remark, style: muted, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}
