import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/problem_model.dart';

class ProblemsRemoteDataSource {
  final DioClient _dioClient;

  ProblemsRemoteDataSource(this._dioClient);

  Future<List<ProblemModel>> getProblems() async {
    try {
      debugPrint('Fetching problems from API...');
      final response = await _dioClient.get(ApiEndpoints.problems);
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['data'] != null) {
        final list = data['data'] as List<dynamic>;
        return list
            .map((json) => ProblemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e, stackTrace) {
      debugPrint('Error in getProblems: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createProblem({
    required String title,
    required String titleEn,
    required String description,
    required String descriptionEn,
    required String category,
    required String categoryEn,
    String? imagePath,
  }) async {
    final formData = await _buildProblemFormData(
      title: title,
      titleEn: titleEn,
      description: description,
      descriptionEn: descriptionEn,
      category: category,
      categoryEn: categoryEn,
      imagePath: imagePath,
    );

    final response = await _dioClient.dio.post(
      ApiEndpoints.problems,
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProblem({
    required String id,
    String? title,
    String? titleEn,
    String? description,
    String? descriptionEn,
    String? category,
    String? categoryEn,
    bool? isActive,
    String? imagePath,
  }) async {
    final formData = FormData();
    if (title != null) formData.fields.add(MapEntry('title', title));
    if (titleEn != null) formData.fields.add(MapEntry('titleEn', titleEn));
    if (description != null) {
      formData.fields.add(MapEntry('description', description));
    }
    if (descriptionEn != null) {
      formData.fields.add(MapEntry('descriptionEn', descriptionEn));
    }
    if (category != null) formData.fields.add(MapEntry('category', category));
    if (categoryEn != null) {
      formData.fields.add(MapEntry('categoryEn', categoryEn));
    }
    if (isActive != null) {
      formData.fields.add(MapEntry('isActive', isActive.toString()));
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        ),
      );
    }

    final response = await _dioClient.dio.put(
      '/api/problems/$id',
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteProblem(String id) async {
    final response = await _dioClient.delete('/api/problems/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<FormData> _buildProblemFormData({
    required String title,
    required String titleEn,
    required String description,
    required String descriptionEn,
    required String category,
    required String categoryEn,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'titleEn': titleEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'category': category,
      'categoryEn': categoryEn,
    });

    if (imagePath != null && imagePath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        ),
      );
    }

    return formData;
  }
}
