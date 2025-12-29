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
    Locale('fr', ''), // French
    Locale('es', ''), // Spanish
    Locale('pt', ''), // Portuguese
    Locale('zh', ''), // Chinese
    Locale('tr', ''), // Turkish
    Locale('ur', ''), // Urdu
    Locale('fa', ''), // Persian
    Locale('ja', ''), // Japanese
    Locale('de', ''), // German
    Locale('it', ''), // Italian
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
  String get unknownLocation =>
      _localizedValues[locale.languageCode]!['unknown_location']!;
  String get prayerTime =>
      _localizedValues[locale.languageCode]!['prayer_time']!;
  String get quran => _localizedValues[locale.languageCode]!['quran']!;
  String get readQuran => _localizedValues[locale.languageCode]!['read_quran']!;
  String get makki => _localizedValues[locale.languageCode]!['makki']!;
  String get madani => _localizedValues[locale.languageCode]!['madani']!;
  String get versesCount =>
      _localizedValues[locale.languageCode]!['verses_count']!;
  String get showTranslation =>
      _localizedValues[locale.languageCode]!['show_translation']!;
  String get translationLanguage =>
      _localizedValues[locale.languageCode]!['translation_language']!;

  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get locationFailed =>
      _localizedValues[locale.languageCode]!['location_failed']!;
  String get usingDefault =>
      _localizedValues[locale.languageCode]!['using_default']!;
  String get locationPermissionRequired =>
      _localizedValues[locale.languageCode]!['location_permission_required']!;
  String get locationPermissionDesc =>
      _localizedValues[locale.languageCode]!['location_permission_desc']!;
  String get details => _localizedValues[locale.languageCode]!['details']!;
  String get openSettings =>
      _localizedValues[locale.languageCode]!['open_settings']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;
  String get french => _localizedValues[locale.languageCode]!['french']!;
  String get spanish => _localizedValues[locale.languageCode]!['spanish']!;
  String get portuguese =>
      _localizedValues[locale.languageCode]!['portuguese']!;
  String get chinese => _localizedValues[locale.languageCode]!['chinese']!;
  String get turkish => _localizedValues[locale.languageCode]!['turkish']!;
  String get urdu => _localizedValues[locale.languageCode]!['urdu']!;
  String get persian => _localizedValues[locale.languageCode]!['persian']!;
  String get japanese => _localizedValues[locale.languageCode]!['japanese']!;
  String get german => _localizedValues[locale.languageCode]!['german']!;
  String get italian => _localizedValues[locale.languageCode]!['italian']!;
  String get calculationMethod =>
      _localizedValues[locale.languageCode]!['calculation_method']!;
  String get method => _localizedValues[locale.languageCode]!['method']!;
  String get auto => _localizedValues[locale.languageCode]!['auto']!;

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
      'app_name': 'Waqt',
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
      'unknown_location': 'Unknown Location',
      'prayer_time': 'Prayer Time',
      'quran': 'Quran',
      'read_quran': 'Read Quran',
      'makki': 'Makki',
      'madani': 'Madani',
      'verses_count': 'Verses',
      'show_translation': 'Show Translation',
      'translation_language': 'Translation Language',

      'error': 'Error',
      'location_failed': 'Location failed',
      'using_default': 'Using default',
      'location_permission_required': 'Location Permission Required',
      'location_permission_desc':
          'The app needs location permission to provide accurate prayer times.',
      'details': 'Details',
      'open_settings': 'Open Settings',
      'retry': 'Retry',
      'english': 'English',
      'arabic': 'Arabic',
      'french': 'French',
      'spanish': 'Spanish',
      'portuguese': 'Portuguese',
      'chinese': 'Chinese',
      'turkish': 'Turkish',
      'urdu': 'Urdu',
      'persian': 'Persian',
      'japanese': 'Japanese',
      'german': 'German',
      'italian': 'Italian',
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculation_method': 'Calculation Method',
      'method': 'Method',
      'auto': 'Auto',
    },
    'ar': {
      'app_name': 'وقت',
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
      'unknown_location': 'موقع غير معروف',
      'prayer_time': 'وقت الصلاة',
      'quran': 'القرآن الكريم',
      'read_quran': 'قراءة القرآن',
      'makki': 'مكية',
      'madani': 'مدنية',
      'verses_count': 'آيات',
      'show_translation': 'إظهار الترجمة',
      'translation_language': 'لغة الترجمة',

      'error': 'خطأ',
      'location_failed': 'فشل تحديد الموقع',
      'using_default': 'تم استخدام الموقع الافتراضي',
      'location_permission_required': 'مطلوب إذن الموقع',
      'location_permission_desc':
          'يحتاج التطبيق إلى إذن الموقع لتوفير مواقيت صلاة دقيقة.',
      'details': 'التفاصيل',
      'open_settings': 'افتح الإعدادات',
      'retry': 'إعادة المحاولة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'french': 'الفرنسية',
      'spanish': 'الإسبانية',
      'portuguese': 'البرتغالية',
      'chinese': 'الصينية',
      'turkish': 'التركية',
      'urdu': 'الأردية',
      'persian': 'الفارسية',
      'japanese': 'اليابانية',
      'german': 'الألمانية',
      'italian': 'الإيطالية',
      'fajr': 'الفجر',
      'sunrise': 'الشروق',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
      'calculation_method': 'طريقة الحساب',
      'method': 'الطريقة',
      'auto': 'تلقائي',
    },
    'fr': {
      'app_name': 'W Prayer',
      'next_prayer': 'PROCHAINE PRIÈRE',
      'next_prayer_time': 'Prochaine Prière',
      'default': 'Défaut',
      'enable_location': 'Activer la localisation',
      'permission_denied': 'Permission refusée',
      'locating': 'Localisation...',
      'settings': 'Paramètres',
      'language': 'Langue',
      'system_default': 'Défaut système',
      'select_language': 'Choisissez votre langue',
      'system_default_desc': 'Utiliser la langue de l\'appareil',
      'unknown_location': 'Lieu inconnu',
      'prayer_time': 'Heure de Prière',
      'quran': 'Coran',
      'read_quran': 'Lire le Coran',
      'makki': 'Makki',
      'madani': 'Madani',
      'verses_count': 'Versets',
      'show_translation': 'Afficher la traduction',
      'translation_language': 'Langue de traduction',

      'error': 'Erreur',
      'location_failed': 'Échec localisation',
      'using_default': 'Utilisation par défaut',
      'location_permission_required': 'Permission requise',
      'location_permission_desc':
          'L\'application a besoin de la permission de localisation pour les heures de prière exactes.',
      'details': 'Détails',
      'open_settings': 'Ouvrir les paramètres',
      'retry': 'Réessayer',
      'english': 'Anglais',
      'arabic': 'Arabe',
      'french': 'Français',
      'spanish': 'Espagnol',
      'portuguese': 'Portugais',
      'chinese': 'Chinois',
      'turkish': 'Turc',
      'urdu': 'Ourdou',
      'persian': 'Persan',
      'japanese': 'Japonais',
      'german': 'Allemand',
      'italian': 'Italien',
      'fajr': 'Fajr',
      'sunrise': 'Lever',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculation_method': 'Méthode de calcul',
      'method': 'Méthode',
      'auto': 'Auto',
    },
    'es': {
      'app_name': 'W Prayer',
      'next_prayer': 'PRÓXIMA ORACIÓN',
      'next_prayer_time': 'Próxima Oración',
      'default': 'Defecto',
      'enable_location': 'Habilitar ubicación',
      'permission_denied': 'Permiso denegado',
      'locating': 'Localizando...',
      'settings': 'Ajustes',
      'language': 'Idioma',
      'system_default': 'Predeterminado',
      'select_language': 'Selecciona tu idioma',
      'system_default_desc': 'Usar idioma del dispositivo',
      'unknown_location': 'Ubicación desconocida',
      'prayer_time': 'Hora de Oración',
      'quran': 'Corán',
      'read_quran': 'Leer el Corán',
      'makki': 'Makki',
      'madani': 'Madani',
      'verses_count': 'Versículos',
      'show_translation': 'Mostrar traducción',
      'translation_language': 'Idioma de traducción',

      'error': 'Error',
      'location_failed': 'Fallo de ubicación',
      'using_default': 'Usando defecto',
      'location_permission_required': 'Permiso requerido',
      'location_permission_desc':
          'La aplicación necesita permiso de ubicación para tiempos de oración precisos.',
      'details': 'Detalles',
      'open_settings': 'Abrir ajustes',
      'retry': 'Reintentar',
      'english': 'Inglés',
      'arabic': 'Árabe',
      'french': 'Francés',
      'spanish': 'Español',
      'portuguese': 'Portugués',
      'chinese': 'Chino',
      'turkish': 'Turco',
      'urdu': 'Urdu',
      'persian': 'Persa',
      'japanese': 'Japonés',
      'german': 'Alemán',
      'italian': 'Italiano',
      'fajr': 'Fajr',
      'sunrise': 'Amanecer',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculation_method': 'Método de cálculo',
      'method': 'Método',
      'auto': 'Auto',
    },
    'pt': {
      'app_name': 'W Prayer',
      'next_prayer': 'PRÓXIMA ORAÇÃO',
      'next_prayer_time': 'Próxima Oração',
      'default': 'Padrão',
      'enable_location': 'Ativar localização',
      'permission_denied': 'Permissão negada',
      'locating': 'Localizando...',
      'settings': 'Configurações',
      'language': 'Idioma',
      'system_default': 'Padrão do sistema',
      'select_language': 'Selecione seu idioma',
      'system_default_desc': 'Usar idioma do dispositivo',
      'unknown_location': 'Local desconhecido',
      'prayer_time': 'Hora de Oração',
      'quran': 'Alcorão',
      'read_quran': 'Ler o Alcorão',
      'makki': 'Makki',
      'madani': 'Madani',
      'verses_count': 'Versículos',
      'show_translation': 'Mostrar tradução',
      'translation_language': 'Idioma de tradução',

      'error': 'Erro',
      'location_failed': 'Falha na localização',
      'using_default': 'Usando padrão',
      'location_permission_required': 'Permissão necessária',
      'location_permission_desc':
          'O app precisa de permissão de localização para horários precisos.',
      'details': 'Detalhes',
      'open_settings': 'Abrir configurações',
      'retry': 'Tentar novamente',
      'english': 'Inglês',
      'arabic': 'Árabe',
      'french': 'Francês',
      'spanish': 'Espanhol',
      'portuguese': 'Português',
      'chinese': 'Chinês',
      'turkish': 'Turco',
      'urdu': 'Urdu',
      'persian': 'Persa',
      'japanese': 'Japonês',
      'german': 'Alemão',
      'italian': 'Italiano',
      'fajr': 'Fajr',
      'sunrise': 'Nascer do sol',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculation_method': 'Método de cálculo',
      'method': 'Método',
      'auto': 'Auto',
    },
    'zh': {
      'app_name': 'W Prayer',
      'next_prayer': '下次祈祷',
      'next_prayer_time': '下次祈祷时间',
      'default': '默认',
      'enable_location': '启用定位',
      'permission_denied': '权限被拒绝',
      'locating': '定位中...',
      'settings': '设置',
      'language': '语言',
      'system_default': '系统默认',
      'select_language': '选择您的语言',
      'system_default_desc': '使用设备语言',
      'unknown_location': '未知位置',
      'prayer_time': '祈祷时间',
      'quran': '古兰经',
      'read_quran': '阅读古兰经',
      'makki': '麦加',
      'madani': '麦地那',
      'verses_count': '诗篇',
      'show_translation': '显示翻译',
      'translation_language': '翻译语言',

      'error': '错误',
      'location_failed': '定位失败',
      'using_default': '使用默认',
      'location_permission_required': '需要定位权限',
      'location_permission_desc': '应用需要定位权限以提供准确的祈祷时间。',
      'details': '详情',
      'open_settings': '打开设置',
      'retry': '重试',
      'english': '英语',
      'arabic': '阿拉伯语',
      'french': '法语',
      'spanish': '西班牙语',
      'portuguese': '葡萄牙语',
      'chinese': '中文',
      'turkish': '土耳其语',
      'urdu': '乌尔都语',
      'persian': '波斯语',
      'japanese': '日语',
      'german': '德语',
      'italian': '意大利语',
      'fajr': 'Fajr',
      'sunrise': '日出',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculation_method': '计算方法',
      'method': '方法',
      'auto': '自动',
    },
    'tr': {
      'app_name': 'W Prayer',
      'next_prayer': 'SONRAKİ NAMAZ',
      'next_prayer_time': 'Sonraki Namaz Vakti',
      'default': 'Varsayılan',
      'enable_location': 'Konumu Etkinleştir',
      'permission_denied': 'İzin Reddedildi',
      'locating': 'Konum Bulunuyor...',
      'settings': 'Ayarlar',
      'language': 'Dil',
      'system_default': 'Sistem Varsayılanı',
      'select_language': 'Dil Seçin',
      'system_default_desc': 'Cihaz dilini kullan',
      'unknown_location': 'Bilinmeyen Konum',
      'prayer_time': 'Namaz Vakti',
      'quran': 'Kur\'an-ı Kerim',
      'read_quran': 'Kur\'an Oku',
      'makki': 'Mekki',
      'madani': 'Medeni',
      'verses_count': 'Ayet',
      'show_translation': 'Meali Göster',
      'translation_language': 'Meal Dili',

      'error': 'Hata',
      'location_failed': 'Konum Hatası',
      'using_default': 'Varsayılan Kullanılıyor',
      'location_permission_required': 'Konum İzni Gerekli',
      'location_permission_desc':
          'Uygulamanın doğru namaz vakitleri için konum iznine ihtiyacı var.',
      'details': 'Detaylar',
      'open_settings': 'Ayarları Aç',
      'retry': 'Tekrar Dene',
      'english': 'İngilizce',
      'arabic': 'Arapça',
      'french': 'Fransızca',
      'spanish': 'İspanyolca',
      'portuguese': 'Portekizce',
      'chinese': 'Çince',
      'turkish': 'Türkçe',
      'urdu': 'Urduca',
      'persian': 'Farsça',
      'japanese': 'Japonca',
      'german': 'Almanca',
      'italian': 'İtalyanca',
      'fajr': 'İmsak',
      'sunrise': 'Güneş',
      'dhuhr': 'Öğle',
      'asr': 'İkindi',
      'maghrib': 'Akşam',
      'isha': 'Yatsı',
      'calculation_method': 'Hesaplama Yöntemi',
      'method': 'Yöntem',
      'auto': 'Otomatik',
    },
    'ur': {
      'app_name': 'W Prayer',
      'next_prayer': 'اگلی نماز',
      'next_prayer_time': 'اگلی نماز کا وقت',
      'default': 'طے شدہ',
      'enable_location': 'مقام فعال کریں',
      'permission_denied': 'اجازت مسترد',
      'locating': 'مقام تلاش...',
      'settings': 'ترتیبات',
      'language': 'زبان',
      'system_default': 'سسٹم ڈیفالٹ',
      'select_language': 'اپنی زبان منتخب کریں',
      'system_default_desc': 'ڈیوائس کی زبان استعمال کریں',
      'unknown_location': 'نامعلوم مقام',
      'prayer_time': 'نماز کا وقت',
      'quran': 'قرآن مجید',
      'read_quran': 'قرآن پڑھیں',
      'makki': 'مکی',
      'madani': 'مدنی',
      'verses_count': 'آیات',
      'show_translation': 'ترجمہ دکھائیں',
      'translation_language': 'ترجمہ کی زبان',

      'error': 'غلطی',
      'location_failed': 'مقام ناکام',
      'using_default': 'طے شدہ استعمال',
      'location_permission_required': 'مقام کی اجازت درکار',
      'location_permission_desc':
          'درست نماز کے اوقات کے لیے ایپ کو مقام کی اجازت درکار ہے۔',
      'details': 'تفصیلات',
      'open_settings': 'ترتیبات کھولیں',
      'retry': 'دوبارہ کوشش',
      'english': 'انگریزی',
      'arabic': 'عربی',
      'french': 'فرانسیسی',
      'spanish': 'ہسپانوی',
      'portuguese': 'پرتگالی',
      'chinese': 'چینی',
      'turkish': 'ترکی',
      'urdu': 'اردو',
      'persian': 'فارسی',
      'japanese': 'جاپانی',
      'german': 'جرمن',
      'italian': 'اطالوی',
      'fajr': 'فجر',
      'sunrise': 'طلوع آفتاب',
      'dhuhr': 'ظہر',
      'asr': 'عصر',
      'maghrib': 'مغرب',
      'isha': 'عشاء',
      'calculation_method': 'حساب کا طریقہ',
      'method': 'طریقہ',
      'auto': 'خودکار',
    },
    'fa': {
      'app_name': 'W Prayer',
      'next_prayer': 'نماز بعدی',
      'next_prayer_time': 'وقت نماز بعدی',
      'default': 'پیش‌فرض',
      'enable_location': 'فعال‌سازی مکان',
      'permission_denied': 'مجوز رد شد',
      'locating': 'مکان‌یابی...',
      'settings': 'تنظیمات',
      'language': 'زبان',
      'system_default': 'پیش‌فرض سیستم',
      'select_language': 'زبان خود را انتخاب کنید',
      'system_default_desc': 'استفاده از زبان دستگاه',
      'unknown_location': 'مکان نامعلوم',
      'prayer_time': 'وقت نماز',
      'quran': 'قرآن کریم',
      'read_quran': 'تلاوت قرآن',
      'makki': 'مکی',
      'madani': 'مدنی',
      'verses_count': 'آیات',
      'show_translation': 'نمایش ترجمه',
      'translation_language': 'زبان ترجمه',

      'error': 'خطا',
      'location_failed': 'مکان‌یابی ناموفق',
      'using_default': 'استفاده از پیش‌فرض',
      'location_permission_required': 'مجوز مکان لازم است',
      'location_permission_desc':
          'برنامه برای اوقات شرعی دقیق به مجوز مکان نیاز دارد.',
      'details': 'جزئیات',
      'open_settings': 'باز کردن تنظیمات',
      'retry': 'تلاش مجدد',
      'english': 'انگلیسی',
      'arabic': 'عربی',
      'french': 'فرانسوی',
      'spanish': 'اسپانیایی',
      'portuguese': 'پرتغالی',
      'chinese': 'چینی',
      'turkish': 'ترکی',
      'urdu': 'اردو',
      'persian': 'فارسی',
      'japanese': 'ژاپنی',
      'german': 'آلمانی',
      'italian': 'ایتالیایی',
      'fajr': 'اذان صبح',
      'sunrise': 'طلوع آفتاب',
      'dhuhr': 'اذان ظهر',
      'asr': 'عصر',
      'maghrib': 'اذان مغرب',
      'isha': 'اذان عشا',
      'calculation_method': 'روش محاسبه',
      'method': 'روش',
      'auto': 'خودکار',
    },
    'ja': {
      'app_name': 'W Prayer',
      'next_prayer': '次の礼拝',
      'next_prayer_time': '次の礼拝時間',
      'default': 'デフォルト',
      'enable_location': '位置情報を有効化',
      'permission_denied': '許可が拒否されました',
      'locating': '位置を特定中...',
      'settings': '設定',
      'language': '言語',
      'system_default': 'システム設定',
      'select_language': '言語を選択',
      'system_default_desc': 'デバイスの言語を使用',
      'unknown_location': '不明な場所',
      'prayer_time': '礼拝時間',
      'quran': 'クルアーン',
      'read_quran': 'クルアーンを読む',
      'makki': 'マッカ期',
      'madani': 'マディーナ期',
      'verses_count': '節',
      'show_translation': '翻訳を表示',
      'translation_language': '翻訳言語',

      'error': 'エラー',
      'location_failed': '位置情報の取得に失敗',
      'using_default': 'デフォルトを使用中',
      'location_permission_required': '位置情報の許可が必要です',
      'location_permission_desc': '正確な礼拝時間を提供するために位置情報の許可が必要です。',
      'details': '詳細',
      'open_settings': '設定を開く',
      'retry': '再試行',
      'english': '英語',
      'arabic': 'アラビア語',
      'french': 'フランス語',
      'spanish': 'スペイン語',
      'portuguese': 'ポルトガル語',
      'chinese': '中国語',
      'turkish': 'トルコ語',
      'urdu': 'ウルドゥー語',
      'persian': 'ペルシア語',
      'japanese': '日本語',
      'german': 'ドイツ語',
      'italian': 'イタリア語',
      'fajr': 'ファジル',
      'sunrise': '日の出',
      'dhuhr': 'ズフル',
      'asr': 'アスル',
      'maghrib': 'マグリブ',
      'isha': 'イシャ',
      'calculation_method': '計算方法',
      'method': '方法',
      'auto': '自動',
    },
    'de': {
      'app_name': 'W Prayer',
      'next_prayer': 'NÄCHSTES GEBET',
      'next_prayer_time': 'Nächste Gebetszeit',
      'default': 'Standard',
      'enable_location': 'Standort aktivieren',
      'permission_denied': 'Berechtigung verweigert',
      'locating': 'Standortermittlung...',
      'settings': 'Einstellungen',
      'language': 'Sprache',
      'system_default': 'Systemstandard',
      'select_language': 'Wähle deine Sprache',
      'system_default_desc': 'Gerätesprache verwenden',
      'unknown_location': 'Unbekannter Ort',
      'prayer_time': 'Gebetszeit',
      'quran': 'Koran',
      'read_quran': 'Koran lesen',
      'makki': 'Mekkanisch',
      'madani': 'Medinisch',
      'verses_count': 'Verse',
      'show_translation': 'Übersetzung anzeigen',
      'translation_language': 'Übersetzungssprache',

      'error': 'Fehler',
      'location_failed': 'Standort fehlgeschlagen',
      'using_default': 'Standard wird verwendet',
      'location_permission_required': 'Standortberechtigung erforderlich',
      'location_permission_desc':
          'Die App benötigt den Standort für genaue Gebetszeiten.',
      'details': 'Details',
      'open_settings': 'Einstellungen öffnen',
      'retry': 'Wiederholen',
      'english': 'Englisch',
      'arabic': 'Arabisch',
      'french': 'Französisch',
      'spanish': 'Spanisch',
      'portuguese': 'Portugiesisch',
      'chinese': 'Chinesisch',
      'turkish': 'Türkisch',
      'urdu': 'Urdu',
      'persian': 'Persisch',
      'japanese': 'Japanisch',
      'german': 'Deutsch',
      'italian': 'Italienisch',
      'fajr': 'Fajr',
      'sunrise': 'Sonnenaufgang',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculation_method': 'Berechnungsmethode',
      'method': 'Methode',
      'auto': 'Auto',
    },
    'it': {
      'app_name': 'W Prayer',
      'next_prayer': 'PROSSIMA PREGHIERA',
      'next_prayer_time': 'Ora Prossima Preghiera',
      'default': 'Predefinito',
      'enable_location': 'Attiva Posizione',
      'permission_denied': 'Permesso Negato',
      'locating': 'Localizzazione...',
      'settings': 'Impostazioni',
      'language': 'Lingua',
      'system_default': 'Predefinito di Sistema',
      'select_language': 'Seleziona la lingua',
      'system_default_desc': 'Usa la lingua del dispositivo',
      'unknown_location': 'Posizione Sconosciuta',
      'prayer_time': 'Ora della Preghiera',
      'quran': 'Corano',
      'read_quran': 'Leggi il Corano',
      'makki': 'Meccana',
      'madani': 'Medinese',
      'verses_count': 'Versetti',
      'show_translation': 'Mostra traduzione',
      'translation_language': 'Lingua traduzione',

      'error': 'Errore',
      'location_failed': 'Posizione Fallita',
      'using_default': 'Uso predefinito',
      'location_permission_required': 'Permesso Posizione Richiesto',
      'location_permission_desc':
          'L\'app necessita del permesso di posizione per orari precisi.',
      'details': 'Dettagli',
      'open_settings': 'Apri Impostazioni',
      'retry': 'Riprova',
      'english': 'Inglese',
      'arabic': 'Arabo',
      'french': 'Francese',
      'spanish': 'Spagnolo',
      'portuguese': 'Portoghese',
      'chinese': 'Cinese',
      'turkish': 'Turco',
      'urdu': 'Urdu',
      'persian': 'Persiano',
      'japanese': 'Giapponese',
      'german': 'Tedesco',
      'italian': 'Italiano',
      'fajr': 'Fajr',
      'sunrise': 'Alba',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculation_method': 'Metodo di Calcolo',
      'method': 'Metodo',
      'auto': 'Auto',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'ar',
      'fr',
      'es',
      'pt',
      'zh',
      'tr',
      'ur',
      'fa',
      'ja',
      'de',
      'it',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
