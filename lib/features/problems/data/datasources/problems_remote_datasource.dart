import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/problem_model.dart';

class ProblemsRemoteDataSource {
  final DioClient _dioClient;

  ProblemsRemoteDataSource(this._dioClient);

  Future<List<ProblemModel>> getProblems() async {
    try {
      debugPrint('🌐 Fetching problems from API...');
      final response = await _dioClient.get('/api/problems');
      debugPrint('📦 Problems response: ${response.data}');
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> list = data['data'] as List<dynamic>;
        debugPrint('📦 Problems count: ${list.length}');
        
        return list.map((json) {
          try {
            return ProblemModel.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            debugPrint('❌ Error parsing problem: $e');
            debugPrint('❌ Problem JSON: $json');
            rethrow;
          }
        }).toList();
      }
      
      debugPrint('⚠️ No problems data in response');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getProblems: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
}
