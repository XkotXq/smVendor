import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deviceLabelKey = 'smvendor.deviceLabel';

/// Which physical forklift ("wózek") this device is mounted in, e.g. "Wózek
/// 3" - set once per device (see AccountPage's own field), same
/// SharedPreferences-persisted, device-level lifetime as locale_providers.dart's
/// own LocaleNotifier (survives logout - there's no per-session state here
/// to clear it from, this app's own sessionProvider is in-memory only).
/// Sent as `deviceLabel` on every login (see AuthApi.login) so wpsApi's
/// login_events - "Historia logowania" in wps - can show which wózek a
/// login happened on. Blank means this device hasn't been labeled yet; a
/// login without one simply isn't logged there (see wpsApi's own
/// routes/auth.js) - smVendor is this app family's one forklift-facing
/// client for order fulfillment ("Rozpocznij realizację"/"Dostarczone"),
/// so this lives here, not in smpda (a general warehouse scanning tool,
/// not exclusively tied to one forklift).
class DeviceLabelNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceLabelKey) ?? '';
  }

  Future<void> setDeviceLabel(String value) async {
    state = AsyncData(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceLabelKey, value);
  }
}

final deviceLabelProvider = AsyncNotifierProvider<DeviceLabelNotifier, String>(DeviceLabelNotifier.new);
