import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/auth_api.dart';

/// Who's logged in right now - in-memory only for this first cut (no
/// SharedPreferences persistence yet, unlike ../smpda's own AppSettings), so
/// a killed/restarted app goes back to the login screen. Add persistence
/// once there is more than a login screen worth keeping signed into.
class SessionNotifier extends Notifier<AuthSession?> {
  @override
  AuthSession? build() => null;

  void setSession(AuthSession session) => state = session;
  void logout() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, AuthSession?>(SessionNotifier.new);
