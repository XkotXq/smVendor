import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'features/auth/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SmVendorApp()));
}

/// Root widget - theme/darkTheme mirror wps's own light/dark tokens (see
/// theme/app_theme.dart, copied from ../smpda's own - both mirror wps's
/// app/globals.css). No router yet (see login_screen.dart's own plain
/// Navigator.push to widgets/app_shell.dart's AppShell, which owns which
/// nav entry is selected as plain widget state) - added once there's more
/// to navigate between than what fits in one shell.
class SmVendorApp extends StatelessWidget {
  const SmVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'smVendor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
