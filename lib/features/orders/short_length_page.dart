import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/session_providers.dart';
import '../../i18n/gen/strings.g.dart';
import 'orders_api.dart';
import 'photo_field.dart';
import 'short_lengths_api.dart';

/// "Krótkie odcinki" - reporting, from inside a task, that what is being
/// brought for one of its materials is remnants rather than a full drum.
///
/// Three things and no more: **which material** (from this order's own
/// lines, so there is nothing to type or scan), **how much** in the
/// operator's own words, and **a photo**. The office reads the result in
/// wps under Transporty → Krótkie odcinki.
///
/// Nothing here moves stock or ticks the order off - a remnant left the
/// warehouse when it was first issued, and this is the record that it was
/// used, not a second issue of it.
class ShortLengthPage extends ConsumerStatefulWidget {
  const ShortLengthPage({super.key, required this.order});

  final TransportOrder order;

  @override
  ConsumerState<ShortLengthPage> createState() => _ShortLengthPageState();
}

class _ShortLengthPageState extends ConsumerState<ShortLengthPage> {
  late String? _itemNo = widget.order.items.length == 1 ? widget.order.items.first.itemNo : null;
  final _quantityController = TextEditingController();
  PickedPhoto? _photo;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _itemNo != null && !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final employeeNo = ref.read(sessionProvider)?.userId ?? '';
      final item = widget.order.items.firstWhere((i) => i.itemNo == _itemNo);
      final api = ref.read(shortLengthsApiProvider);
      final reportId = await api.create(
        orderId: widget.order.id,
        itemNo: item.itemNo,
        itemName: item.itemName,
        quantity: _quantityController.text.trim(),
        reportedBy: employeeNo,
      );

      // The photo second, under the report's own id. A failure here must not
      // read as "the report was not made" - it was, and it is already on the
      // office's list - so it is reported on its own and the report stands.
      final photo = _photo;
      if (photo != null) {
        try {
          await api.uploadPhoto(reportId: reportId, photo: photo, uploadedBy: employeeNo);
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _error = context.t.shortLengths.photoUploadError;
          });
          return;
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = context.t.shortLengths.submitError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.shortLengths;

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
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Icon(LucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.title,
                          style: theme.textTheme.h3.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(widget.order.orderNo, style: theme.textTheme.muted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(t.material, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  for (final item in widget.order.items) ...[
                    _ItemOption(
                      itemNo: item.itemNo,
                      itemName: item.itemName,
                      selected: _itemNo == item.itemNo,
                      onTap: () => setState(() => _itemNo = item.itemNo),
                    ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 8),
                  Text(t.quantity, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ShadInput(controller: _quantityController, placeholder: Text(t.quantity)),

                  const SizedBox(height: 20),
                  PhotoField(photo: _photo, onChanged: (photo) => setState(() => _photo = photo)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                border: Border(top: BorderSide(color: theme.colorScheme.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.destructive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_error!, style: theme.textTheme.small.copyWith(color: theme.colorScheme.destructive)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ShadButton(onPressed: _canSubmit ? _submit : null, child: Text(t.submit)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the order's own materials. A full-width row rather than a chip:
/// these are catalog names, not four-character codes, and the operator is
/// picking one of a handful.
class _ItemOption extends StatelessWidget {
  const _ItemOption({required this.itemNo, required this.itemName, required this.selected, required this.onTap});

  final String itemNo;
  final String itemName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.accent : theme.colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 20,
              color: selected ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    itemName.isEmpty ? itemNo : itemName,
                    style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(itemNo, style: theme.textTheme.muted.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
