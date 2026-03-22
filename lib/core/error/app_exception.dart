class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  factory AppException.general(String message) =>
      AppException(message: message, code: 'GENERAL_ERROR');

  factory AppException.unauthorized() => const AppException(
      message: 'Session expired. Please login again.', code: 'UNAUTHORIZED');

  factory AppException.noInternet() => const AppException(
      message: 'No internet connection.', code: 'NO_INTERNET');

  factory AppException.networkTimeout() => const AppException(
      message: 'Request timed out. Please try again.', code: 'TIMEOUT');

  factory AppException.notFound(String message) =>
      AppException(message: message, code: 'NOT_FOUND');

  factory AppException.serverError(String message) =>
      AppException(message: message, code: 'SERVER_ERROR');

  @override
  String toString() => 'AppException[$code]: $message';
}
