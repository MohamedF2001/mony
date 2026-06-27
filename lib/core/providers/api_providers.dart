import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/token_service.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  //const baseUrl = 'http://10.0.2.2:3000';
  //const baseUrl = 'http://localhost:3000/';
  //const baseUrl = 'http://192.168.0.189:3000/';
  //const baseUrl = 'http://10.0.2.2:3000/';
  const baseUrl = 'https://mony-api.vercel.app/';
  return ApiClient(baseUrl: baseUrl, tokenService: tokenService);
});
