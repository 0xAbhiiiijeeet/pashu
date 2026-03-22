import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/cow_sale_model.dart';

class MarketplaceRemoteDataSource {
  final Dio _dio;

  MarketplaceRemoteDataSource(this._dio);

  /// Upload cow images and return URLs
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    debugPrint('🌐 [API] POST ${ApiEndpoints.cowSaleImages}');
    debugPrint('📤 [API] Uploading ${imagePaths.length} images');

    final formData = FormData();

    for (int i = 0; i < imagePaths.length; i++) {
      final fileName = imagePaths[i].split('/').last;
      debugPrint('   Adding image ${i + 1}: $fileName');

      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            imagePaths[i],
            filename: fileName,
          ),
        ),
      );
    }

    final response = await _dio.post(
      ApiEndpoints.cowSaleImages,
      data: formData,
    );

    debugPrint('📥 [API] Response Status: ${response.statusCode}');
    debugPrint('📥 [API] Response Data: ${response.data}');

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final responseMap = response.data as Map<String, dynamic>;

    // Check success flag
    if (responseMap['success'] != true) {
      throw Exception(responseMap['message'] ?? 'Failed to upload images');
    }

    final urls = List<String>.from(responseMap['urls'] ?? []);

    debugPrint('✅ [API] Received ${urls.length} image URLs');
    return urls;
  }

  /// Create a new cow sale request
  Future<CowSaleModel> createCowSale(CowDetails cowDetails) async {
    debugPrint('🌐 [API] POST ${ApiEndpoints.cowSales}');
    debugPrint('📤 [API] Request Body: ${{'cowDetails': cowDetails.toJson()}}');

    final response = await _dio.post(
      ApiEndpoints.cowSales,
      data: {'cowDetails': cowDetails.toJson()},
    );

    debugPrint('📥 [API] Response Status: ${response.statusCode}');
    debugPrint('📥 [API] Response Data: ${response.data}');

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final responseMap = response.data as Map<String, dynamic>;

    if (responseMap['success'] != true) {
      throw Exception(responseMap['message'] ?? 'Failed to create cow sale');
    }

    final data = responseMap['data'] as Map<String, dynamic>;
    return CowSaleModel.fromJson(data);
  }

  /// Get user's own cow sales
  Future<List<CowSaleModel>> getMySales() async {
    try {
      debugPrint('🌐 [API] GET ${ApiEndpoints.myCowSales}');

      final response = await _dio.get(ApiEndpoints.myCowSales);

      debugPrint('📥 [API] Response Status: ${response.statusCode}');
      debugPrint('📥 [API] Response Data: ${response.data}');

      if (response.data == null) return [];
      if (response.data is! Map<String, dynamic>) return [];

      final responseMap = response.data as Map<String, dynamic>;
      if (responseMap['success'] != true) return [];

      final dynamic data = responseMap['data'];
      if (data is! List) return [];

      return data.map((json) => CowSaleModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('💥 [API] Get my sales request failed: $e');
      return [];
    }
  }

  /// Get all approved cow sales (marketplace)
  Future<List<CowSaleModel>> getApprovedSales() async {
    try {
      debugPrint('🌐 [API] GET ${ApiEndpoints.cowSales}');

      final response = await _dio.get(ApiEndpoints.cowSales);

      debugPrint('📥 [API] Response Status: ${response.statusCode}');
      debugPrint('📥 [API] Response Data: ${response.data}');

      if (response.data == null) return [];
      if (response.data is! Map<String, dynamic>) return [];

      final responseMap = response.data as Map<String, dynamic>;
      if (responseMap['success'] != true) return [];

      final dynamic data = responseMap['data'];
      if (data is! List) return [];

      return data.map((json) => CowSaleModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('💥 [API] Get approved sales request failed: $e');
      return [];
    }
  }
}
