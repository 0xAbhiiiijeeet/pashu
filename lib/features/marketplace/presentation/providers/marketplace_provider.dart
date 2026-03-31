import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/marketplace_remote_datasource.dart';
import '../../domain/models/cow_sale_model.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceRemoteDataSource _dataSource;

  MarketplaceProvider(this._dataSource);

  String _status = 'initial';
  List<CowSaleModel> _mySales = [];
  List<CowSaleModel> _approvedSales = [];
  String? _errorMessage;

  // Getters
  String get status => _status;
  List<CowSaleModel> get mySales => _mySales;
  List<CowSaleModel> get approvedSales => _approvedSales;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == 'loading';

  /// Initialize - load from cache and fetch fresh data
  Future<void> init() async {
    await fetchApprovedSales();
  }

  /// Create a new cow sale
  Future<bool> createCowSale(
    CowDetails cowDetails, {
    List<String> imagePaths = const [],
  }) async {
    _setLoading();
    debugPrint('🐄 [Marketplace] Creating cow sale...');
    debugPrint('📝 [Marketplace] Details: ${cowDetails.toJson()}');
    
    try {
      final sale = await _dataSource.createCowSale(
        cowDetails,
        imagePaths: imagePaths,
      );
      _mySales = [sale, ..._mySales];
      
      debugPrint('✅ [Marketplace] Cow sale created successfully!');
      debugPrint('   Sale ID: ${sale.id}');
      debugPrint('   Status: ${sale.status}');
      debugPrint('   Breed: ${sale.cowDetails.breed}');
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint('❌ [Marketplace] Create sale failed - DioException:');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Response Data: ${e.response?.data}');
      debugPrint('   Error Message: ${e.message}');
      debugPrint('   Error Type: ${e.type}');
      
      final errorMsg = _extractDioError(e);
      debugPrint('   Extracted Error: $errorMsg');
      _setError(errorMsg);
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ [Marketplace] Create sale failed - Unexpected error: $e');
      debugPrint('   Stack Trace: $stackTrace');
      _setError(e.toString());
      return false;
    }
  }

  /// Fetch user's own sales
  Future<void> fetchMySales() async {
    _setLoading();
    debugPrint('📋 [Marketplace] Fetching my sales...');
    
    try {
      _mySales = await _dataSource.getMySales();
      
      debugPrint('✅ [Marketplace] My sales fetched: ${_mySales.length} listings');
      for (var sale in _mySales) {
        debugPrint('   - ${sale.cowDetails.breed} (${sale.status})');
      }
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('⚠️ [Marketplace] Error fetching my sales: $e');
      debugPrint('   Stack Trace: $stackTrace');
      debugPrint('   Showing empty state gracefully');
      
      _mySales = [];
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Fetch all approved sales (marketplace)
  Future<void> fetchApprovedSales() async {
    _setLoading();
    debugPrint('🏪 [Marketplace] Fetching approved sales...');
    
    try {
      _approvedSales = await _dataSource.getApprovedSales();
      
      debugPrint('✅ [Marketplace] Approved sales fetched: ${_approvedSales.length} listings');
      for (var sale in _approvedSales) {
        debugPrint('   - ${sale.cowDetails.breed} - ₹${sale.cowDetails.price}');
      }
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('⚠️ [Marketplace] Error fetching approved sales: $e');
      debugPrint('   Stack Trace: $stackTrace');
      debugPrint('   Showing empty state gracefully');
      
      _approvedSales = [];
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
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
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] as String?;
        if (message != null) return message;
      } else if (responseData is Map) {
        final message = responseData['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      } else if (responseData is String && responseData.isNotEmpty) {
        return responseData;
      }
    }
    return e.message ?? 'Unable to complete this action. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
