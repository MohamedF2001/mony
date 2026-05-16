import 'package:dio/dio.dart';
import 'token_service.dart';

class ApiClient {
  final Dio _dio;
  final TokenService _tokenService;

  ApiClient({
    required String baseUrl,
    required TokenService tokenService,
  })  : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        )),
        _tokenService = tokenService {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle token expiration or unauthorized access
          }
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
