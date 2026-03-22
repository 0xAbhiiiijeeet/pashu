import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get maintenanceText => _settingsService.maintenanceText;
  bool get isMaintenanceMode => _settingsService.isMaintenanceMode;

  /// Fetch settings
  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _settingsService.fetchSettings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force refresh
  Future<void> forceRefresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _settingsService.forceRefresh();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
