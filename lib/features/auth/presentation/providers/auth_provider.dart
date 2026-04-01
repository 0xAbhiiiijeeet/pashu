import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRemoteDataSource _dataSource;
  final StorageService _storageService;

  String _status = 'initial';
  UserModel? _user;
  String? _errorMessage;
  String? _firebaseVerificationId; // for Firebase auth
  final bool _useFirebaseAuth = false; // Toggle Firebase on/off

  AuthProvider(this._dataSource, this._storageService);

  // ── Getters ───────────────────────────────────────────────────────────────
  String get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == 'loading';
  bool get isAuthenticated => _status == 'authenticated';
  bool get needsOnboarding {
    try {
      debugPrint('🔍 Checking needsOnboarding: user=$_user, onboardingComplete=${_user?.onboardingComplete}');
      return _user != null && _user!.onboardingComplete == false;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in needsOnboarding getter: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    debugPrint('🚀 Starting auth initialization...');
    
    // Immediately set loading state so UI can render
    _status = 'loading';
    notifyListeners();

    // Run the actual init logic with timeout
    try {
      await _runInit().timeout(
        const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('⚠️ Auth init timeout: $e');
      _status = 'unauthenticated';
      _errorMessage = 'App is taking longer to start. Please try again.';
    }
    
    debugPrint('🏁 Auth initialization complete. Status: $_status');
    notifyListeners();
  }

  Future<void> _runInit() async {
    // Check if session is expired
    debugPrint('📅 Checking session expiry...');
    if (_storageService.isSessionExpired()) {
      debugPrint('🔒 Session expired, clearing cache');
      await _storageService.clearAuthCache();
      _status = 'unauthenticated';
      debugPrint('✅ Auth init complete: unauthenticated (session expired)');
      notifyListeners();
      return;
    }

    debugPrint('🔑 Getting token...');
    final token = await _storageService.getToken();
    debugPrint('👤 Getting user data...');
    final userData = _storageService.getUser();

    debugPrint('🔑 Token exists: ${token != null}');
    debugPrint('👤 User data exists: ${userData != null}');
    if (token != null) {
      debugPrint('🔑 Token value: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    }
    if (userData != null) {
      debugPrint('👤 User data keys: ${userData.keys.toList()}');
      debugPrint('👤 User data: name=${userData['name']}, phone=${userData['phoneNumber']}, onboardingComplete=${userData['onboardingComplete']}');
    }

    if (token != null && userData != null) {
      DioClient.instance.setAuthToken(token);
      debugPrint('🔄 Creating UserModel from JSON...');
      try {
        _user = UserModel.fromJson(userData);
        debugPrint('✅ UserModel created successfully');
        debugPrint('✅ User: id=${_user!.id}, name=${_user!.name}, onboardingComplete=${_user!.onboardingComplete}');
      } catch (e, stackTrace) {
        debugPrint('❌ Error creating UserModel from cached data: $e');
        debugPrint('❌ Stack: $stackTrace');
        debugPrint('❌ User data that failed: $userData');
        debugPrint('🧹 Clearing corrupted cache...');
        await _storageService.clearAuthCache();
        _status = 'unauthenticated';
        debugPrint('✅ Cache cleared, user needs to login again');
        notifyListeners();
        return;
      }
      
      _status = 'authenticated';
      
      debugPrint('✅ User authenticated: ${_user?.name} (${_user?.phoneNumber})');
      
      // Update auth status cache
      await _storageService.saveAuthStatus('authenticated');
      
      // Check if cache needs refresh (optional: fetch fresh data from API)
      if (_storageService.needsCacheRefresh()) {
        debugPrint('🔄 Cache needs refresh');
        await _storageService.saveAuthStatus('needs_refresh');
      }
      
      debugPrint('📊 Calculating profile completion...');
      try {
        final completion = _calculateProfileCompletion(_user!);
        debugPrint('📊 Profile completion: $completion%');
        await _storageService.setProfileCompletion(completion);
      } catch (e, stackTrace) {
        debugPrint('❌ Error calculating profile completion: $e');
        debugPrint('❌ Stack: $stackTrace');
        // Don't rethrow - this is not critical
      }
    } else {
      debugPrint('❌ No valid session found');
      _status = 'unauthenticated';
      await _storageService.saveAuthStatus('unauthenticated');
    }
  }

  // ── Send OTP (Firebase with Fallback) ────────────────────────────────────
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      // Cache phone number for later use
      await _storageService.savePhoneNumber(phoneNumber);
      
      // Try Firebase first if enabled
      if (_useFirebaseAuth) {
        debugPrint('🔥 Attempting Firebase OTP...');
        final firebaseSuccess = await _sendFirebaseOtp(phoneNumber);
        if (firebaseSuccess) {
          debugPrint('✅ Firebase OTP sent successfully');
          return true;
        }
        debugPrint('⚠️ Firebase OTP failed, falling back to hardcoded OTP');
      }
      
      // Fallback to hardcoded OTP
      debugPrint('📱 Using hardcoded OTP (123456)');
      await _dataSource.sendOtp(phoneNumber);
      _errorMessage = null;
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

  // ── Send Firebase OTP ─────────────────────────────────────────────────────
  Future<bool> _sendFirebaseOtp(String phoneNumber) async {
    try {
      final firebaseAuth = FirebaseAuthService();
      bool success = false;
      String? error;
      
      await firebaseAuth.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          _firebaseVerificationId = verificationId;
          success = true;
          debugPrint('✅ Firebase verification ID received');
        },
        onError: (errorMessage) {
          error = errorMessage;
          debugPrint('❌ Firebase error: $errorMessage');
        },
        onAutoVerified: () {
          // Auto-verification succeeded (Android only)
          success = true;
          debugPrint('✅ Firebase auto-verification succeeded');
        },
      );
      
      if (error != null) {
        debugPrint('❌ Firebase OTP failed: $error');
        return false;
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Firebase OTP exception: $e');
      return false;
    }
  }

  // ── Verify OTP (Firebase with Fallback) ──────────────────────────────────
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    _setLoading();
    try {
      debugPrint('════ VERIFY OTP FLOW ════════════');
      debugPrint('Input phone: $phoneNumber');
      debugPrint('Input otp: $otp');

      // Try Firebase verification if we have a verification ID
      if (_firebaseVerificationId != null) {
        debugPrint('🔥 Attempting Firebase OTP verification...');
        final firebaseSuccess = await _verifyFirebaseOtp(otp, phoneNumber);
        if (firebaseSuccess) {
          debugPrint('✅ Firebase OTP verified successfully');
          return true;
        }
        debugPrint('⚠️ Firebase verification failed, falling back to hardcoded OTP');
        // Clear verification ID so we don't try Firebase again
        _firebaseVerificationId = null;
      }
      
      // Fallback to hardcoded OTP verification
      debugPrint('📱 Using hardcoded OTP verification');
      final result = await _dataSource.verifyOtp(phoneNumber, otp);
      debugPrint('Raw verifyOtp result: $result');
      debugPrint('Raw verifyOtp keys: ${result.keys.toList()}');
      final dataObj = result.containsKey('data') ? result['data'] as Map<String, dynamic> : result;
      debugPrint('Parsed data object: $dataObj');
      debugPrint('Parsed data object keys: ${dataObj.keys.toList()}');
      final token = dataObj['token'] as String;
      final userData = dataObj['user'] as Map<String, dynamic>;
      debugPrint('✅ Parsed verify-otp token length: ${token.length}');
      debugPrint('✅ Parsed verify-otp user keys: ${userData.keys.toList()}');
      debugPrint('✅ Parsed verify-otp user data: $userData');

      // Save token securely
      await _storageService.saveToken(token);
      DioClient.instance.setAuthToken(token);
      
      // Save refresh token if available
      if (result.containsKey('refreshToken')) {
        await _storageService.saveRefreshToken(result['refreshToken'] as String);
      }
      
      // Save user data
      _user = UserModel.fromJson(userData);
      await _storageService.saveUser(_user!.toJson());
      
      // Cache phone number
      await _storageService.savePhoneNumber(phoneNumber);
      
      // Update auth status
      await _storageService.saveAuthStatus('authenticated');
      
      // Calculate and save profile completion
      final completion = _calculateProfileCompletion(_user!);
      await _storageService.setProfileCompletion(completion);

      // Re-initialize notifications with user token
      try {
        await NotificationService.instance.initialize(userToken: token);
      } catch (e) {
        debugPrint('⚠️ Failed to re-initialize notifications: $e');
      }

      _status = 'authenticated';
      _errorMessage = null;
      notifyListeners();
      debugPrint('════ VERIFY OTP SUCCESS ═════════');
      return true;
    } on DioException catch (e) {
      debugPrint('════ VERIFY OTP DIO ERROR ═══════');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Error object: ${e.error}');
      _setError(_extractDioError(e));
      return false;
    } catch (e) {
      debugPrint('════ VERIFY OTP ERROR ═══════════');
      debugPrint('Error: $e');
      _setError(e.toString());
      return false;
    }
  }

  // ── Verify Firebase OTP ───────────────────────────────────────────────────
  Future<bool> _verifyFirebaseOtp(String otp, String phoneNumber) async {
    try {
      if (_firebaseVerificationId == null) {
        debugPrint('❌ No Firebase verification ID found');
        return false;
      }
      
      // Verify OTP with Firebase
      final firebaseAuth = FirebaseAuthService();
      final idToken = await firebaseAuth.verifyOtp(
        verificationId: _firebaseVerificationId!,
        otp: otp,
      );
      
      if (idToken == null) {
        debugPrint('❌ Failed to get Firebase ID token');
        return false;
      }
      
      debugPrint('✅ Firebase ID token obtained, verifying with backend...');
      
      // Verify token with backend
      final result = await _dataSource.verifyFirebaseToken(idToken);
      final dataObj = result.containsKey('data') ? result['data'] as Map<String, dynamic> : result;
      final token = dataObj['token'] as String;
      final userData = dataObj['user'] as Map<String, dynamic>;
      debugPrint('✅ Parsed verify-firebase-token token length: ${token.length}');
      debugPrint('✅ Parsed verify-firebase-token user keys: ${userData.keys.toList()}');

      // Save token securely
      await _storageService.saveToken(token);
      DioClient.instance.setAuthToken(token);
      
      // Save refresh token if available
      if (result.containsKey('refreshToken')) {
        await _storageService.saveRefreshToken(result['refreshToken'] as String);
      }
      
      // Save user data
      _user = UserModel.fromJson(userData);
      await _storageService.saveUser(_user!.toJson());
      
      // Cache phone number
      await _storageService.savePhoneNumber(phoneNumber);
      
      // Update auth status
      await _storageService.saveAuthStatus('authenticated');
      
      // Calculate and save profile completion
      final completion = _calculateProfileCompletion(_user!);
      await _storageService.setProfileCompletion(completion);

      // Re-initialize notifications with user token
      try {
        await NotificationService.instance.initialize(userToken: token);
      } catch (e) {
        debugPrint('⚠️ Failed to re-initialize notifications: $e');
      }

      _status = 'authenticated';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Firebase verification error: $e');
      return false;
    }
  }

  // ── Complete Onboarding ───────────────────────────────────────────────────
  Future<bool> completeOnboarding(String name) async {
    _setLoading();
    try {
      final updatedUser = await _dataSource.completeOnboarding(name);
      _user = updatedUser;
      
      // Save updated user data
      await _storageService.saveUser(_user!.toJson());
      
      // Mark onboarding as complete
      await _storageService.setOnboardingComplete(true);
      await _storageService.setOnboardingStep(100);
      
      // Update profile completion
      final completion = _calculateProfileCompletion(_user!);
      await _storageService.setProfileCompletion(completion);
      
      _status = 'authenticated';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_extractDioError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile({
    required String name,
    required Map<String, dynamic> profileDetails,
  }) async {
    debugPrint('🔄 Starting profile update...');
    debugPrint('📝 Name: $name');
    debugPrint('📝 Profile Details: $profileDetails');
    
    // Store current user data to preserve fields backend doesn't return
    final oldProfileDetails = _user?.profileDetails;
    
    _setLoading();
    try {
      debugPrint('📡 Calling API...');
      final updatedUser = await _dataSource.updateProfile(
        name: name,
        profileDetails: profileDetails,
      );
      debugPrint('✅ API call successful');
      debugPrint('👤 Updated user from backend: ${updatedUser.toJson()}');
      
      // Merge with old data to preserve fields backend doesn't return
      if (oldProfileDetails != null && updatedUser.profileDetails != null) {
        final newDetails = updatedUser.profileDetails!;
        _user = updatedUser.copyWith(
          profileDetails: ProfileDetails(
            language: newDetails.language ?? oldProfileDetails.language,
            address: newDetails.address ?? oldProfileDetails.address,
            addressLocked: newDetails.addressLocked ?? oldProfileDetails.addressLocked,
            whatsAppNumber: newDetails.whatsAppNumber ?? oldProfileDetails.whatsAppNumber,
            work: newDetails.work ?? oldProfileDetails.work,
            education: newDetails.education ?? oldProfileDetails.education,
            experienceYears: newDetails.experienceYears ?? oldProfileDetails.experienceYears,
            birthday: newDetails.birthday ?? oldProfileDetails.birthday,
            animalCount: newDetails.animalCount ?? oldProfileDetails.animalCount,
          ),
        );
        debugPrint('👤 Merged user data: ${_user!.toJson()}');
      } else {
        _user = updatedUser;
      }
      
      // Save updated user data
      await _storageService.saveUser(_user!.toJson());
      debugPrint('💾 User data saved to cache');
      
      // Update profile completion
      final completion = _calculateProfileCompletion(_user!);
      await _storageService.setProfileCompletion(completion);
      debugPrint('📊 Profile completion updated: $completion%');
      
      _status = 'authenticated';
      _errorMessage = null;
      notifyListeners();
      debugPrint('✅ Profile update complete');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ DioException during profile update: ${e.type}');
      debugPrint('❌ Message: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      
      // Don't change auth status - just set error and keep user authenticated
      _status = 'authenticated';
      _errorMessage = _extractDioError(e);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Exception during profile update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // Don't change auth status - just set error and keep user authenticated
      _status = 'authenticated';
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Upload Profile Picture ────────────────────────────────────────────────
  Future<bool> uploadProfilePic(String filePath) async {
    debugPrint('🔄 Starting profile picture upload...');
    debugPrint('📁 File path: $filePath');
    
    _setLoading();
    try {
      debugPrint('📡 Calling API...');
      final updatedUser = await _dataSource.uploadProfilePic(filePath);
      debugPrint('✅ API call successful');
      debugPrint('👤 Updated user from backend: ${updatedUser.toJson()}');
      
      _user = updatedUser;
      
      // Save updated user data
      await _storageService.saveUser(_user!.toJson());
      debugPrint('💾 User data saved to cache');
      
      _status = 'authenticated';
      _errorMessage = null;
      notifyListeners();
      debugPrint('✅ Profile picture upload complete');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ DioException during profile picture upload: ${e.type}');
      debugPrint('❌ Message: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      
      _status = 'authenticated';
      _errorMessage = _extractDioError(e);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Exception during profile picture upload: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      _status = 'authenticated';
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Fetch Current User ────────────────────────────────────────────────────
  Future<bool> fetchCurrentUser() async {
    try {
      debugPrint('🔄 Fetching current user from backend...');
      final updatedUser = await _dataSource.getCurrentUser();
      _user = updatedUser;
      
      // Save updated user data
      await _storageService.saveUser(_user!.toJson());
      
      // Update profile completion
      final completion = _calculateProfileCompletion(_user!);
      await _storageService.setProfileCompletion(completion);
      
      debugPrint('✅ User data refreshed from backend');
      debugPrint('👤 User: ${_user!.name}, Phone: ${_user!.phoneNumber}');
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final errorMsg = _extractDioError(e);
      debugPrint('❌ Failed to fetch user (DioException): $errorMsg');
      debugPrint('❌ Error type: ${e.type}');
      debugPrint('❌ Error object: ${e.error}');
      
      // Don't set error message in provider - just return false
      // This prevents showing error to user when loading profile
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to fetch user (Exception): $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    // Clear all auth-related cache
    await _storageService.clearAuthCache();
    await _storageService.clearOnboardingCache();
    await _storageService.saveAuthStatus('logged_out');
    DioClient.instance.clearAuthToken();
    
    _user = null;
    _status = 'unauthenticated';
    _errorMessage = null;
    _firebaseVerificationId = null;
    notifyListeners();
  }

  // ── Profile Completion Calculator ─────────────────────────────────────────
  int _calculateProfileCompletion(UserModel user) {
    int completion = 0;
    int totalFields = 0;
    int filledFields = 0;
    
    // Basic info (2 fields)
    totalFields += 2;
    if (user.name != null && user.name!.isNotEmpty) filledFields++;
    if (user.phoneNumber.isNotEmpty) filledFields++;
    
    // Profile details (8 fields - excluding addressLocked which is auto-set)
    if (user.profileDetails != null) {
      final details = user.profileDetails!;
      totalFields += 8;
      
      if (details.language != null && details.language!.isNotEmpty) filledFields++;
      if (details.address != null && details.address!.isNotEmpty) filledFields++;
      if (details.whatsAppNumber != null && details.whatsAppNumber!.isNotEmpty) filledFields++;
      if (details.work != null && details.work!.isNotEmpty) filledFields++;
      if (details.education != null && details.education!.isNotEmpty) filledFields++;
      if (details.experienceYears != null && details.experienceYears!.isNotEmpty) filledFields++;
      if (details.birthday != null) filledFields++;
      if (details.animalCount != null) filledFields++;
    }
    
    // Calculate percentage: (filled / total) * 100
    completion = ((filledFields / totalFields) * 100).round();
    
    debugPrint('📊 Profile completion: $filledFields/$totalFields fields = $completion%');
    return completion;
  }

  // ── Get Cached Data ───────────────────────────────────────────────────────
  String? get lastPhoneNumber => _storageService.lastPhoneNumber;
  
  int get profileCompletion => _storageService.profileCompletion;
  
  bool get isFirstLaunch => _storageService.isFirstLaunch;
  
  DateTime? get loginTimestamp => _storageService.loginTimestamp;
  
  bool get needsCacheRefresh => _storageService.needsCacheRefresh();

  // ── Session Management ────────────────────────────────────────────────────
  Future<void> refreshSession() async {
    if (_user == null) return;
    
    try {
      // TODO: Implement refresh token logic with API
      // For now, just update the last sync timestamp
      await _storageService.saveUser(_user!.toJson());
    } catch (e) {
      // If refresh fails, user needs to login again
      await logout();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = 'loading';
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = 'unauthenticated';
    _errorMessage = message;
    notifyListeners();
  }

  String _extractDioError(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data as Map<String, dynamic>?;
      final message = responseData?['message'] as String?;
      
      if (statusCode == 400 && message == 'Invalid OTP') {
        return 'The OTP you entered is incorrect. Please check and try again.';
      }
      if (statusCode == 401) {
        return 'Your session has expired. Please login again.';
      }
      if (statusCode == 403) {
        return 'You need an active subscription to use this feature. Please go to Profile → Subscription to complete your payment.';
      }
    }

    if (e.error is AppException) {
      return (e.error as AppException).message;
    }
    
    // Handle different error types with user-friendly messages
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Your internet seems slow. Please try again.';
      
      case DioExceptionType.connectionError:
        return 'Please check your internet connection and try again.';
      
      case DioExceptionType.badResponse:
        final responseData = e.response?.data as Map<String, dynamic>?;
        final message = responseData?['message'] as String?;
        return message ?? 'We\'re having trouble connecting to our servers. Please try again.';
      
      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';
      
      case DioExceptionType.badCertificate:
        return 'There\'s a security issue. Please try again or contact support.';
      
      case DioExceptionType.unknown:
        // Check if it's a network error
        if (e.error != null) {
          final errorStr = e.error.toString().toLowerCase();
          if (errorStr.contains('socket') || 
              errorStr.contains('network') ||
              errorStr.contains('connection')) {
            return 'Please check your internet connection and try again.';
          }
        }
        return e.message ?? 'Something unexpected happened. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
