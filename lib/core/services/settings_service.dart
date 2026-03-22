import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static SettingsService get instance => _instance;
  
  String? _maintenanceText;
  bool _isMaintenanceMode = false;
  DateTime? _lastFetchTime;
  
  // Cache duration: 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get maintenance text (with caching)
  String? get maintenanceText => _maintenanceText;
  
  /// Check if app is in maintenance mode
  bool get isMaintenanceMode => _isMaintenanceMode;

  /// Fetch settings from API
  Future<void> fetchSettings() async {
    // Check cache validity
    if (_lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      debugPrint('⚡ Using cached settings');
      return;
    }

    try {
      debugPrint('🔄 Fetching app settings...');
      
      final response = await DioClient.instance.dio.get('/api/settings');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final settings = data['data'] as Map<String, dynamic>;
          _maintenanceText = settings['maintenanceText'] as String? ?? '';
          _isMaintenanceMode = settings['isMaintenanceMode'] as bool? ?? false;
          _lastFetchTime = DateTime.now();
          
          if (_isMaintenanceMode) {
            debugPrint('🚧 Maintenance mode active: $_maintenanceText');
          } else {
            debugPrint('✅ App is operational');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch settings: $e');
      // Don't throw - app should work even if settings fetch fails
    }
  }

  /// Force refresh settings (bypass cache)
  Future<void> forceRefresh() async {
    debugPrint('🔄 Force refresh requested - clearing cache');
    _lastFetchTime = null;
    await fetchSettings();
    debugPrint('✅ Force refresh completed - isMaintenanceMode: $_isMaintenanceMode');
  }

  /// Clear maintenance mode (for testing)
  void clearMaintenanceMode() {
    _maintenanceText = null;
    _isMaintenanceMode = false;
    _lastFetchTime = null;
  }
}
