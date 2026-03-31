import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/datasources/bookings_remote_datasource.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/problem_model.dart';

class BookingsProvider extends ChangeNotifier {
  final BookingsRemoteDataSource _dataSource;
  final StorageService _storageService;

  BookingsProvider(this._dataSource, this._storageService);

  String _status = 'initial';
  List<ProblemModel> _problems = [];
  List<BookingModel> _booked = [];
  List<BookingModel> _completed = [];
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  String get status => _status;
  List<ProblemModel> get problems => _problems;
  List<BookingModel> get booked => _booked;
  List<BookingModel> get completed => _completed;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == 'loading';

  /// Returns the first pending booking that hasn't expired yet.
  /// A booking is expired when the call window (3 h from scheduledTime) has passed.
  BookingModel? get activeBooking {
    final now = DateTime.now();
    for (final b in _booked) {
      if (b.status == 'pending' &&
          b.scheduledTime.add(const Duration(hours: 3)).isAfter(now)) {
        return b;
      }
    }
    return null;
  }

  // ── Initialize ────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Load from cache synchronously (fast)
    loadBookedFromCacheSync();
    loadCompletedFromCacheSync();
    
    // Fetch fresh data in background
    await fetchBooked();
  }

  // ── Cache Management ──────────────────────────────────────────────────────
  void loadBookedFromCacheSync() {
    try {
      final cachedData = _storageService.getBookedCalls();
      if (cachedData != null && cachedData.isNotEmpty) {
        _booked = cachedData.map((json) => BookingModel.fromJson(json)).toList();
        debugPrint('📦 Loaded ${_booked.length} booked calls from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading booked calls from cache: $e');
    }
  }

  void loadCompletedFromCacheSync() {
    try {
      final cachedData = _storageService.getCompletedCalls();
      if (cachedData != null && cachedData.isNotEmpty) {
        _completed = cachedData.map((json) => BookingModel.fromJson(json)).toList();
        debugPrint('📦 Loaded ${_completed.length} completed calls from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading completed calls from cache: $e');
    }
  }

  // ── Problems ──────────────────────────────────────────────────────────────
  Future<void> fetchProblems() async {
    _setLoading();
    try {
      _problems = await _dataSource.getProblems();
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } on DioException catch (e) {
      _setError(_extractDioError(e));
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Book Call ─────────────────────────────────────────────────────────────
  Future<bool> bookCall({
    required String problemId,
    required DateTime scheduledTime,
  }) async {
    _setLoading();
    try {
      debugPrint('📞 Booking call for problem: $problemId at $scheduledTime');
      
      final booking = await _dataSource.bookCall(
        problemId: problemId,
        scheduledTime: scheduledTime,
      );
      
      debugPrint('✅ Call booked successfully: ${booking.id}');
      _booked = [booking, ..._booked];
      
      // Update cache
      await _storageService.saveBookedCalls(
        _booked.map((b) => b.toJson()).toList(),
      );
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint('❌ DioException booking call: ${e.type}');
      debugPrint('❌ Response: ${e.response?.data}');
      debugPrint('❌ Message: ${e.message}');
      
      // Handle subscription requirement specifically
      if (e.response?.statusCode == 403) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        if (responseData?['subscriptionRequired'] == true) {
          _setError('Please complete your subscription payment to book calls. Go to Profile → Subscription to pay.');
          return false;
        }
      }
      
      _setError(_extractDioError(e));
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Exception booking call: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // Check if it's a subscription error
      final errorMessage = e.toString();
      if (errorMessage.contains('subscription') || errorMessage.contains('subscribe')) {
        _setError('Please complete your subscription payment to book calls. Go to Profile → Subscription to pay.');
      } else {
        _setError('Unable to book your call. Please try again or contact support.');
      }
      return false;
    }
  }

  // ── Fetch Booked ──────────────────────────────────────────────────────────
  Future<void> fetchBooked() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ Skipping booked calls fetch: no auth token available yet');
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _setLoading();
    try {
      _booked = await _dataSource.getBookedCalls();
      
      // Update cache
      await _storageService.saveBookedCalls(
        _booked.map((b) => b.toJson()).toList(),
      );
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } on DioException catch (e) {
      _setError(_extractDioError(e));
      
      // If fetch fails and we have no data, try to use cache
      if (_booked.isEmpty) {
        loadBookedFromCacheSync();
      }
    } catch (e) {
      _setError(e.toString());
      
      // If fetch fails and we have no data, try to use cache
      if (_booked.isEmpty) {
        loadBookedFromCacheSync();
      }
    }
  }

  // ── Fetch Completed ───────────────────────────────────────────────────────
  Future<void> fetchCompleted() async {
    _setLoading();
    try {
      _completed = await _dataSource.getCompletedCalls();
      
      // Update cache
      await _storageService.saveCompletedCalls(
        _completed.map((b) => b.toJson()).toList(),
      );
      
      _status = 'loaded';
      _errorMessage = null;
      notifyListeners();
    } on DioException catch (e) {
      _setError(_extractDioError(e));
      
      // If fetch fails and we have no data, try to use cache
      if (_completed.isEmpty) {
        loadCompletedFromCacheSync();
      }
    } catch (e) {
      _setError(e.toString());
      
      // If fetch fails and we have no data, try to use cache
      if (_completed.isEmpty) {
        loadCompletedFromCacheSync();
      }
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
    
    // Handle 403 subscription errors specifically
    if (e.response?.statusCode == 403) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      if (responseData?['subscriptionRequired'] == true) {
        return 'Please complete your subscription payment to book calls. Go to Profile → Subscription to pay.';
      }
    }
    
    // Handle other HTTP errors
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
