import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'package:wprayer/utils/localization/locale_provider.dart';
import 'package:wprayer/screens/language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Get current language name
    String currentLanguage = loc.systemDefault;
    if (localeProvider.locale?.languageCode == 'en') {
      currentLanguage = 'English';
    } else if (localeProvider.locale?.languageCode == 'ar') {
      currentLanguage = 'العربية';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(WSizes.padding / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingItem(
                context,
                icon: Icons.language,
                title: loc.language,
                subtitle: currentLanguage,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WSizes.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(WSizes.padding / 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(WSizes.borderRadius),
        ),
        child: Row(
          children: [
            Icon(icon, color: WColors.primary, size: WSizes.iconSize),
            const SizedBox(width: WSizes.spaceBetweenItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.5),
              size: WSizes.iconSize,
            ),
          ],
        ),
      ),
    );
  }
}
