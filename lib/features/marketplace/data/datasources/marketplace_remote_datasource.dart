import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/cow_sale_model.dart';

class MarketplaceRemoteDataSource {
  final Dio _dio;

  MarketplaceRemoteDataSource(this._dio);

  Future<CowSaleModel> createCowSale(
    CowDetails cowDetails, {
    List<String> imagePaths = const [],
  }) async {
    final formData = FormData();
    formData.fields.add(
      MapEntry('cowDetails', jsonEncode(_buildCowDetailsPayload(cowDetails))),
    );

    for (final imagePath in imagePaths) {
      final fileName = imagePath.split(RegExp(r'[\\/]')).last;
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ),
      );
    }

    final response = await _dio.post(
      ApiEndpoints.cowSales,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
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

  Map<String, dynamic> _buildCowDetailsPayload(CowDetails cowDetails) {
    return {
      'animalType': cowDetails.animalType,
      'breed': cowDetails.breed,
      'age': cowDetails.age,
      'price': _normalizeNumber(cowDetails.price),
      'yield': _normalizeNumber(cowDetails.milkYield),
      'description': cowDetails.description,
    };
  }

  dynamic _normalizeNumber(double value) {
    return value % 1 == 0 ? value.toInt() : value;
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

  Map<String, dynamic>? _asMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    if (rawData is String && rawData.isNotEmpty) {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  List<String> _extractImageUrls(Map<String, dynamic> responseMap) {
    final candidates = [
      responseMap['urls'],
      responseMap['images'],
      responseMap['data'],
      responseMap['data'] is Map ? (responseMap['data'] as Map)['urls'] : null,
      responseMap['data'] is Map ? (responseMap['data'] as Map)['images'] : null,
    ];

    for (final candidate in candidates) {
      final urls = _normalizeUrls(candidate);
      if (urls.isNotEmpty) return urls;
    }

    return [];
  }

  List<String> _normalizeUrls(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return [value];
    }

    if (value is List) {
      return value
          .map((item) {
            if (item is String) return item;
            if (item is Map<String, dynamic>) {
              return item['url']?.toString() ??
                  item['path']?.toString() ??
                  item['image']?.toString() ??
                  '';
            }
            if (item is Map) {
              return item['url']?.toString() ??
                  item['path']?.toString() ??
                  item['image']?.toString() ??
                  '';
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    if (value is Map<String, dynamic>) {
      final nested = value['urls'] ?? value['images'] ?? value['url'];
      return _normalizeUrls(nested);
    }

    if (value is Map) {
      final nested = value['urls'] ?? value['images'] ?? value['url'];
      return _normalizeUrls(nested);
    }

    return [];
  }
}
