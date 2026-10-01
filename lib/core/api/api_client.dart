import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// wpsApi's own address - hardcoded for now (no settings screen yet, unlike
/// smpda's own apiBaseUrl field). Same LAN address the rest of this app
/// family (wps, smpda) already points at during development.
const _apiBaseUrl = 'http://10.96.12.204:4000/api';

/// Plain, unauthenticated Dio instance - only /auth/login needs this (see
/// wpsApi's AGENTS.md: unlike every other route, login doesn't need the
/// shared bearer apiToken).
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: _apiBaseUrl, connectTimeout: const Duration(seconds: 15)));
});

/// Every other wpsApi route (see AGENTS.md's "Auth") needs the shared bearer
/// token - same one wps's lib/smCatalogApi.js sends and smpda's own settings
/// screen lets an operator type in. smVendor has no settings screen yet, so
/// rather than hardcode the real secret into this source file (it's
/// committed to GitHub - see AGENTS.md's push), it's read from a compile-time
/// define instead: pass `--dart-define=API_TOKEN=...` to `flutter run`/
/// `flutter build`. Empty (no header sent) when omitted, same as wps's own
/// `apiFetch` when NEXT_PUBLIC_API_TOKEN is unset.
const _apiToken = String.fromEnvironment('API_TOKEN');

final authedDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: _apiBaseUrl, connectTimeout: const Duration(seconds: 15)));
  if (_apiToken.isNotEmpty) {
    dio.options.headers['Authorization'] = 'Bearer $_apiToken';
  }
  return dio;
});
