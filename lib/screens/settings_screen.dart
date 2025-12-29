import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wprayer/providers/locale_provider.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'package:wprayer/screens/language_screen.dart';
import 'package:wprayer/screens/calculation_method_screen.dart';
import 'package:wprayer/services/notification_service.dart';

import 'package:wprayer/providers/quran_settings_provider.dart';
import 'package:wprayer/screens/quran/quran_translation_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final quranSettings = ref.watch(quranSettingsProvider);

    // Get current language name
    String currentLanguage = loc.systemDefault;
    if (locale?.languageCode == 'en') {
      currentLanguage = loc.english;
    } else if (locale?.languageCode == 'ar') {
      currentLanguage = loc.arabic;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
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
              const SizedBox(height: WSizes.spaceBetweenItems),
              FutureBuilder<String?>(
                future: _getCalculationMethod(),
                builder: (context, snapshot) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.calculate,
                    title: loc.calculationMethod,
                    subtitle: "${snapshot.data ?? 'MWL'} (${loc.auto})",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalculationMethodScreen(),
                        ),
                      ).then((_) {});
                    },
                  );
                },
              ),
              const SizedBox(height: WSizes.spaceBetweenItems),
              _buildToggleItem(
                context,
                icon: Icons.translate,
                title: loc.showTranslation,
                value: quranSettings.showTranslation,
                onChanged: (value) {
                  ref
                      .read(quranSettingsProvider.notifier)
                      .toggleShowTranslation(value);
                },
              ),
              if (quranSettings.showTranslation) ...[
                const SizedBox(height: WSizes.spaceBetweenItems),
                _buildSettingItem(
                  context,
                  icon: Icons.language,
                  title: loc.translationLanguage,
                  subtitle: quranSettings.translationLanguage.name
                      .toUpperCase(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuranTranslationScreen(),
                      ),
                    );
                  },
                ),
              ],

              if (kDebugMode) ...[
                const SizedBox(height: WSizes.spaceBetweenItems),
                Text("Debug", style: TextStyle(color: Colors.redAccent)),
                const SizedBox(height: WSizes.spaceBetweenItems),
                _buildSettingItem(
                  context,
                  icon: Icons.notifications_active,
                  title: "Native Test Notification",
                  subtitle: "Schedules a test in 3 seconds",
                  onTap: () async {
                    await NotificationService().showTestNotification();
                  },
                ),
                const SizedBox(height: WSizes.spaceBetweenItems),
                _buildSettingItem(
                  context,
                  icon: Icons.flash_on,
                  title: "Instant Native Test",
                  subtitle: "Show notification NOW",
                  onTap: () async {
                    await NotificationService()
                        .triggerInstantNativeNotification();
                  },
                ),
              ],

              const SizedBox(height: WSizes.spaceBetweenItems),
              _buildSettingItem(
                context,
                icon: Icons.security,
                title: "Request Permission",
                subtitle: "Ask for notification permissions",
                onTap: () async {
                  await NotificationService().requestPermission();
                },
              ),
              const SizedBox(height: WSizes.spaceBetweenItems),
              _buildSettingItem(
                context,
                icon: Icons.settings_applications,
                title: "App Settings",
                subtitle: "Go to app settings",
                onTap: () async {
                  await NotificationService().openSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: WColors.primary,
            activeThumbColor: Colors.white,
          ),
        ],
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

  Future<String?> _getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('calculation_method');
  }
}
