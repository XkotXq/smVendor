import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
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
      home: const _AboveKeyboard(child: _SystemBars(child: LoginScreen())),
    );
  }
}

/// Makes the Android status bar and navigation bar usable on both themes:
/// their icons and the clock are drawn by the system in whatever contrast
/// the app asks for, and an app that asks for nothing gets light icons -
/// invisible on this app's light background.
///
/// Reads the **resolved** brightness from ShadTheme rather than the chosen
/// ThemeMode, so "system" lands on the right one, and sits inside ShadApp so
/// it covers every route pushed later (the shell, every order page).
/// AnnotatedRegion rather than SystemChrome.setSystemUIOverlayStyle: it
/// follows the widget tree instead of being a one-off side effect that a
/// later route or a theme switch could leave stale.
class _SystemBars extends StatelessWidget {
  const _SystemBars({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = ShadTheme.of(context).brightness == Brightness.dark;
    final icons = dark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0x00000000),
        statusBarIconBrightness: icons,
        // iOS words it the other way round - this is the brightness of the
        // bar, not of what is drawn on it.
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: ShadTheme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness: icons,
      ),
      child: child,
    );
  }
}

/// Shrinks the app to the space above the on-screen keyboard instead of
/// letting the keyboard cover it.
///
/// Android is already told to resize for the keyboard
/// (`windowSoftInputMode="adjustResize"` in AndroidManifest.xml), but that
/// only makes it *report* the inset: Flutter keeps the window its full size
/// and raises `MediaQuery.viewInsets.bottom`. Material's Scaffold is what
/// normally turns that into padding - and these apps have no Scaffold
/// (shadcn_ui on package:flutter/widgets.dart), so without this the
/// keyboard simply sat on top of the layout, hiding whatever was at the
/// bottom: the send button in the chat, "Dostarczone", the problem footer.
///
/// Sits inside ShadApp, so it covers every route pushed later as well.
/// `removeViewInsets` strips the inset for everything below, or widgets that
/// handle it themselves (a scrolling field, a SafeArea) would count it a
/// second time and leave a gap the height of the keyboard.
class _AboveKeyboard extends StatelessWidget {
  const _AboveKeyboard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}
