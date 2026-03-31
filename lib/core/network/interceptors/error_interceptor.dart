import 'package:dio/dio.dart';
import '../../error/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check for type conversion errors that might happen during response parsing
    if (err.error != null && err.error.toString().contains("type 'String' is not a subtype of type 'int'")) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: AppException.general('Server response format error'),
          type: DioExceptionType.unknown,
          response: err.response,
        ),
      );
      return;
    }

    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = AppException.networkTimeout();
        break;

      case DioExceptionType.connectionError:
        appException = AppException.noInternet();
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractMessage(err.response?.data);

        if (statusCode == 401) {
          appException = AppException.unauthorized();
        } else if (statusCode == 404) {
          appException = AppException.notFound(message);
        } else if (statusCode != null && statusCode >= 500) {
          appException = AppException.serverError(message);
        } else {
          appException = AppException.general(message);
        }
        break;

      default:
        appException = AppException.general(err.message ?? 'Unexpected error');
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message != null) return message.toString();
      return 'Unknown error';
    }

    if (data is Map) {
      final message = data['message'];
      if (message != null) return message.toString();
      return 'Unknown error';
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return 'Unknown error';
  }
}
