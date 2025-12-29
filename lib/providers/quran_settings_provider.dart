import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_flutter/quran_flutter.dart';

class QuranSettings {
  final bool showTranslation;
  final QuranLanguage translationLanguage;

  QuranSettings({
    required this.showTranslation,
    required this.translationLanguage,
  });

  QuranSettings copyWith({
    bool? showTranslation,
    QuranLanguage? translationLanguage,
  }) {
    return QuranSettings(
      showTranslation: showTranslation ?? this.showTranslation,
      translationLanguage: translationLanguage ?? this.translationLanguage,
    );
  }
}

class QuranSettingsNotifier extends StateNotifier<QuranSettings> {
  QuranSettingsNotifier()
    : super(
        QuranSettings(
          showTranslation: false,
          translationLanguage: QuranLanguage.english,
        ),
      ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final show = prefs.getBool('quran_show_translation') ?? false;
    final langStr = prefs.getString('quran_translation_language') ?? 'english';

    QuranLanguage lang = QuranLanguage.english;
    try {
      lang = QuranLanguage.values.firstWhere(
        (e) => e.name.toLowerCase() == langStr.toLowerCase(),
      );
    } catch (_) {}

    state = QuranSettings(showTranslation: show, translationLanguage: lang);
  }

  Future<void> toggleShowTranslation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quran_show_translation', value);
    state = state.copyWith(showTranslation: value);
  }

  Future<void> setTranslationLanguage(QuranLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_translation_language', lang.name);
    state = state.copyWith(translationLanguage: lang);
  }
}

final quranSettingsProvider =
    StateNotifierProvider<QuranSettingsNotifier, QuranSettings>((ref) {
      return QuranSettingsNotifier();
    });
