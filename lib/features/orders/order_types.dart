import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_colors.dart';

/// A transport type's own icon and colour.
///
/// The icon and the **exact** colour pair WPS gives that type in its own
/// "Nowe zamówienie" menu (`text-<c>-600` / `dark:text-<c>-400`, see
/// ORDER_TYPES in OrdersCipListTable.js), so one type reads as one thing
/// across the dashboard, ../../../smOrder and here - an operator and a
/// foreman pointing at "the orange one" mean the same transport.
///
/// Deliberately a trimmed copy of smOrder's own order_types.dart: that app
/// also keeps per-type *form fields* there, which this app has no use for
/// (it never creates an order). Same reasoning as order_status.dart being
/// duplicated rather than shared - these are separate apps in separate
/// repositories, and the duplication is the thing keeping them identical on
/// purpose rather than by accident.
class OrderTypeConfig {
  const OrderTypeConfig({required this.code, required this.icon, required this.iconLight, required this.iconDark});

  final String code;
  final IconData icon;
  final Color iconLight;
  final Color iconDark;

  Color iconColor(Brightness brightness) => brightness == Brightness.dark ? iconDark : iconLight;
}

const orderTypes = [
  OrderTypeConfig(
    code: 'water_refill',
    icon: LucideIcons.droplets,
    iconLight: AppColors.blue600,
    iconDark: AppColors.blue400,
  ),
  OrderTypeConfig(
    code: 'material_order',
    icon: LucideIcons.package,
    iconLight: AppColors.pink600,
    iconDark: AppColors.pink400,
  ),
  OrderTypeConfig(
    code: 'spool_order',
    icon: LucideIcons.spool,
    iconLight: AppColors.gray600,
    // wps pairs this one with neutral-300, not gray-400.
    iconDark: AppColors.neutral300,
  ),
  OrderTypeConfig(
    code: 'goods_transport',
    icon: LucideIcons.truck,
    iconLight: AppColors.orange600,
    iconDark: AppColors.orange400,
  ),
  OrderTypeConfig(
    code: 'waste_removal',
    icon: LucideIcons.trash2,
    iconLight: AppColors.yellow600,
    iconDark: AppColors.yellow400,
  ),
  OrderTypeConfig(
    code: 'warehouse_return',
    icon: LucideIcons.undo2,
    iconLight: AppColors.green600,
    iconDark: AppColors.green400,
  ),
  OrderTypeConfig(
    code: 'machine_transport',
    icon: LucideIcons.forklift,
    iconLight: AppColors.gray600,
    iconDark: AppColors.neutral300,
  ),
];

OrderTypeConfig orderTypeConfig(String code) =>
    orderTypes.firstWhere((t) => t.code == code, orElse: () => orderTypes.first);
