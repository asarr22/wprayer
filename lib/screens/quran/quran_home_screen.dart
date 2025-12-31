import 'package:flutter/material.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'surah_details_screen.dart';

class QuranHomeScreen extends StatelessWidget {
  const QuranHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final surahs = Quran.getSurahAsList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.quran),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: WSizes.padding),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(WSizes.padding / 2),
              // leading: Container(
              //   width: 40,
              //   height: 40,
              //   decoration: BoxDecoration(
              //     color: WColors.primary.withValues(alpha: 0.1),
              //     shape: BoxShape.circle,
              //   ),
              //   child: Center(
              //     child: Text(
              //       (index + 1).toString(),
              //       style: const TextStyle(
              //         color: WColors.primary,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
              title: Text(
                surah.nameEnglish,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${Quran.isMakkiSurah(index + 1) ? loc.makki : loc.madani} • ${Quran.getTotalVersesInSurah(index + 1)} ${loc.versesCount}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),

              trailing: Text(
                surah.name,
                style: const TextStyle(
                  fontFamily:
                      'Amiri', // Assuming there's an Arabic font or default
                  fontSize: 16,
                  color: WColors.primary,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailsScreen(surah: surah),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
