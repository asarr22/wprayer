import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wprayer/models/prayer_state.dart';
import 'package:wprayer/providers/prayer_provider.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'package:wprayer/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _handleError(String? error) {
    if (error == null || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context)!;
      if (error == "LOCATION_SERVICES_DISABLED") {
        // This case is often handled by the system or a specific dialog,
        // but we can show a snackbar if needed.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.enableLocation}. ${loc.usingDefault}.'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (error.contains("denied")) {
        _showPermissionDialog(error);
      } else if (error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${loc.locationFailed}: $error. ${loc.usingDefault}.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _showPermissionDialog(String details) {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.locationPermissionRequired),
          content: Text(
            '${loc.locationPermissionDesc}\n\n${loc.details}: $details',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Open app settings so the user can grant permissions manually
                await Geolocator.openAppSettings();
              },
              child: Text(loc.openSettings),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Retry getting location
                ref.read(prayerProvider.notifier).initData(isRefresh: true);
              },
              child: Text(loc.retry),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerProvider);

    // Use a listener to handle errors/dialogs
    ref.listen(prayerProvider.select((s) => s.error), (previous, next) {
      if (next != null && next != previous) {
        _handleError(next);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(WSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(prayerState),
                const SizedBox(height: WSizes.spaceBetweenItems),
                if (prayerState.prayerTimes != null) ...[
                  _buildNextPrayerCard(prayerState),
                  const SizedBox(height: WSizes.spaceBetweenSections),
                  _buildPrayerList(prayerState),
                  const SizedBox(height: WSizes.spaceBetweenSections),
                  _buildSettingsButton(),
                ] else
                  const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PrayerState prayerState) {
    final loc = AppLocalizations.of(context)!;
    final locationName = prayerState.locationName;
    final isLoading = prayerState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(loc.appName, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                locationName.isEmpty
                    ? loc.locating
                    : (locationName == "Unknown Location"
                          ? loc.unknownLocation
                          : (locationName == "PERMISSION_DENIED"
                                ? loc.permissionDenied
                                : (locationName == "LOCATION_SERVICES_DISABLED"
                                      ? loc.enableLocation
                                      : locationName))),
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              )
            else
              InkWell(
                onTap: () =>
                    ref.read(prayerProvider.notifier).initData(isRefresh: true),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.refresh, color: Colors.white70, size: 16),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard(PrayerState prayerState) {
    final nextPrayer = prayerState.nextPrayer;
    if (nextPrayer == null || nextPrayer == Prayer.none) {
      return const SizedBox(); // Day ended or no prayer data
    }

    final loc = AppLocalizations.of(context)!;
    final nextTime = prayerState.prayerTimes!.timeForPrayer(nextPrayer)!;
    final prayerName = loc.getPrayerName(nextPrayer.name);
    final timeStr = DateFormat.jm().format(nextTime);

    return Container(
      padding: const EdgeInsets.all(WSizes.padding / 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [WColors.primary, WColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: WColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.nextPrayer, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(prayerName, style: Theme.of(context).textTheme.titleLarge),
          Text(timeStr, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildPrayerList(PrayerState prayerState) {
    final loc = AppLocalizations.of(context)!;
    final prayerTimes = prayerState.prayerTimes!;
    final nextPrayer = prayerState.nextPrayer;

    final prayers = [
      (Prayer.fajr, prayerTimes.fajr),
      (Prayer.dhuhr, prayerTimes.dhuhr),
      (Prayer.asr, prayerTimes.asr),
      (Prayer.maghrib, prayerTimes.maghrib),
      (Prayer.isha, prayerTimes.isha),
    ];

    return Column(
      children: prayers.map((prayer) {
        final name = loc.getPrayerName(prayer.$1.name);
        final time = DateFormat.jm().format(prayer.$2);
        final isNext = prayer.$1 == nextPrayer;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isNext
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: isNext ? Border.all(color: Colors.white30) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsButton() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
        icon: const Icon(Icons.settings, size: 20),
        label: Text(loc.settings),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: WSizes.padding,
            vertical: WSizes.padding / 1.5,
          ),
          backgroundColor: WColors.primary.withValues(alpha: 0.2),
          foregroundColor: WColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WSizes.borderRadius),
            side: BorderSide(color: WColors.primary.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }
}
