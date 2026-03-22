import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  /// POST /api/auth/send-otp
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      debugPrint('📡 Sending OTP request for: $phoneNumber');
      final response = await _dioClient.post(
        ApiEndpoints.sendOtp,
        data: {'phoneNumber': phoneNumber},
      );
      debugPrint('✅ OTP response received: ${response.statusCode}');
      
      // Handle different response types
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        // Backend returned string instead of JSON
        debugPrint('⚠️ Backend returned string response: ${response.data}');
        return {'success': true, 'message': response.data as String};
      } else {
        debugPrint('⚠️ Unexpected response type: ${response.data.runtimeType}');
        return {'success': true, 'message': 'OTP sent'};
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in sendOtp: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      if (e.toString().contains("type 'String' is not a subtype of type 'int'")) {
        throw Exception('Server response format error. Please check backend API.');
      }
      rethrow;
    }
  }

  /// POST /api/auth/verify-otp (Dev/Test only - uses hardcoded OTP 123456)
  Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.verifyOtp,
      data: {'phoneNumber': phoneNumber, 'otp': otp},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/auth/verify-firebase-token (Production - uses real Firebase OTP)
  Future<Map<String, dynamic>> verifyFirebaseToken(String idToken) async {
    debugPrint('📡 Verifying Firebase token with backend...');
    final response = await _dioClient.post(
      ApiEndpoints.verifyFirebaseToken,
      data: {'idToken': idToken},
    );
    debugPrint('✅ Backend verification successful');
    return response.data as Map<String, dynamic>;
  }

  /// PUT /api/auth/onboarding
  Future<UserModel> completeOnboarding(String name) async {
    final response = await _dioClient.put(
      ApiEndpoints.onboarding,
      data: {'name': name},
    );
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// PUT /api/auth/profile
  Future<UserModel> updateProfile({
    required String name,
    required Map<String, dynamic> profileDetails,
  }) async {
    debugPrint('📤 Sending profile update request:');
    debugPrint('   Name: $name');
    debugPrint('   ProfileDetails: $profileDetails');
    
    final response = await _dioClient.put(
      ApiEndpoints.profile,
      data: {
        'name': name,
        'profileDetails': profileDetails,
      },
    );
    
    debugPrint('📥 Received profile update response:');
    debugPrint('   Status: ${response.statusCode}');
    debugPrint('   Data: ${response.data}');
    
    final data = response.data as Map<String, dynamic>;
    
    // Check if response has data field
    if (data['data'] == null) {
      debugPrint('⚠️ Backend returned success but no data field');
      throw Exception(data['message'] ?? 'Profile update failed');
    }
    
    final userData = data['data'] as Map<String, dynamic>;
    
    debugPrint('📋 User data from backend:');
    debugPrint('   ProfileDetails: ${userData['profileDetails']}');
    
    return UserModel.fromJson(userData);
  }

  /// GET /api/auth/profile - Fetch current user data
  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.get(ApiEndpoints.profile);
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// PUT /api/auth/profile-pic - Upload profile picture
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
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}
