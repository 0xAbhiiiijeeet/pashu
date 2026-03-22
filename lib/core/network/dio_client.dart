import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../storage/storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  DioClient._();

  static DioClient? _instance;
  static DioClient get instance => _instance ??= DioClient._();

  late final Dio _dio;

  Dio get dio => _dio;

  void init(StorageService storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to prevent Dio from throwing on non-200
          return status != null && status < 500;
        },
        followRedirects: false, // Disable redirects to avoid issues
        maxRedirects: 0,
        contentType: 'application/json; charset=utf-8',
        responseType: ResponseType.json, // Explicitly set response type
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(storageService),
      ErrorInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
    ]);
  }

  // ── GET ──────────────────────────────────────────────────────────────────
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ── POST ─────────────────────────────────────────────────────────────────
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ── PUT ──────────────────────────────────────────────────────────────────
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ── MULTIPART ────────────────────────────────────────────────────────────
  Future<Response> uploadFile(
    String endpoint, {
    required FormData formData,
  }) async {
    return _dio.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
