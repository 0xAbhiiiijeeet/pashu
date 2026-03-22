import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ── Keys ──────────────────────────────────────────────────────────────────
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _phoneNumberKey = 'last_phone_number';
  static const String _loginTimestampKey = 'login_timestamp';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _authStatusKey = 'auth_status';
  static const String _userRoleKey = 'user_role';
  static const String _onboardingStepKey = 'onboarding_step';
  static const String _profileCompletionKey = 'profile_completion_percentage';
  static const String _firstLaunchKey = 'first_launch';
  static const String _appVersionKey = 'app_version';
  static const String _problemsKey = 'cached_problems';
  static const String _problemsCacheTimeKey = 'problems_cache_time';
  static const String _bookedCallsKey = 'cached_booked_calls';
  static const String _bookedCallsCacheTimeKey = 'booked_calls_cache_time';
  static const String _completedCallsKey = 'cached_completed_calls';
  static const String _completedCallsCacheTimeKey = 'completed_calls_cache_time';
  static const String _postsKey = 'cached_posts';
  static const String _postsCacheTimeKey = 'posts_cache_time';
  static const String _languageKey = 'app_language';

  final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;

  StorageService(this._secureStorage);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkFirstLaunch();
  }

  // ── First Launch ──────────────────────────────────────────────────────────
  Future<void> _checkFirstLaunch() async {
    if (!_prefs.containsKey(_firstLaunchKey)) {
      await _prefs.setBool(_firstLaunchKey, true);
    }
  }

  bool get isFirstLaunch => _prefs.getBool(_firstLaunchKey) ?? true;

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(_firstLaunchKey, false);
  }

  // ── Token Management ──────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _saveLoginTimestamp();
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  // ── User Data ─────────────────────────────────────────────────────────────
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, jsonEncode(userData));
    
    // Cache user role separately for quick access
    if (userData.containsKey('role')) {
      await _prefs.setString(_userRoleKey, userData['role'] as String);
    }
    
    // Update last sync timestamp
    await _updateLastSync();
  }

  Map<String, dynamic>? getUser() {
    final data = _prefs.getString(_userKey);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      // Debug: print the actual stored data
      print('📦 Stored user data: $decoded');
      return decoded;
    } catch (e) {
      // If JSON decode fails, clear corrupted data
      print('❌ Error decoding user data: $e');
      _prefs.remove(_userKey);
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_userRoleKey);
  }

  // ── User Role ─────────────────────────────────────────────────────────────
  String? get userRole => _prefs.getString(_userRoleKey);

  bool get isAdmin => userRole == 'admin';

  bool get isUser => userRole == 'user';

  // ── Phone Number ──────────────────────────────────────────────────────────
  Future<void> savePhoneNumber(String phoneNumber) async {
    await _prefs.setString(_phoneNumberKey, phoneNumber);
  }

  String? get lastPhoneNumber => _prefs.getString(_phoneNumberKey);

  Future<void> deletePhoneNumber() async {
    await _prefs.remove(_phoneNumberKey);
  }

  // ── Onboarding ────────────────────────────────────────────────────────────
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_onboardingKey, value);
    if (value) {
      await _prefs.setInt(_onboardingStepKey, 100); // 100% complete
    }
  }

  bool get isOnboardingComplete => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingStep(int step) async {
    await _prefs.setInt(_onboardingStepKey, step);
  }

  int get onboardingStep => _prefs.getInt(_onboardingStepKey) ?? 0;

  Future<void> resetOnboarding() async {
    await _prefs.setBool(_onboardingKey, false);
    await _prefs.setInt(_onboardingStepKey, 0);
  }

  // ── Profile Completion ────────────────────────────────────────────────────
  Future<void> setProfileCompletion(int percentage) async {
    await _prefs.setInt(_profileCompletionKey, percentage);
  }

  int get profileCompletion => _prefs.getInt(_profileCompletionKey) ?? 0;

  // ── Auth Status ───────────────────────────────────────────────────────────
  Future<void> saveAuthStatus(String status) async {
    await _prefs.setString(_authStatusKey, status);
  }

  String? get authStatus => _prefs.getString(_authStatusKey);

  // ── Timestamps ────────────────────────────────────────────────────────────
  Future<void> _saveLoginTimestamp() async {
    await _prefs.setInt(
      _loginTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  DateTime? get loginTimestamp {
    final timestamp = _prefs.getInt(_loginTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> _updateLastSync() async {
    await _prefs.setInt(
      _lastSyncKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  DateTime? get lastSyncTimestamp {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // ── Session Management ────────────────────────────────────────────────────
  Future<bool> hasValidSession() async {
    final token = await getToken();
    final user = getUser();
    return token != null && user != null;
  }

  bool isSessionExpired({Duration maxAge = const Duration(days: 30)}) {
    final loginTime = loginTimestamp;
    if (loginTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(loginTime);
    return difference > maxAge;
  }

  // ── App Version ───────────────────────────────────────────────────────────
  Future<void> saveAppVersion(String version) async {
    await _prefs.setString(_appVersionKey, version);
  }

  String? get appVersion => _prefs.getString(_appVersionKey);

  // ── Problems Cache ────────────────────────────────────────────────────────
  Future<void> saveProblems(List<Map<String, dynamic>> problems) async {
    await _prefs.setString(_problemsKey, jsonEncode(problems));
    await _prefs.setInt(
      _problemsCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<Map<String, dynamic>>? getProblems() {
    final data = _prefs.getString(_problemsKey);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error decoding problems cache: $e');
      _prefs.remove(_problemsKey);
      return null;
    }
  }

  DateTime? get problemsCacheTime {
    final timestamp = _prefs.getInt(_problemsCacheTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  bool isProblemsCacheStale({Duration maxAge = const Duration(hours: 24)}) {
    final cacheTime = problemsCacheTime;
    if (cacheTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    return difference > maxAge;
  }

  Future<void> clearProblemsCache() async {
    await _prefs.remove(_problemsKey);
    await _prefs.remove(_problemsCacheTimeKey);
  }

  // ── Booked Calls Cache ────────────────────────────────────────────────────
  Future<void> saveBookedCalls(List<Map<String, dynamic>> bookings) async {
    await _prefs.setString(_bookedCallsKey, jsonEncode(bookings));
    await _prefs.setInt(
      _bookedCallsCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<Map<String, dynamic>>? getBookedCalls() {
    final data = _prefs.getString(_bookedCallsKey);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error decoding booked calls cache: $e');
      _prefs.remove(_bookedCallsKey);
      return null;
    }
  }

  DateTime? get bookedCallsCacheTime {
    final timestamp = _prefs.getInt(_bookedCallsCacheTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  bool isBookedCallsCacheStale({Duration maxAge = const Duration(minutes: 30)}) {
    final cacheTime = bookedCallsCacheTime;
    if (cacheTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    return difference > maxAge;
  }

  Future<void> clearBookedCallsCache() async {
    await _prefs.remove(_bookedCallsKey);
    await _prefs.remove(_bookedCallsCacheTimeKey);
  }

  // ── Completed Calls Cache ─────────────────────────────────────────────────
  Future<void> saveCompletedCalls(List<Map<String, dynamic>> bookings) async {
    await _prefs.setString(_completedCallsKey, jsonEncode(bookings));
    await _prefs.setInt(
      _completedCallsCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<Map<String, dynamic>>? getCompletedCalls() {
    final data = _prefs.getString(_completedCallsKey);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error decoding completed calls cache: $e');
      _prefs.remove(_completedCallsKey);
      return null;
    }
  }

  DateTime? get completedCallsCacheTime {
    final timestamp = _prefs.getInt(_completedCallsCacheTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  bool isCompletedCallsCacheStale({Duration maxAge = const Duration(hours: 24)}) {
    final cacheTime = completedCallsCacheTime;
    if (cacheTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    return difference > maxAge;
  }

  Future<void> clearCompletedCallsCache() async {
    await _prefs.remove(_completedCallsKey);
    await _prefs.remove(_completedCallsCacheTimeKey);
  }

  // ── Posts Cache ───────────────────────────────────────────────────────────
  Future<void> savePosts(List<Map<String, dynamic>> posts) async {
    await _prefs.setString(_postsKey, jsonEncode(posts));
    await _prefs.setInt(
      _postsCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<Map<String, dynamic>>? getPosts() {
    final data = _prefs.getString(_postsKey);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error decoding posts cache: $e');
      _prefs.remove(_postsKey);
      return null;
    }
  }

  DateTime? get postsCacheTime {
    final timestamp = _prefs.getInt(_postsCacheTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  bool isPostsCacheStale({Duration maxAge = const Duration(hours: 1)}) {
    final cacheTime = postsCacheTime;
    if (cacheTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    return difference > maxAge;
  }

  Future<void> clearPostsCache() async {
    await _prefs.remove(_postsKey);
    await _prefs.remove(_postsCacheTimeKey);
  }

  // ── Language ──────────────────────────────────────────────────────────────
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  Future<String?> getLanguage() async {
    return _prefs.getString(_languageKey);
  }

  // ── Cache Management ──────────────────────────────────────────────────────
  Future<void> clearAuthCache() async {
    await deleteToken();
    await deleteUser();
    await deletePhoneNumber();
    await _prefs.remove(_loginTimestampKey);
    await _prefs.remove(_authStatusKey);
    await _prefs.remove(_userRoleKey);
  }

  Future<void> clearOnboardingCache() async {
    await _prefs.remove(_onboardingKey);
    await _prefs.remove(_onboardingStepKey);
    await _prefs.remove(_profileCompletionKey);
  }

  Future<void> clearAllDataCaches() async {
    await clearProblemsCache();
    await clearBookedCallsCache();
    await clearCompletedCallsCache();
    await clearPostsCache();
    print('🗑️ All data caches cleared');
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
    print('🗑️ All storage cleared');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final user = getUser();
    final token = await getToken();
    return user != null && token != null;
  }

  // Get all cached data for debugging
  Future<Map<String, dynamic>> getAllCachedData() async {
    final token = await getToken();
    return {
      'hasToken': token != null,
      'hasUser': getUser() != null,
      'isOnboardingComplete': isOnboardingComplete,
      'onboardingStep': onboardingStep,
      'profileCompletion': profileCompletion,
      'lastPhoneNumber': lastPhoneNumber,
      'userRole': userRole,
      'loginTimestamp': loginTimestamp?.toIso8601String(),
      'lastSyncTimestamp': lastSyncTimestamp?.toIso8601String(),
      'isFirstLaunch': isFirstLaunch,
      'appVersion': appVersion,
      'authStatus': authStatus,
    };
  }

  // Check if cache needs refresh
  bool needsCacheRefresh({Duration maxAge = const Duration(hours: 24)}) {
    final lastSync = lastSyncTimestamp;
    if (lastSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference > maxAge;
  }

  // Get cache status for all data
  Map<String, dynamic> getCacheStatus() {
    return {
      'problems': {
        'hasCachedData': getProblems() != null,
        'cacheTime': problemsCacheTime?.toIso8601String(),
        'isStale': isProblemsCacheStale(),
      },
      'bookedCalls': {
        'hasCachedData': getBookedCalls() != null,
        'cacheTime': bookedCallsCacheTime?.toIso8601String(),
        'isStale': isBookedCallsCacheStale(),
      },
      'completedCalls': {
        'hasCachedData': getCompletedCalls() != null,
        'cacheTime': completedCallsCacheTime?.toIso8601String(),
        'isStale': isCompletedCallsCacheStale(),
      },
      'posts': {
        'hasCachedData': getPosts() != null,
        'cacheTime': postsCacheTime?.toIso8601String(),
        'isStale': isPostsCacheStale(),
      },
    };
  }
}
