import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../i18n/gen/strings.g.dart';

const _localeKey = 'smvendor.localeCode';

/// The chosen language (pl/en), persisted across restarts - same idea as
/// ../smpda's own AppSettings.localeCode, in its own small provider since
/// smVendor has no shared "app settings" state yet (see session_providers.dart's
/// own comment on why there's no persistence there either, still true).
/// Defaults to Polish - slang.yaml's own base_locale, this app family's
/// primary language - rather than the device's own locale, same default
/// smpda's settings screen falls back to.
class LocaleNotifier extends AsyncNotifier<AppLocale> {
  @override
  Future<AppLocale> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) == 'en' ? AppLocale.en : AppLocale.pl;
  }

  Future<void> setLocale(AppLocale locale) async {
    state = AsyncData(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, AppLocale>(LocaleNotifier.new);
