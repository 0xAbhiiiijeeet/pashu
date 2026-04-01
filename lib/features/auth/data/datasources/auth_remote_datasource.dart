import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Map<String, dynamic> _extractUserMap(
    Map<String, dynamic> responseData, {
    String fallbackMessage = 'User data not found in response',
  }) {
    final userData = responseData['user'] ?? responseData['data'];

    if (userData is Map<String, dynamic>) {
      return userData;
    }

    debugPrint('Unexpected auth response shape: $responseData');
    throw Exception(responseData['message'] ?? fallbackMessage);
  }

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      debugPrint('Sending OTP request for: $phoneNumber');
      final response = await _dioClient.post(
        ApiEndpoints.sendOtp,
        data: {'phoneNumber': phoneNumber},
      );
      debugPrint('OTP response received: ${response.statusCode}');

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      if (response.data is String) {
        debugPrint('Backend returned string response: ${response.data}');
        return {'success': true, 'message': response.data as String};
      }

      debugPrint('Unexpected response type: ${response.data.runtimeType}');
      return {'success': true, 'message': 'OTP sent'};
    } catch (e, stackTrace) {
      debugPrint('Error in sendOtp: $e');
      debugPrint('Stack trace: $stackTrace');

      if (e.toString().contains("type 'String' is not a subtype of type 'int'")) {
        throw Exception('Server response format error. Please check backend API.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    debugPrint('──── VERIFY OTP API ─────────────');
    debugPrint('Phone: $phoneNumber');
    debugPrint('OTP: $otp');
    final response = await _dioClient.post(
      ApiEndpoints.verifyOtp,
      data: {'phoneNumber': phoneNumber, 'otp': otp},
    );
    debugPrint('verify-otp response status: ${response.statusCode}');
    debugPrint('verify-otp response type: ${response.data.runtimeType}');
    debugPrint('verify-otp response data: ${response.data}');
    debugPrint('────────────────────────────────');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyFirebaseToken(String idToken) async {
    debugPrint('Verifying Firebase token with backend...');
    final response = await _dioClient.post(
      ApiEndpoints.verifyFirebaseToken,
      data: {'idToken': idToken},
    );
    debugPrint('Backend Firebase verification successful');
    debugPrint('verify-firebase-token response status: ${response.statusCode}');
    debugPrint('verify-firebase-token response data: ${response.data}');
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> completeOnboarding(String name) async {
    final response = await _dioClient.put(
      ApiEndpoints.onboarding,
      data: {'name': name},
    );
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(
      _extractUserMap(
        data,
        fallbackMessage: 'Onboarding response did not include user data',
      ),
    );
  }

  Future<UserModel> updateProfile({
    required String name,
    required Map<String, dynamic> profileDetails,
  }) async {
    debugPrint('Sending profile update request:');
    debugPrint('  Name: $name');
    debugPrint('  ProfileDetails: $profileDetails');

    final response = await _dioClient.put(
      ApiEndpoints.profile,
      data: {
        'name': name,
        'profileDetails': profileDetails,
      },
    );

    debugPrint('Received profile update response:');
    debugPrint('  Status: ${response.statusCode}');
    debugPrint('  Data: ${response.data}');

    final data = response.data as Map<String, dynamic>;
    final userData = _extractUserMap(
      data,
      fallbackMessage: 'Profile update failed',
    );

    debugPrint('User data from backend: ${userData['profileDetails']}');
    return UserModel.fromJson(userData);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.get(ApiEndpoints.profile);
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(
      _extractUserMap(
        data,
        fallbackMessage: 'Profile response did not include user data',
      ),
    );
  }

  Future<UserModel> uploadProfilePic(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'profilePic': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await _dioClient.put(
      ApiEndpoints.profilePic,
      data: formData,
    );

    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(
      _extractUserMap(
        data,
        fallbackMessage: 'Profile picture upload failed',
      ),
    );
  }
}
