import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';

class SubscriptionService {
  final DioClient _dioClient;

  SubscriptionService(this._dioClient);

  Future<Map<String, dynamic>> startTrial() async {
    try {
      debugPrint('Starting trial subscription...');
      final response = await _dioClient.post(ApiEndpoints.subscriptionTrial);
      debugPrint('Trial subscription response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error starting trial: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSubscription() async {
    try {
      debugPrint('Creating full subscription...');
      final response = await _dioClient.post(ApiEndpoints.subscriptionSubscribe);
      debugPrint('Subscription response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating subscription: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    try {
      debugPrint('Fetching subscription status...');
      final response = await _dioClient.get(ApiEndpoints.subscriptionStatus);
      debugPrint('Subscription status: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error fetching subscription status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forceActivate() async {
    try {
      debugPrint('Force activating current user subscription...');
      final response = await _dioClient.put(ApiEndpoints.subscriptionForceActive);
      debugPrint('Force activation response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error force activating subscription: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forceActivateForUser(String userId) async {
    try {
      debugPrint('Admin force activating subscription for user: $userId');
      final response = await _dioClient.put(
        ApiEndpoints.adminSubscriptionForceActive(userId),
      );
      debugPrint('Admin force activation response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error admin force activating subscription: $e');
      rethrow;
    }
  }
}
