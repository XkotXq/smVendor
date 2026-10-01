// Smoke tests - check the app boots to the login screen, and that AppShell
// picks the right nav shape at each breakpoint (see widgets/app_shell.dart).
// Replace/extend once there's real behaviour worth testing.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:smvendor/i18n/gen/strings.g.dart';
import 'package:smvendor/main.dart';
import 'package:smvendor/theme/app_theme.dart';
import 'package:smvendor/widgets/app_shell.dart';

void main() {
  testWidgets('App boots to the login screen', (WidgetTester tester) async {
    // Both ProviderScope (SmVendorApp/LoginScreen read riverpod state) and
    // TranslationProvider (they now read context.t - see
    // core/session/locale_providers.dart, i18n/) are needed here the same
    // way main.dart wires them for the real app.
    await tester.pumpWidget(TranslationProvider(child: const ProviderScope(child: SmVendorApp())));
    await tester.pumpAndSettle();

    // Both the title and the submit button say "Zaloguj się" (same as
    // wps's own login page), so this checks the subtitle instead - unique,
    // and only rendered once the screen (and its Satoshi font) actually built.
    expect(find.text('smVendor - panel logowania'), findsOneWidget);
  });

  // The officially recommended way to test a responsive layout - resizing
  // the test binding's own view, not just wrapping a MediaQuery around
  // ShadApp (which builds its own navigator/overlay and isn't guaranteed to
  // pass an ancestor MediaQuery straight through unchanged).
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(child: ShadApp(theme: AppTheme.light, home: const AppShell())),
      ),
    );
    await tester.pumpAndSettle();
  }

  // "Pulpit" itself isn't a useful assertion either way - the header always
  // repeats the *current* page's own label (that's the whole point being
  // tested elsewhere below), so it's already 2 matches (header + whichever
  // nav) on both layouts at the default selection. "Konto" is never the
  // header's text at that point, so it alone tells the two layouts apart:
  // exactly one match if it's only in the nav, more if the nav shows a
  // brand name (side nav) that the bottom nav doesn't.
  testWidgets('Phone width shows the bottom nav, not the side nav', (tester) async {
    await pumpAt(tester, const Size(390, 844)); // a phone

    expect(find.text('smVendor'), findsNothing); // only the side nav shows this
    expect(find.text('Konto'), findsOneWidget); // bottom nav's own label
  });

  testWidgets('Tablet width shows the side nav, not the bottom nav', (tester) async {
    await pumpAt(tester, const Size(1024, 768)); // a tablet

    expect(find.text('smVendor'), findsOneWidget); // side nav's own brand row
    expect(find.text('Konto'), findsOneWidget); // side nav's own entry
  });

  testWidgets('Tapping a nav entry switches the header title', (tester) async {
    await pumpAt(tester, const Size(390, 844));

    expect(find.text('Wyloguj'), findsNothing);
    await tester.tap(find.text('Konto'));
    await tester.pumpAndSettle();
    expect(find.text('Wyloguj'), findsOneWidget); // AccountPage's own content
  });
}
