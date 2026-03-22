import 'package:flutter/material.dart';
import '../storage/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final StorageService _storageService;
  Locale _locale = const Locale('hi', ''); // Default to Hindi

  LocaleProvider(this._storageService) {
    // Load locale asynchronously without blocking
    Future.microtask(() => _loadLocale());
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final languageCode = await _storageService.getLanguage();
    if (languageCode != null) {
      _locale = Locale(languageCode, '');
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _storageService.saveLanguage(locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'en'
        ? const Locale('hi', '')
        : const Locale('en', '');
    await setLocale(newLocale);
  }
}
