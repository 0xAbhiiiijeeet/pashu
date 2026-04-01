import 'package:flutter/foundation.dart';
import '../services/remote_config_service.dart';

class RemoteConfigProvider extends ChangeNotifier {
  final RemoteConfigService _remoteConfigService = RemoteConfigService.instance;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  RemoteConfigProvider() {
    final values = _remoteConfigService.getAllValues();
    _isInitialized = values['status'] == 'initialized';
    final fetchTime = values['last_fetch_time']?.toString();
    if (fetchTime != null) {
      _lastFetchTime = DateTime.tryParse(fetchTime);
    }
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  String get baseUrl => _remoteConfigService.baseUrl;
  String get appUrl => _remoteConfigService.appUrl;

  /// Initialize Remote Config
  Future<void> initialize() async {
    _setLoading(true);
    _error = null;
    
    try {
      await _remoteConfigService.initialize();
      _isInitialized = true;
      _lastFetchTime = DateTime.now();
      debugPrint('✅ RemoteConfigProvider: Initialized successfully');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ RemoteConfigProvider: Failed to initialize - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch and activate new values
  Future<bool> fetchAndActivate() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RemoteConfigProvider: Not initialized, cannot fetch');
      return false;
    }

    _setLoading(true);
    _error = null;
    
    try {
      final updated = await _remoteConfigService.fetchAndActivate();
      _lastFetchTime = DateTime.now();
      
      if (updated) {
        debugPrint('✅ RemoteConfigProvider: Values updated');
        notifyListeners(); // Notify listeners about new values
      } else {
        debugPrint('ℹ️ RemoteConfigProvider: No updates available');
      }
      
      return updated;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ RemoteConfigProvider: Failed to fetch - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Force refresh (bypasses minimum fetch interval)
  Future<bool> forceRefresh() async {
    if (!_isInitialized) {
      debugPrint('⚠️ RemoteConfigProvider: Not initialized, cannot force refresh');
      return false;
    }

    _setLoading(true);
    _error = null;
    
    try {
      final updated = await _remoteConfigService.forceRefresh();
      _lastFetchTime = DateTime.now();
      
      if (updated) {
        debugPrint('✅ RemoteConfigProvider: Force refresh successful');
        notifyListeners(); // Notify listeners about new values
      } else {
        debugPrint('ℹ️ RemoteConfigProvider: Force refresh - no updates');
      }
      
      return updated;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ RemoteConfigProvider: Force refresh failed - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get all config values for debugging
  Map<String, dynamic> getAllValues() {
    return _remoteConfigService.getAllValues();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
