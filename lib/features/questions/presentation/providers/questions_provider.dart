import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/datasources/questions_remote_datasource.dart';
import '../../domain/models/question_model.dart';

class QuestionsProvider extends ChangeNotifier {
  final QuestionsRemoteDataSource _dataSource;

  QuestionsProvider(this._dataSource);

  String _status = 'initial';
  List<QuestionModel> _questions = [];
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  String get status => _status;
  List<QuestionModel> get questions => _questions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == 'loading';

  // ── Fetch Questions ───────────────────────────────────────────────────────
  Future<void> fetchQuestions() async {
    _setLoading();
    try {
      _questions = await _dataSource.getQuestions();
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } on DioException catch (e) {
      _setError(_extractDioError(e));
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Ask Question ──────────────────────────────────────────────────────────
  Future<bool> askQuestion({
    required String questionText,
    String? imageUrl,
  }) async {
    try {
      final question = await _dataSource.askQuestion(
        questionText: questionText,
        imageUrl: imageUrl,
      );
      _questions = [question, ..._questions];
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractDioError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Toggle Like ───────────────────────────────────────────────────────────
  Future<void> toggleLike(String questionId, String currentUserId) async {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index == -1) return;

    final question = _questions[index];
    final isLiked = question.likes.contains(currentUserId);

    // Optimistic update
    final newLikes = isLiked
        ? question.likes.where((id) => id != currentUserId).toList()
        : [...question.likes, currentUserId];

    _questions[index] = question.copyWith(likes: newLikes);
    notifyListeners();

    try {
      await _dataSource.toggleLike(questionId);
    } on DioException catch (_) {
      // Revert on failure
      _questions[index] = question;
      notifyListeners();
    }
  }

  // ── Add Comment ───────────────────────────────────────────────────────────
  Future<bool> addComment({
    required String questionId,
    required String text,
  }) async {
    try {
      final comments = await _dataSource.addComment(
        questionId: questionId,
        text: text,
      );
      final index = _questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _questions[index] = _questions[index].copyWith(comments: comments);
        notifyListeners();
      }
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractDioError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = 'loading';
    notifyListeners();
  }

  void _setError(String message) {
    _status = 'error';
    _errorMessage = message;
    notifyListeners();
  }

  String _extractDioError(DioException e) {
    if (e.error is AppException) return (e.error as AppException).message;
    return e.message ?? 'Unable to complete this action. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
