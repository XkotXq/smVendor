import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/session/session_providers.dart';

/// "Pulpit" - the first tab/nav entry (see widgets/app_shell.dart). Nothing
/// built past a welcome message yet; real content lands here as it's built.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

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
            Text('Witaj w smVendor', style: theme.textTheme.h3, textAlign: TextAlign.center),
            if (session != null) ...[
              const SizedBox(height: 8),
              Text(session.name, style: theme.textTheme.muted, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
