import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      // System default
      _locale = null;
    } else {
      _locale = locale;
    }

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('language_code');
      await prefs.remove('flutter.language_code');
    } else {
      await prefs.setString('language_code', locale.languageCode);
      // Also save with flutter. prefix for native complication access
      await prefs.setString('flutter.language_code', locale.languageCode);
    }

    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}
