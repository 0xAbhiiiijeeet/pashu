import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static SettingsService get instance => _instance;

  String? _maintenanceText;
  bool _isMaintenanceMode = false;
  bool _isOtpBypassed = false;
  DateTime? _lastFetchTime;

  static const Duration _cacheDuration = Duration(minutes: 5);

  String? get maintenanceText => _maintenanceText;
  bool get isMaintenanceMode => _isMaintenanceMode;
  bool get isOtpBypassed => _isOtpBypassed;

  Future<void> fetchSettings() async {
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      debugPrint('Using cached settings');
      return;
    }

    try {
      debugPrint('Fetching app settings...');

      final response = await DioClient.instance.get(ApiEndpoints.settings);
      if (response.statusCode != 200) return;

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final settings = data['data'] as Map<String, dynamic>;
        _maintenanceText = settings['maintenanceText'] as String? ?? '';
        _isMaintenanceMode = settings['isMaintenanceMode'] as bool? ?? false;
        _isOtpBypassed = settings['isOtpBypassed'] as bool? ?? false;
        _lastFetchTime = DateTime.now();
      }
    } catch (e) {
      debugPrint('Failed to fetch settings: $e');
    }
  }

  Future<void> forceRefresh() async {
    _lastFetchTime = null;
    await fetchSettings();
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    final response = await DioClient.instance.put(
      ApiEndpoints.settings,
      data: settings,
    );
    _lastFetchTime = null;
    await fetchSettings();
    return response.data as Map<String, dynamic>;
  }

  void clearMaintenanceMode() {
    _maintenanceText = null;
    _isMaintenanceMode = false;
    _isOtpBypassed = false;
    _lastFetchTime = null;
  }
}
