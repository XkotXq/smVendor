import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// "Tap one of these" - the one shape this app uses for it.
///
/// Mirrors smOrder's own widgets/option_chip.dart (the two apps are kept
/// file-for-file wherever the shape matches - see AGENTS.md), minus nothing
/// and plus an optional icon, which is what makes a theme picker scannable
/// without reading three words.
///
/// 48dp tall, which is Android's floor for a touch target: the settings
/// pills this replaced were 40, and the person tapping them is as likely to
/// be in a work glove as the one picking a line.
class OptionChip extends StatelessWidget {
  const OptionChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.expand = false,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  /// Fill the row it sits in - for a set of mutually exclusive answers,
  /// where splitting the width gives each the largest target available.
  final bool expand;

  /// Optional, and only where it carries meaning the label does not: a sun
  /// beside "Jasny" is read before the word is.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final tone = selected ? theme.colorScheme.primary : theme.colorScheme.foreground;

    final chip = Container(
      height: 48,
      constraints: const BoxConstraints(minWidth: 64),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: icon == null ? 16 : 12),
      decoration: BoxDecoration(
        color: selected ? theme.colorScheme.accent : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: tone),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.p.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: tone,
              ),
            ),
          ),
        ],
      ),
    );

    final tappable = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: chip);
    return expand ? Expanded(child: tappable) : tappable;
  }
}
