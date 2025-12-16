import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
  ];

  // App texts
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get nextPrayer =>
      _localizedValues[locale.languageCode]!['next_prayer']!;
  String get nextPrayerTime =>
      _localizedValues[locale.languageCode]!['next_prayer_time']!;
  String get defaultLocation =>
      _localizedValues[locale.languageCode]!['default']!;
  String get enableLocation =>
      _localizedValues[locale.languageCode]!['enable_location']!;
  String get permissionDenied =>
      _localizedValues[locale.languageCode]!['permission_denied']!;
  String get locating => _localizedValues[locale.languageCode]!['locating']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get systemDefault =>
      _localizedValues[locale.languageCode]!['system_default']!;
  String get selectLanguage =>
      _localizedValues[locale.languageCode]!['select_language']!;
  String get systemDefaultDesc =>
      _localizedValues[locale.languageCode]!['system_default_desc']!;

  // Prayer names
  String get fajr => _localizedValues[locale.languageCode]!['fajr']!;
  String get sunrise => _localizedValues[locale.languageCode]!['sunrise']!;
  String get dhuhr => _localizedValues[locale.languageCode]!['dhuhr']!;
  String get asr => _localizedValues[locale.languageCode]!['asr']!;
  String get maghrib => _localizedValues[locale.languageCode]!['maghrib']!;
  String get isha => _localizedValues[locale.languageCode]!['isha']!;

  String getPrayerName(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return prayer;
    }
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'W Prayer',
      'next_prayer': 'NEXT PRAYER',
      'next_prayer_time': 'Next Prayer Time',
      'default': 'Default',
      'enable_location': 'Enable Location',
      'permission_denied': 'Permission Denied',
      'locating': 'Locating...',
      'settings': 'Settings',
      'language': 'Language',
      'system_default': 'System Default',
      'select_language': 'Select your preferred language',
      'system_default_desc': 'Use device language',
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    },
    'ar': {
      'app_name': 'الصلاة',
      'next_prayer': 'الصلاة القادمة',
      'next_prayer_time': 'وقت الصلاة القادمة',
      'default': 'افتراضي',
      'enable_location': 'تفعيل الموقع',
      'permission_denied': 'تم رفض الإذن',
      'locating': 'تحديد الموقع...',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'system_default': 'لغة النظام',
      'select_language': 'اختر لغتك المفضلة',
      'system_default_desc': 'اتبع لغة الجهاز',
      'fajr': 'الفجر',
      'sunrise': 'الشروق',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
