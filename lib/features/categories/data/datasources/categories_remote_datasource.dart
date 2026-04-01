import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/category_model.dart';

class CategoriesRemoteDataSource {
  final DioClient _dioClient;

  CategoriesRemoteDataSource(this._dioClient);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.get(ApiEndpoints.categories);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    required String nameEn,
    required String description,
    required String descriptionEn,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.categories,
      data: {
        'name': name,
        'nameEn': nameEn,
        'description': description,
        'descriptionEn': descriptionEn,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory({
    required String id,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    bool? isActive,
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.categoryById(id),
      data: {
        if (name != null) 'name': name,
        if (nameEn != null) 'nameEn': nameEn,
        if (description != null) 'description': description,
        if (descriptionEn != null) 'descriptionEn': descriptionEn,
        if (isActive != null) 'isActive': isActive,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> deleteCategory(String id) async {
    final response = await _dioClient.delete(ApiEndpoints.categoryById(id));
    return response.data as Map<String, dynamic>;
  }
}
