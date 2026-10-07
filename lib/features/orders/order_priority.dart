import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_colors.dart';

/// How urgent the requester said a transport is - wpsApi's own PRIORITIES,
/// least to most. Set in smOrder when the order is placed; read-only here.
///
/// Green, amber, red - one shape at every level, so the mark is recognised
/// before it is read and the colour carries the level.
Color orderPriorityColor(String priority, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return switch (priority) {
    // The app's own red, the one the destructive theme colour uses - not a
    // new one invented for this mark.
    'critical' => dark ? AppColors.destructiveDark : AppColors.destructiveLight,
    'urgent' => dark ? AppColors.yellow400 : AppColors.yellow600,
    _ => dark ? AppColors.green400 : AppColors.green600,
  };
}

/// Three rising bars, drawn rather than taken from the icon font.
///
/// Lucide ships this shape (`chartNoAxesColumnIncreasing`) and it was what
/// this used at first, but an icon font bakes its stroke width into the
/// glyph: the only way to make the bars heavier is to make the whole icon
/// bigger. On a card scanned at arm's length in a warehouse the weight is
/// the point, so the bars are three filled rectangles here and [barWidth]
/// says how thick they are.
///
/// Deliberately not a Lucide icon any more, and deliberately the only such
/// exception in this app - everything else stays with the icon set.
class OrderPriorityBars extends StatelessWidget {
  const OrderPriorityBars({
    super.key,
    required this.priority,
    this.size = 20,
    this.barWidth = 5,
    this.gap = 2.5,
  });

  final String priority;

  /// The mark's overall height; the tallest bar is exactly this.
  final double size;
  final double barWidth;
  final double gap;

  /// Each bar's share of the full height - a rising run, same proportions
  /// the Lucide glyph used.
  static const _heights = [0.45, 0.72, 1.0];

  @override
  Widget build(BuildContext context) {
    // The **resolved** theme brightness, not the platform's: somebody who
    // forced light or dark in Konto must get that mark, not the one the
    // phone would have chosen.
    final color = orderPriorityColor(priority, ShadTheme.of(context).brightness);
    return SizedBox(
      height: size,
      width: barWidth * 3 + gap * 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _heights.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Container(
              width: barWidth,
              height: size * _heights[i],
              decoration: BoxDecoration(
                color: color,
                // Just enough to take the hard corner off at this size -
                // a fully rounded cap would read as a bar chart drawn by
                // somebody else.
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
