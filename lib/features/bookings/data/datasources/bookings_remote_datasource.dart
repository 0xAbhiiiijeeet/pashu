import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/problem_model.dart';

class BookingsRemoteDataSource {
  final DioClient _dioClient;

  BookingsRemoteDataSource(this._dioClient);

  /// GET /api/problems
  Future<List<ProblemModel>> getProblems() async {
    final response = await _dioClient.get(ApiEndpoints.problems);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => ProblemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/bookings
  Future<BookingModel> bookCall({
    required String problemId,
    required DateTime scheduledTime,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.bookings,
      data: {
        'problemId': problemId,
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
    
    // Debug: Print the raw response
    print('📡 Book call response: ${response.data}');
    
    final data = response.data as Map<String, dynamic>;
    
    // Check if this is an error response
    if (data['success'] == false) {
      final message = data['message'] as String? ?? 'Booking failed';
      
      // For testing: if subscription exists but not active, provide helpful message
      if (message.contains('subscription') && message.contains('required')) {
        throw Exception('Subscription exists but not active. Use test card 4111 1111 1111 1111 to complete payment in Profile → Subscription.');
      }
      
      throw Exception(message);
    }
    
    // Check if data field exists and is not null
    final bookingData = data['data'];
    if (bookingData == null) {
      throw Exception('API returned null booking data');
    }
    
    if (bookingData is! Map<String, dynamic>) {
      throw Exception('API returned invalid booking data format: ${bookingData.runtimeType}');
    }
    
    return BookingModel.fromJson(bookingData);
  }

  /// GET /api/bookings/booked
  Future<List<BookingModel>> getBookedCalls() async {
    final response = await _dioClient.get(ApiEndpoints.bookedCalls);
    
    // Debug: Print the raw response
    print('📡 Booked calls response: ${response.data}');
    
    final data = response.data as Map<String, dynamic>;
    final list = data['data'];
    
    if (list == null) {
      print('⚠️ API returned null for booked calls data');
      return [];
    }
    
    if (list is! List) {
      print('⚠️ API returned non-list for booked calls: ${list.runtimeType}');
      return [];
    }
    
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/bookings/completed
  Future<List<BookingModel>> getCompletedCalls() async {
    final response = await _dioClient.get(ApiEndpoints.completedCalls);
    
    // Debug: Print the raw response
    print('📡 Completed calls response: ${response.data}');
    
    final data = response.data as Map<String, dynamic>;
    final list = data['data'];
    
    if (list == null) {
      print('⚠️ API returned null for completed calls data');
      return [];
    }
    
    if (list is! List) {
      print('⚠️ API returned non-list for completed calls: ${list.runtimeType}');
      return [];
    }
    
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/bookings/admin/all
  Future<List<BookingModel>> getAllBookingsForAdmin() async {
    final response = await _dioClient.get(ApiEndpoints.adminBookings);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/bookings/:id/status
  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.bookingStatus(bookingId),
      data: {'status': status},
    );
    final data = response.data as Map<String, dynamic>;
    final bookingData = data['data'] as Map<String, dynamic>;
    return BookingModel.fromJson(bookingData);
  }
}
