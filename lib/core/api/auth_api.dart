import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Result of a successful CIP login - mirrors wpsApi's own
/// POST /api/auth/login response shape (src/routes/auth.js), same as
/// ../smpda's own AuthApi. Only what this screen needs so far (token +
/// display name); refresh/authorities can be added once something past the
/// login screen needs them.
class AuthSession {
  const AuthSession({required this.token, required this.name, required this.userId});

  final String token;

  /// Display name (wpsApi's `name` - CIP's own `user_info.employee`,
  /// falling back to whatever username was typed).
  final String name;

  /// CIP username (wpsApi's `userId`) - the employee number.
  final String userId;
}

/// A failed login. [code] is wpsApi's stable error code (invalid_credentials,
/// cip_unreachable, too_many_attempts, ...) - LoginScreen turns it into a
/// message in Polish, since CIP's own text is Chinese. Null when the server
/// couldn't be reached at all.
class AuthFailure implements Exception {
  AuthFailure(this.code, this.message);
  final String? code;

  /// wpsApi's Polish fallback message, for a code this app doesn't know.
  final String message;

  @override
  String toString() => message;
}

/// POST /api/auth/login - proxies the company's legacy CIP system's OAuth2
/// password grant (see wpsApi's src/routes/auth.js). Doesn't need the
/// shared bearer apiToken, unlike every other wpsApi route.
class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  /// Throws an [AuthFailure] - LoginScreen shows its `code` in Polish
  /// rather than the server's own text.
  ///
  /// [deviceLabel]: this device's own "Wózek N" setting (see
  /// core/session/device_label_providers.dart, set once per device on
  /// AccountPage) - wpsApi logs a login_events row for wps's "Historia
  /// logowania" whenever it's non-blank (see its own routes/auth.js), and
  /// skips logging entirely for a device that was never labeled.
  Future<AuthSession> login(String username, String password, {String? deviceLabel}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          if (deviceLabel != null && deviceLabel.isNotEmpty) 'deviceLabel': deviceLabel,
        },
      );
      final data = res.data!;
      return AuthSession(
        token: data['token'] as String,
        name: data['name'] as String? ?? username,
        userId: data['userId'] as String? ?? username,
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final serverMessage = body is Map ? body['error'] as String? : null;
      final code = body is Map ? body['code'] as String? : null;
      throw AuthFailure(code, serverMessage ?? 'Nie udało się połączyć z serwerem.');
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioProvider)));
