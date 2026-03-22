import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';
import '../constants/api_endpoints.dart';

class SubscriptionService {
  final DioClient _dioClient;

  SubscriptionService(this._dioClient);

  /// Start ₹1 trial subscription (first-time users only)
  Future<Map<String, dynamic>> startTrial() async {
    try {
      debugPrint('💳 Starting trial subscription...');
      final response = await _dioClient.post(ApiEndpoints.subscriptionTrial);
      debugPrint('✅ Trial subscription response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error starting trial: $e');
      rethrow;
    }
  }

  /// Start full ₹999/year subscription
  Future<Map<String, dynamic>> createSubscription() async {
    try {
      debugPrint('💳 Creating full subscription...');
      final response = await _dioClient.post(ApiEndpoints.subscriptionSubscribe);
      debugPrint('✅ Subscription response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error creating subscription: $e');
      rethrow;
    }
  }

  /// Get current subscription status
  Future<Map<String, dynamic>> getStatus() async {
    try {
      debugPrint('💳 Fetching subscription status...');
      final response = await _dioClient.get(ApiEndpoints.subscriptionStatus);
      debugPrint('✅ Subscription status: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error fetching subscription status: $e');
      rethrow;
    }
  }
}
