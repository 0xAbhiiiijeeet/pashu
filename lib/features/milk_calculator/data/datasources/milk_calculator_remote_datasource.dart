import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/milk_calculation_model.dart';

class MilkCalculatorRemoteDataSource {
  final Dio _dio;

  MilkCalculatorRemoteDataSource(this._dio);

  /// Calculate and save milk details
  Future<MilkCalculationModel> calculate(MilkCalculationInput input) async {
    try {
      debugPrint(
          '🌐 [API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.milkCalculate}');
      debugPrint('📤 [API] Request Body: ${input.toJson()}');

      final response = await _dio.post(
        ApiEndpoints.milkCalculate,
        data: input.toJson(),
      );

      debugPrint('📥 [API] Response Status: ${response.statusCode}');
      debugPrint('📥 [API] Response Data: ${response.data}');

      // Ensure we have a valid JSON response
      if (response.data is! Map<String, dynamic>) {
        debugPrint(
            '💥 [API] Invalid response format - expected JSON, got: ${response.data.runtimeType}');
        throw Exception('Invalid response format from server');
      }

      final responseMap = response.data as Map<String, dynamic>;

      // Check if response has the expected structure
      if (!responseMap.containsKey('data')) {
        debugPrint('💥 [API] Response missing "data" field');
        throw Exception('Invalid response structure from server');
      }

      final data = responseMap['data'] as Map<String, dynamic>;
      return MilkCalculationModel.fromJson(data);
    } catch (e) {
      debugPrint('💥 [API] Calculate request failed: $e');
      rethrow;
    }
  }

  /// Get calculation history
  Future<List<MilkCalculationModel>> getHistory() async {
    try {
      debugPrint('🌐 [API] GET ${ApiEndpoints.milkHistory}');

      final response = await _dio.get(ApiEndpoints.milkHistory);

      debugPrint('📥 [API] Response Status: ${response.statusCode}');
      debugPrint('📥 [API] Response Data: ${response.data}');

      if (response.data == null) return [];
      if (response.data is! Map<String, dynamic>) return [];

      final responseMap = response.data as Map<String, dynamic>;
      if (responseMap['success'] != true) return [];

      final List<dynamic> data = responseMap['data'] ?? [];
      return data.map((json) => MilkCalculationModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('💥 [API] Get history request failed: $e');
      return [];
    }
  }

  /// Delete calculation record
  Future<void> deleteCalculation(String id) async {
    final path = ApiEndpoints.milkCalculation(id);
    debugPrint('🌐 [API] DELETE $path');

    final response = await _dio.delete(path);

    debugPrint('📥 [API] Response Status: ${response.statusCode}');
    debugPrint('📥 [API] Response Data: ${response.data}');
  }
}
