import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// wpsApi's own address - hardcoded for now (no settings screen yet, unlike
/// smpda's own apiBaseUrl field). Same LAN address the rest of this app
/// family (wps, smpda) already points at during development.
const _apiBaseUrl = 'http://10.96.12.204:4000/api';

/// Plain, unauthenticated Dio instance - only /auth/login needs this so far
/// (see wpsApi's AGENTS.md: unlike every other route, login doesn't need the
/// shared bearer apiToken). A token-carrying instance for the rest of the
/// API can be added once smVendor has something past the login screen to
/// call it for.
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: _apiBaseUrl, connectTimeout: const Duration(seconds: 15)));
});
