import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/customer_model.dart';
import '../../domain/models/milk_entry_model.dart';

class MilkRemoteDataSource {
  MilkRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Customer>> getCustomers() async {
    final response = await _dio.get(ApiEndpoints.milkCustomers);
    final responseMap = _asMap(response.data);
    final data = responseMap?['data'];
    if (data is! List) return [];
    return data
        .map((json) => Customer.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Customer> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String milkTypePreference,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.milkCustomers,
      data: {
        'name': name,
        'phone': phone,
        'address': address,
        'milkTypePreference': milkTypePreference,
      },
    );

    final responseMap = _asMap(response.data);
    final payload = responseMap?['data'] ?? responseMap?['customer'] ?? response.data;
    return Customer.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  Future<MilkEntry> addMilkRecord({
    required String customerId,
    required double quantity,
    required double pricePerLiter,
    required String milkType,
    required String shift,
    required DateTime date,
  }) async {
    final primaryPayload = _buildRecordPayload(
      customerId: customerId,
      quantity: quantity,
      pricePerLiter: pricePerLiter,
      milkType: milkType,
      shift: shift,
      date: date,
      lowercaseEnums: false,
    );

    try {
      final response = await _dio.post(
        ApiEndpoints.milkRecords,
        data: primaryPayload,
      );

      final responseMap = _asMap(response.data);
      final payload = responseMap?['data'] ?? response.data;
      return MilkEntry.fromJson(Map<String, dynamic>.from(payload as Map));
    } on DioException catch (e) {
      debugPrint('[Milk API] Primary addMilkRecord failed: ${e.response?.data}');

      final shouldRetry =
          e.type == DioExceptionType.badResponse &&
          (e.response?.statusCode == 400 ||
              e.response?.statusCode == 422 ||
              e.response?.statusCode == 500);

      if (!shouldRetry) rethrow;

      final fallbackPayload = _buildRecordPayload(
        customerId: customerId,
        quantity: quantity,
        pricePerLiter: pricePerLiter,
        milkType: milkType,
        shift: shift,
        date: date,
        lowercaseEnums: true,
      );

      debugPrint('[Milk API] Retrying addMilkRecord with fallback payload: $fallbackPayload');

      final response = await _dio.post(
        ApiEndpoints.milkRecords,
        data: fallbackPayload,
      );

      final responseMap = _asMap(response.data);
      final payload = responseMap?['data'] ?? response.data;
      return MilkEntry.fromJson(Map<String, dynamic>.from(payload as Map));
    }
  }

  Future<List<MilkEntry>> getMilkRecords({
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (customerId != null && customerId.isNotEmpty) {
      queryParameters['customerId'] = customerId;
    }
    if (startDate != null) {
      queryParameters['startDate'] = DateFormat('yyyy-MM-dd').format(startDate);
    }
    if (endDate != null) {
      queryParameters['endDate'] = DateFormat('yyyy-MM-dd').format(endDate);
    }

    final response = await _dio.get(
      ApiEndpoints.milkRecords,
      queryParameters: queryParameters,
    );

    final responseMap = _asMap(response.data);
    final data = responseMap?['data'];
    if (data is! List) return [];
    return data
        .map((json) => MilkEntry.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Map<String, dynamic>> getDailySummary() async {
    final response = await _dio.get(ApiEndpoints.milkSummary);
    final responseMap = _asMap(response.data);
    final data = responseMap?['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    debugPrint('[Milk API] Unexpected payload type: ${data.runtimeType}');
    return null;
  }

  Map<String, dynamic> _buildRecordPayload({
    required String customerId,
    required double quantity,
    required double pricePerLiter,
    required String milkType,
    required String shift,
    required DateTime date,
    required bool lowercaseEnums,
  }) {
    final normalizedMilkType =
        lowercaseEnums ? milkType.toLowerCase() : milkType;
    final normalizedShift = lowercaseEnums ? shift.toLowerCase() : shift;

    return {
      'customerId': customerId.toString(),
      'quantity': _normalizeNumber(quantity),
      'pricePerLiter': _normalizeNumber(pricePerLiter),
      'milkType': normalizedMilkType,
      'shift': normalizedShift,
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }

  num _normalizeNumber(double value) {
    return value % 1 == 0 ? value.toInt() : value;
  }
}
