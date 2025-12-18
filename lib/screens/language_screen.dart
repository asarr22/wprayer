import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wprayer/providers/locale_provider.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    // Define available languages
    final languages = [
      LanguageOption(
        title: loc.systemDefault,
        subtitle: loc.systemDefaultDesc,
        locale: null,
      ),
      LanguageOption(
        title: 'English',
        subtitle: loc.english,
        locale: const Locale('en'),
      ),
      LanguageOption(
        title: 'العربية',
        subtitle: loc.arabic,
        locale: const Locale('ar'),
      ),
    ];

    return Scaffold(
      backgroundColor: WColors.backgroundDark,
      appBar: AppBar(
        title: Text(loc.language),
        backgroundColor: WColors.backgroundDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(WSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.selectLanguage,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: WSizes.spaceBetweenSections),
              ...languages.asMap().entries.map((entry) {
                final index = entry.key;
                final language = entry.value;

                return Column(
                  children: [
                    _buildLanguageOption(
                      context,
                      title: language.title,
                      subtitle: language.subtitle,
                      locale: language.locale,
                      currentLocale: locale,
                      onTap: () => localeNotifier.setLocale(language.locale),
                    ),
                    if (index < languages.length - 1)
                      const SizedBox(height: WSizes.spaceBetweenItems),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Locale? locale,
    required Locale? currentLocale,
    required VoidCallback onTap,
  }) {
    final isSelected =
        (locale == null && currentLocale == null) ||
        (locale != null && currentLocale?.languageCode == locale.languageCode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WSizes.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(WSizes.padding / 2),
        decoration: BoxDecoration(
          color: isSelected
              ? WColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(WSizes.borderRadius),
          border: isSelected
              ? Border.all(color: WColors.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: WColors.primary,
                size: WSizes.iconSize,
              ),
          ],
        ),
      ),
    );
  }
}

/// Model class for language options
class LanguageOption {
  final String title;
  final String subtitle;
  final Locale? locale;

  const LanguageOption({
    required this.title,
    required this.subtitle,
    required this.locale,
  });
}
