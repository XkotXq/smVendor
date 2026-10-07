import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// wpsApi's own address. No settings screen here, unlike smpda's own
/// apiBaseUrl field, so this is a compile-time value.
/// Overridable at build time (`--dart-define=API_BASE_URL=...`), with the
/// development LAN address as the default so nothing changes for a local
/// `flutter run`. Deploying to a server would otherwise mean editing this
/// line in each app - see ../../../../deploy/README.md, which passes it from
/// deploy/.env.
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.96.12.204:4000/api',
);

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
