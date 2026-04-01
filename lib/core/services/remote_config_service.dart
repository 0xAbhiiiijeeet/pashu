import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  static RemoteConfigService get instance => _instance;

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  // Default values
  static const String _defaultBaseUrl = 'http://13.222.160.206:1234/';
  static const String _defaultAppUrl =
      'https://drive.google.com/file/d/1PpHB8_I07gNTKj-j0DII9JEJ5lThZ-a4/view?usp=drive_link';

  // Remote config keys
  static const String _baseUrlKey = 'base_url';
  static const String _appUrlKey = 'app_url';

  /// Initialize Firebase Remote Config
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      debugPrint('🔧 Initializing Firebase Remote Config...');

      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set config settings
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? const Duration(seconds: 10) // Short interval for debug
            : const Duration(hours: 1), // 1 hour for production
      ));

      // Set default values
      await _remoteConfig!.setDefaults({
        _baseUrlKey: _defaultBaseUrl,
        _appUrlKey: _defaultAppUrl,
      });

      // Fetch and activate
      await _fetchAndActivate();

      _initialized = true;
      debugPrint('✅ Firebase Remote Config initialized successfully');
      debugPrint('📡 Base URL: ${baseUrl}');
      debugPrint('📱 App URL: ${appUrl}');
    } catch (e) {
      debugPrint('❌ Failed to initialize Firebase Remote Config: $e');
      // Continue with default values
      _initialized = true;
    }
  }

  /// Fetch and activate remote config
  Future<bool> fetchAndActivate() async {
    if (!_initialized || _remoteConfig == null) {
      debugPrint('⚠️ Remote Config not initialized, using defaults');
      return false;
    }

    return await _fetchAndActivate();
  }

  Future<bool> _fetchAndActivate() async {
    try {
      debugPrint('🔄 Fetching remote config...');

      final bool updated = await _remoteConfig!.fetchAndActivate();

      if (updated) {
        debugPrint('✅ Remote config updated successfully');
        debugPrint('📡 New Base URL: ${baseUrl}');
        debugPrint('📱 New App URL: ${appUrl}');
      } else {
        debugPrint('ℹ️ Remote config values are up to date');
      }

      return updated;
    } catch (e) {
      debugPrint('❌ Failed to fetch remote config: $e');
      return false;
    }
  }

  /// Get base URL for API calls
  String get baseUrl {
    if (!_initialized || _remoteConfig == null) {
      debugPrint('⚠️ Remote Config not ready, using default base URL');
      return _defaultBaseUrl;
    }

    final url = _remoteConfig!.getString(_baseUrlKey);
    return url.isNotEmpty ? url : _defaultBaseUrl;
  }

  /// Get app URL for sharing
  String get appUrl {
    if (!_initialized || _remoteConfig == null) {
      debugPrint('⚠️ Remote Config not ready, using default app URL');
      return _defaultAppUrl;
    }

    final url = _remoteConfig!.getString(_appUrlKey);
    return url.isNotEmpty ? url : _defaultAppUrl;
  }

  /// Get all remote config values (for debugging)
  Map<String, dynamic> getAllValues() {
    if (!_initialized || _remoteConfig == null) {
      return {
        _baseUrlKey: _defaultBaseUrl,
        _appUrlKey: _defaultAppUrl,
        'status': 'not_initialized',
      };
    }

    return {
      _baseUrlKey: baseUrl,
      _appUrlKey: appUrl,
      'status': 'initialized',
      'last_fetch_time': _remoteConfig!.lastFetchTime.toIso8601String(),
      'last_fetch_status': _remoteConfig!.lastFetchStatus.toString(),
    };
  }

  /// Force refresh (useful for testing)
  Future<bool> forceRefresh() async {
    if (!_initialized || _remoteConfig == null) return false;

    try {
      debugPrint('🔄 Force refreshing remote config...');

      // Reset minimum fetch interval for immediate fetch
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      final bool updated = await _remoteConfig!.fetchAndActivate();

      // Restore normal fetch interval
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? const Duration(seconds: 10) : const Duration(hours: 1),
      ));

      if (updated) {
        debugPrint('✅ Force refresh successful');
      } else {
        debugPrint('ℹ️ No updates available');
      }

      return updated;
    } catch (e) {
      debugPrint('❌ Force refresh failed: $e');
      return false;
    }
  }
}
