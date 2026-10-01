import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/session/locale_providers.dart';
import 'core/session/theme_providers.dart';
import 'features/auth/login_screen.dart';
import 'i18n/gen/strings.g.dart';
import 'theme/app_theme.dart';

void main() {
  // TranslationProvider wraps everything so `context.t.someKey` works (see
  // ../smpda's own main.dart) - it must sit above ProviderScope's own child
  // since SmVendorApp (and every screen under it) reads context.t.
  runApp(TranslationProvider(child: const ProviderScope(child: SmVendorApp())));
}

/// Root widget - theme/darkTheme mirror wps's own light/dark tokens (see
/// theme/app_theme.dart, copied from ../smpda's own - both mirror wps's
/// app/globals.css). No router yet (see login_screen.dart's own plain
/// Navigator.push to widgets/app_shell.dart's AppShell, which owns which
/// nav entry is selected as plain widget state) - added once there's more
/// to navigate between than what fits in one shell.
///
/// Locale (PL/EN, see core/session/locale_providers.dart) is bridged into
/// slang's own LocaleSettings singleton here, same idea as ../smpda's own
/// app.dart - a plain equality check keeps this idempotent, since build()
/// re-running for an unrelated reason would otherwise call setLocale
/// needlessly. While the persisted choice is still loading (first launch,
/// before SharedPreferences answers), Polish is shown rather than blocking
/// on a loading screen - it's also slang.yaml's own base_locale, so nothing
/// extra needs bundling for it to render immediately.
///
/// Theme mode (system/light/dark, see core/session/theme_providers.dart) is
/// the account page's own "Motyw" picker - defaults to system the same way,
/// while its own persisted choice is still loading.
class SmVendorApp extends ConsumerWidget {
  const SmVendorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).value ?? AppLocale.pl;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    if (LocaleSettings.currentLocale != locale) {
      LocaleSettings.setLocale(locale);
    }
    return ShadApp(
      title: 'smVendor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale.flutterLocale,
      supportedLocales: AppLocale.values.map((l) => l.flutterLocale),
      home: const LoginScreen(),
    );
  }
}
