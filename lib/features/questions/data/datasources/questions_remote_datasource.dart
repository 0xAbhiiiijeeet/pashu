import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/question_model.dart';

class QuestionsRemoteDataSource {
  final DioClient _dioClient;

  QuestionsRemoteDataSource(this._dioClient);

  /// GET /api/questions
  Future<List<QuestionModel>> getQuestions() async {
    final response = await _dioClient.get(ApiEndpoints.questions);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/questions
  Future<QuestionModel> askQuestion({
    required String questionText,
    String? imageUrl,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.questions,
      data: {
        'questionText': questionText,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return QuestionModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// PUT /api/questions/:id/like
  Future<int> toggleLike(String questionId) async {
    final response = await _dioClient.put(
      ApiEndpoints.questionLike(questionId),
    );
    final data = response.data as Map<String, dynamic>;
    return data['likes'] as int;
  }

  /// POST /api/questions/:id/comments
  Future<List<CommentModel>> addComment({
    required String questionId,
    required String text,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.questionComments(questionId),
      data: {'text': text},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/questions/:id/answer
  Future<QuestionModel> answerQuestion({
    required String questionId,
    required String text,
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.questionAnswer(questionId),
      data: {'text': text},
    );
    final data = response.data as Map<String, dynamic>;
    final questionData = data['data'] as Map<String, dynamic>;
    return QuestionModel.fromJson(questionData);
  }
}
