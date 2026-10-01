import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../features/account/account_page.dart';
import '../features/orders/history_page.dart';
import '../features/orders/orders_page.dart';
import '../i18n/gen/strings.g.dart';

/// Below this width (a phone in portrait or a small phone in landscape) the
/// nav is a bottom bar (see _BottomNav) - same breakpoint idea as wps's own
/// sidebar, just inverted for a touchscreen: a tablet/desktop has the width
/// to spare for an always-visible side nav (_SideNav, wps's own design -
/// see theme/), a phone doesn't.
const _kWideBreakpoint = 600.0;

class _NavEntry {
  const _NavEntry(this.icon, this.label, this.page);
  final IconData icon;
  final String label;
  final Widget page;
}

/// The whole app past login: which nav entry is selected lives here (plain
/// widget state, not a route - see main.dart's own comment on why there's
/// no router yet), so switching pages never rebuilds this shell itself. The
/// header always shows the *current* page's own label (see _Header) - that
/// is the "remembers which page you're on" part, kept in sync automatically
/// since both the header and the page body read the same `_selected` index.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;
  // Narrows _SideNav to an icon rail - useful on a tablet, where the wide
  // layout kicks in (see _kWideBreakpoint) but a 260px side nav still eats
  // a chunk of a smaller tablet screen's width. Plain widget state (not
  // persisted) - same "just a toggle" scope as wps's own, minus the
  // localStorage carry-over, which nothing here has asked for yet.
  bool _collapsed = false;

  void _select(int index) => setState(() => _selected = index);
  void _toggleCollapsed() => setState(() => _collapsed = !_collapsed);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.nav;
    // Built per-build (not static const) since the labels come from context.t
    // and must follow the current locale (see core/session/locale_providers.dart).
    final items = [
      _NavEntry(LucideIcons.truck, t.orders, const OrdersPage()),
      _NavEntry(LucideIcons.history, t.history, const HistoryPage()),
      _NavEntry(LucideIcons.user, t.account, const AccountPage()),
    ];
    final wide = MediaQuery.sizeOf(context).width >= _kWideBreakpoint;

    final header = _Header(title: items[_selected].label);
    final page = items[_selected].page;

    return ColoredBox(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: wide
            ? Row(
                children: [
                  _SideNav(
                    items: items,
                    selected: _selected,
                    onSelect: _select,
                    collapsed: _collapsed,
                    onToggleCollapsed: _toggleCollapsed,
                  ),
                  Expanded(
                    child: Column(children: [header, Expanded(child: page)]),
                  ),
                ],
              )
            : Column(
                children: [
                  header,
                  Expanded(child: page),
                  _BottomNav(items: items, selected: _selected, onSelect: _select),
                ],
              ),
      ),
    );
  }
}

/// Same header on both layouts - just the current page's label, big and
/// bold like wps's own dashboard header (app/dashboard/layout.js).
class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.h2.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tablet/desktop: an always-visible column down the left, wps's own
/// sidebar design (app/dashboard/layout.js) - the SV badge + app name up
/// top, then the nav list, then the collapse toggle at the bottom (same
/// place wps puts "Zwiń nawigację"). Collapsed, this narrows to a 72px
/// icon rail - the badge/app name and every row's label disappear, same
/// as wps's own collapsed state.
class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapsed,
  });
  final List<_NavEntry> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.nav;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: collapsed ? 72 : 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'SV',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.primaryForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Text('smVendor', style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < items.length; i++)
            _SideNavRow(entry: items[i], active: i == selected, collapsed: collapsed, onTap: () => onSelect(i)),
          const Spacer(),
          _SideNavRow(
            entry: _NavEntry(
              collapsed ? LucideIcons.panelLeftOpen : LucideIcons.panelLeftClose,
              collapsed ? t.expand : t.collapse,
              const SizedBox.shrink(),
            ),
            active: false,
            collapsed: collapsed,
            onTap: onToggleCollapsed,
          ),
        ],
      ),
    );
  }
}

class _SideNavRow extends StatelessWidget {
  const _SideNavRow({required this.entry, required this.active, required this.collapsed, required this.onTap});
  final _NavEntry entry;
  final bool active;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final color = active ? theme.colorScheme.primary : theme.colorScheme.mutedForeground;
    final row = Container(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12, vertical: 12),
      decoration: BoxDecoration(
        color: active ? theme.colorScheme.accent : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(entry.icon, size: 20, color: color),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Text(
              entry.label,
              style: theme.textTheme.p.copyWith(color: color, fontWeight: active ? FontWeight.w600 : FontWeight.w500),
            ),
          ],
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: row),
    );
  }
}

/// Phone: a bottom tab bar - same shape as smpda's own dashboard bottom bar
/// (dashboard_screen.dart's _TabButton), just generalized to however many
/// nav entries this shell has instead of a fixed Moduły/Konto pair.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.items, required this.selected, required this.onSelect});
  final List<_NavEntry> items;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.colorScheme.border))),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            _BottomNavButton(entry: items[i], active: i == selected, onTap: () => onSelect(i)),
        ],
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({required this.entry, required this.active, required this.onTap});
  final _NavEntry entry;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final color = active ? theme.colorScheme.primary : theme.colorScheme.mutedForeground;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(entry.icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(entry.label, style: theme.textTheme.small.copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
