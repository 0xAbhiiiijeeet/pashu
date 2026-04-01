import 'package:dio/dio.dart';
import '../../storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  static const Set<String> _publicAuthPaths = {
    '/api/auth/send-otp',
    '/api/auth/verify-otp',
    '/api/auth/verify-firebase-token',
  };

  AuthInterceptor(this._storageService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_publicAuthPaths.contains(options.path)) {
      options.headers.remove('Authorization');
      handler.next(options);
      return;
    }

    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
