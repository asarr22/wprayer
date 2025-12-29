import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:wprayer/providers/quran_settings_provider.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';

class QuranTranslationScreen extends ConsumerWidget {
  const QuranTranslationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentSettings = ref.watch(quranSettingsProvider);
    final languages = QuranLanguage.values;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translationLanguage),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(WSizes.padding),
        itemCount: languages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected = currentSettings.translationLanguage == language;

          return InkWell(
            onTap: () {
              ref
                  .read(quranSettingsProvider.notifier)
                  .setTranslationLanguage(language);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? WColors.primary.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: WColors.primary.withValues(alpha: 0.5))
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                    language.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? WColors.primary : Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check, color: WColors.primary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
