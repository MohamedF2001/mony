// lib/core/providers/api_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/token_service.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  const baseUrl = 'https://mony-api.vercel.app/';
  return ApiClient(baseUrl: baseUrl, tokenService: tokenService);
});
