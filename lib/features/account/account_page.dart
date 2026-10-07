import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/locale_providers.dart';
import '../../core/session/session_providers.dart';
import '../../core/session/theme_providers.dart';
import '../../i18n/gen/strings.g.dart';
import '../../widgets/option_chip.dart';
import '../auth/login_screen.dart';

/// "Konto" - who is signed in, the two settings this app has, and the way
/// out.
///
/// Laid out the way wps lays out a settings panel: an identity block, then
/// the settings in **one** bordered card with a label above each control
/// and a hairline between groups, then the destructive action on its own
/// below it. What was here before was three centred groups floating 32px
/// apart with no container at all, which read as an unfinished screen - and
/// its own pill control was a fifth near-copy of a chip this app already
/// had four of (see widgets/option_chip.dart).
///
/// Everything here is **per device, not per person** (see the locale and
/// theme providers): the phone belongs to a shift.

/// Clearing the session is not enough on its own: nothing in this app
/// watches it to decide what to show (login pushes the shell and that is
/// the whole of the routing - see features/auth/login_screen.dart), so
/// without replacing the stack here "Wyloguj" left the operator inside the
/// app with no session, every request going out with an empty viewer.
/// pushAndRemoveUntil drops the shell and this page with it, so Back cannot
/// return to a signed-out queue either.
void _logout(BuildContext context, WidgetRef ref) {
  final navigator = Navigator.of(context);
  ref.read(sessionProvider.notifier).logout();
  navigator.pushAndRemoveUntil(
    PageRouteBuilder(pageBuilder: (context, _, _) => const LoginScreen()),
    (route) => false,
  );
}

/// Up to two initials, for the monogram. A name this app cannot read falls
/// back to a person glyph rather than to a stray letter.
String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  final letters = parts.take(2).map((p) => p.characters.first.toUpperCase());
  return letters.join();
}

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final t = context.t.account;
    final session = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider).value ?? AppLocale.pl;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final initials = _initials(session?.name ?? '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        if (session != null)
          Row(
            children: [
              // A monogram rather than an avatar: there is no photo to show
              // and a grey circle with a person icon in it would be a
              // placeholder pretending to be content.
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: initials.isEmpty
                    ? Icon(LucideIcons.user, size: 24, color: theme.colorScheme.primaryForeground)
                    : Text(
                        initials,
                        style: theme.textTheme.h4.copyWith(
                          color: theme.colorScheme.primaryForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.name,
                      style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(session.userId, style: theme.textTheme.muted),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),

        // One card for both settings - they are the same kind of thing and
        // two cards would have made that a question.
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingLabel(t.language),
              const SizedBox(height: 10),
              Row(
                children: [
                  OptionChip(
                    expand: true,
                    label: t.languagePolish,
                    selected: locale == AppLocale.pl,
                    onTap: () => ref.read(localeProvider.notifier).setLocale(AppLocale.pl),
                  ),
                  const SizedBox(width: 10),
                  OptionChip(
                    expand: true,
                    label: t.languageEnglish,
                    selected: locale == AppLocale.en,
                    onTap: () => ref.read(localeProvider.notifier).setLocale(AppLocale.en),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(height: 1, color: theme.colorScheme.border),
              ),
              _SettingLabel(t.theme),
              const SizedBox(height: 10),
              Row(
                children: [
                  OptionChip(
                    expand: true,
                    icon: LucideIcons.smartphone,
                    label: t.themeSystem,
                    selected: themeMode == ThemeMode.system,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                  ),
                  const SizedBox(width: 8),
                  OptionChip(
                    expand: true,
                    icon: LucideIcons.sun,
                    label: t.themeLight,
                    selected: themeMode == ThemeMode.light,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 8),
                  OptionChip(
                    expand: true,
                    icon: LucideIcons.moon,
                    label: t.themeDark,
                    selected: themeMode == ThemeMode.dark,
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
        // Outside the card and in the destructive colour: it is the one
        // control here that ends something rather than setting it.
        SizedBox(
          height: 52,
          child: ShadButton.outline(
            onPressed: () => _logout(context, ref),
            leading: Icon(LucideIcons.logOut, size: 18, color: theme.colorScheme.destructive),
            child: Text(
              t.logout,
              style: theme.textTheme.p.copyWith(
                color: theme.colorScheme.destructive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Text(
      text,
      style: theme.textTheme.small.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.mutedForeground,
      ),
    );
  }
}
