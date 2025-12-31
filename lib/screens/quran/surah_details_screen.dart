import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:wprayer/providers/quran_settings_provider.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';

class SurahDetailsScreen extends ConsumerWidget {
  final Surah surah;

  const SurahDetailsScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get settings
    final settings = ref.watch(quranSettingsProvider);

    // Get verses for this surah
    final verses = Quran.getSurahVersesAsList(surah.number);
    List<Verse>? translatedVerses;

    if (settings.showTranslation) {
      translatedVerses = Quran.getSurahVersesAsList(
        surah.number,
        language: settings.translationLanguage,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(surah.nameEnglish, style: const TextStyle(fontSize: 18)),
            Text(
              surah.name,
              style: const TextStyle(fontSize: 14, color: WColors.primary),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(WSizes.padding),
              itemCount: verses.length + 1,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white10, height: 32),
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (surah.number != 9 && surah.number != 1) {
                    return Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: WColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const SizedBox(height: 20);
                }

                // Adjust index for verses array
                final verseIndex = index - 1;
                final verse = verses[verseIndex];
                final translatedVerse = translatedVerses?[verseIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      verse.text,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    if (translatedVerse != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        translatedVerse.text,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: WColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${surah.number}:$index',
                            style: const TextStyle(
                              color: WColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
