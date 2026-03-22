import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('──── REQUEST ────────────────────');
    debugPrint('[${options.method}] ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) debugPrint('Body: ${options.data}');
    debugPrint('─────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('──── RESPONSE ───────────────────');
    debugPrint('[${response.requestOptions.method}] ${response.requestOptions.uri}');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Data: ${response.data}');
    debugPrint('─────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      debugPrint('──── ERROR ──────────────────────');
      debugPrint('[${err.requestOptions.method}] ${err.requestOptions.uri}');
      debugPrint('Type: ${err.type}');
      debugPrint('Message: ${err.message}');
      debugPrint('Error: ${err.error}');
      if (err.response != null) {
        debugPrint('Status: ${err.response?.statusCode}');
        debugPrint('Response: ${err.response?.data}');
      } else {
        debugPrint('No response received - possible network issue');
      }
      debugPrint('─────────────────────────────────');
    } catch (e) {
      debugPrint('Error in logging interceptor: $e');
    }
    handler.next(err);
  }
}
