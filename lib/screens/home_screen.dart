import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'package:wprayer/screens/prayer_time_screen.dart';
import 'package:wprayer/screens/settings_screen.dart';
import 'package:wprayer/screens/quran/quran_home_screen.dart';
import 'package:wprayer/screens/qibla_finder.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(WSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    loc.appName,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: WSizes.spaceBetweenSections),
                _mainMenuItem(
                  context,
                  icon: Icons.access_time_filled,
                  title: loc.prayerTime,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PTScreen()),
                  ),
                ),
                const SizedBox(height: WSizes.spaceBetweenItems),
                _mainMenuItem(
                  context,
                  icon: Icons.menu_book_rounded,
                  title: loc.quran,
                  subtitle: loc.readQuran,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuranHomeScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: WSizes.spaceBetweenItems),
                _mainMenuItem(
                  context,
                  icon: Icons.explore_rounded,
                  title: loc.qiblaFinder,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QiblaFinderScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: WSizes.spaceBetweenItems),
                _mainMenuItem(
                  context,
                  icon: Icons.settings,
                  title: loc.settings,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: WSizes.spaceBetweenSections * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
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
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
