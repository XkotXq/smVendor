import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'smvendor.themeMode';

/// The chosen theme (system/light/dark), persisted across restarts - same
/// idea as locale_providers.dart's own LocaleNotifier, in its own small
/// provider since smVendor has no shared "app settings" state yet (see
/// that file's own comment on why). Defaults to system, same as main.dart's
/// own previous hardcoded `ThemeMode.system`.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    // ThemeMode.name is "system"/"light"/"dark" - the same strings read back
    // in build() above, so this needs no separate encode/decode map.
    await prefs.setString(_themeModeKey, mode.name);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
