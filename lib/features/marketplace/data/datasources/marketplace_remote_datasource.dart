import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/cow_sale_model.dart';

class MarketplaceRemoteDataSource {
  final Dio _dio;

  MarketplaceRemoteDataSource(this._dio);

  Future<List<String>> uploadImages(List<String> imagePaths) async {
    debugPrint('[API] POST ${ApiEndpoints.cowSaleImages}');
    debugPrint('[API] Uploading ${imagePaths.length} images');

    final formData = FormData();

    for (final imagePath in imagePaths) {
      final fileName = imagePath.split('/').last;
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ),
      );
    }

    final response = await _dio.post(
      ApiEndpoints.cowSaleImages,
      data: formData,
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final responseMap = response.data as Map<String, dynamic>;
    if (responseMap['success'] != true) {
      throw Exception(responseMap['message'] ?? 'Failed to upload images');
    }

    return List<String>.from(responseMap['urls'] ?? []);
  }

  Future<CowSaleModel> createCowSale(CowDetails cowDetails) async {
    final response = await _dio.post(
      ApiEndpoints.cowSales,
      data: {'cowDetails': cowDetails.toJson()},
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final responseMap = response.data as Map<String, dynamic>;
    if (responseMap['success'] != true) {
      throw Exception(responseMap['message'] ?? 'Failed to create cow sale');
    }

    return CowSaleModel.fromJson(responseMap['data'] as Map<String, dynamic>);
  }

  Future<List<CowSaleModel>> getMySales() async {
    return _readSalesList(ApiEndpoints.myCowSales);
  }

  Future<List<CowSaleModel>> getApprovedSales() async {
    return _readSalesList(ApiEndpoints.cowSales);
  }

  Future<List<CowSaleModel>> getAllSalesForAdmin() async {
    return _readSalesList(ApiEndpoints.adminCowSales);
  }

  Future<CowSaleModel> updateSaleStatus({
    required String saleId,
    required String status,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.adminCowSaleStatus(saleId),
      data: {'status': status},
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format from server');
    }

    final responseMap = response.data as Map<String, dynamic>;
    return CowSaleModel.fromJson(responseMap['data'] as Map<String, dynamic>);
  }

  Future<List<CowSaleModel>> _readSalesList(String path) async {
    try {
      final response = await _dio.get(path);
      if (response.data is! Map<String, dynamic>) return [];

      final responseMap = response.data as Map<String, dynamic>;
      final dynamic data = responseMap['data'];
      if (data is! List) return [];

      return data
          .map((json) => CowSaleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[API] Sales request failed for $path: $e');
      return [];
    }
  }
}
