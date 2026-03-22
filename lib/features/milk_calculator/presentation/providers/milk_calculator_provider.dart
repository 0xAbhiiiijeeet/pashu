import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/milk_calculator_remote_datasource.dart';
import '../../domain/models/milk_calculation_model.dart';

class MilkCalculatorProvider extends ChangeNotifier {
  final MilkCalculatorRemoteDataSource _dataSource;

  MilkCalculatorProvider(this._dataSource);

  String _status = 'initial';
  List<MilkCalculationModel> _history = [];
  MilkCalculationModel? _latestCalculation;
  String? _errorMessage;

  // Getters
  String get status => _status;
  List<MilkCalculationModel> get history => _history;
  MilkCalculationModel? get latestCalculation => _latestCalculation;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == 'loading';

  /// Calculate milk details
  Future<bool> calculate(MilkCalculationInput input) async {
    _setLoading();
    debugPrint('🧮 [MilkCalculator] Starting calculation...');
    debugPrint('📊 [MilkCalculator] Input: ${input.toJson()}');
    
    try {
      final calculation = await _dataSource.calculate(input);
      _latestCalculation = calculation;
      _history = [calculation, ..._history];
      
      debugPrint('✅ [MilkCalculator] Calculation successful!');
      debugPrint('💰 [MilkCalculator] Daily Income: ₹${calculation.totalDailyIncome}');
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint('❌ [MilkCalculator] DioException occurred:');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Response Data: ${e.response?.data}');
      debugPrint('   Error Message: ${e.message}');
      debugPrint('   Error Type: ${e.type}');
      
      final errorMsg = _extractDioError(e);
      debugPrint('   Extracted Error: $errorMsg');
      _setError(errorMsg);
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ [MilkCalculator] Unexpected error: $e');
      debugPrint('   Stack Trace: $stackTrace');
      _setError(e.toString());
      return false;
    }
  }

  /// Fetch calculation history
  Future<void> fetchHistory() async {
    _setLoading();
    debugPrint('📜 [MilkCalculator] Fetching calculation history...');
    
    try {
      _history = await _dataSource.getHistory();
      debugPrint('✅ [MilkCalculator] History fetched: ${_history.length} calculations');
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('⚠️ [MilkCalculator] Error fetching history: $e');
      debugPrint('   Stack Trace: $stackTrace');
      debugPrint('   Showing empty state gracefully');
      
      _history = [];
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Delete calculation
  Future<bool> deleteCalculation(String id) async {
    debugPrint('🗑️ [MilkCalculator] Deleting calculation: $id');
    
    try {
      await _dataSource.deleteCalculation(id);
      _history.removeWhere((calc) => calc.id == id);
      
      debugPrint('✅ [MilkCalculator] Calculation deleted successfully');
      debugPrint('   Remaining calculations: ${_history.length}');
      
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint('❌ [MilkCalculator] Delete failed - DioException:');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Response Data: ${e.response?.data}');
      debugPrint('   Error Message: ${e.message}');
      
      final errorMsg = _extractDioError(e);
      debugPrint('   Extracted Error: $errorMsg');
      _setError(errorMsg);
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ [MilkCalculator] Delete failed - Unexpected error: $e');
      debugPrint('   Stack Trace: $stackTrace');
      _setError(e.toString());
      return false;
    }
  }

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
    if (e.response != null) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final message = responseData?['message'] as String?;
      if (message != null) return message;
    }
    return e.message ?? 'Unable to complete this action. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
