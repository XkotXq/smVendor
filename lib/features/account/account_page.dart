import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/device_label_providers.dart';
import '../../core/session/locale_providers.dart';
import '../../core/session/session_providers.dart';
import '../../core/session/theme_providers.dart';
import '../../i18n/gen/strings.g.dart';

/// "Konto" - who's signed in and the way out. Same placement as smpda's own
/// Konto tab (dashboard_screen.dart's _AccountView) - logout lives here, not
/// as a persistent element in the side nav/bottom nav themselves, so both
/// layouts (see widgets/app_shell.dart) only have it in one place.
///
/// Also the only place the PL/EN switch (see core/session/locale_providers.dart),
/// the theme picker (see core/session/theme_providers.dart) and this
/// device's own "Oznaczenie wózka" (see core/session/device_label_providers.dart)
/// live - there's no separate settings page yet, and this is the one screen
/// every user visits regardless of role.
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _deviceLabelController = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _deviceLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final t = context.t.account;
    final session = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider).value ?? AppLocale.pl;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final deviceLabel = ref.watch(deviceLabelProvider).value ?? '';
    if (!_hydrated) {
      _deviceLabelController.text = deviceLabel;
      _hydrated = true;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (session != null) ...[
              Text(session.name, style: theme.textTheme.h4, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(session.userId, style: theme.textTheme.muted, textAlign: TextAlign.center),
              const SizedBox(height: 32),
            ],
            Text(t.language, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LocaleOption(
                  label: t.languagePolish,
                  selected: locale == AppLocale.pl,
                  onTap: () => ref.read(localeProvider.notifier).setLocale(AppLocale.pl),
                ),
                const SizedBox(width: 12),
                _LocaleOption(
                  label: t.languageEnglish,
                  selected: locale == AppLocale.en,
                  onTap: () => ref.read(localeProvider.notifier).setLocale(AppLocale.en),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(t.theme, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LocaleOption(
                  label: t.themeSystem,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                ),
                const SizedBox(width: 12),
                _LocaleOption(
                  label: t.themeLight,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 12),
                _LocaleOption(
                  label: t.themeDark,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // This device's own forklift label - set once per device (like
            // the language above), sent on every login so wps's "Historia
            // logowania" can show which wózek a login happened on.
            Align(
              alignment: Alignment.centerLeft,
              child: Text(t.deviceLabel, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(t.deviceLabelHint, style: theme.textTheme.muted.copyWith(fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ShadInput(controller: _deviceLabelController, placeholder: const Text('Wózek 3')),
                ),
                const SizedBox(width: 8),
                ShadButton.outline(
                  onPressed: () => ref.read(deviceLabelProvider.notifier).setDeviceLabel(_deviceLabelController.text.trim()),
                  child: Text(t.save),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ShadButton.outline(
                onPressed: () => ref.read(sessionProvider.notifier).logout(),
                child: Text(t.logout, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One option pill - filled when it's the active choice, same active/inactive
/// colour split as widgets/app_shell.dart's own nav rows (accent background,
/// primary vs. mutedForeground text) so this reads as "selected" the same way
/// the rest of the app already does. Used for both the PL/EN switch and the
/// theme picker above - despite the name, it's generic (label/selected/onTap).
class _LocaleOption extends StatelessWidget {
  const _LocaleOption({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.accent : null,
          border: Border.all(color: selected ? theme.colorScheme.primary : theme.colorScheme.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: theme.textTheme.p.copyWith(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
