import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/session_providers.dart';

/// "Konto" - who's signed in and the way out. Same placement as smpda's own
/// Konto tab (dashboard_screen.dart's _AccountView) - logout lives here, not
/// as a persistent element in the side nav/bottom nav themselves, so both
/// layouts (see widgets/app_shell.dart) only have it in one place.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final session = ref.watch(sessionProvider);
    return Center(
      child: Padding(
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
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ShadButton.outline(
                onPressed: () => ref.read(sessionProvider.notifier).logout(),
                child: const Text('Wyloguj', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
