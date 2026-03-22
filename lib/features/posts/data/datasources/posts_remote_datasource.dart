import 'package:dio/dio.dart';
import '../../domain/models/post_model.dart';

class PostsRemoteDataSource {
  final Dio _dio;

  PostsRemoteDataSource(this._dio);

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _dio.get('/api/posts');
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Unable to load posts. Please try again.');
    }
  }

  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await _dio.get('/api/posts/$postId');
      return PostModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Unable to load post. Please try again.');
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      await _dio.put('/api/posts/$postId/like');
    } catch (e) {
      throw Exception('Unable to update like. Please try again.');
    }
  }

  Future<List<CommentModel>> addComment(String postId, String text) async {
    try {
      final response = await _dio.post(
        '/api/posts/$postId/comments',
        data: {'text': text},
      );
      final comments = response.data['data'] as List<dynamic>;
      return comments.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Unable to add comment. Please try again.');
    }
  }
}
