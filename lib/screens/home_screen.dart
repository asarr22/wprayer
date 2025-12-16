import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:wprayer/services/location_service.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/constants/texts.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'package:wprayer/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  String _locationName = "";
  PrayerTimes? _prayerTimes;
  Prayer? _nextPrayer;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      double latitude;
      double longitude;
      String cityCountry;

      try {
        // Try to get actual location
        final position = await _locationService.determinePosition();
        latitude = position.latitude;
        longitude = position.longitude;
        cityCountry = await _locationService.getCityCountry(
          latitude,
          longitude,
        );
      } catch (locationError) {
        // Fallback to default location (Mecca) if location services are disabled
        print("Location error, using default: $locationError");
        latitude = 21.4225; // Mecca
        longitude = 39.8262;
        cityCountry = "Mecca (${WTexts.default_})";
      }

      // Calculate Prayer Times
      final coordinates = Coordinates(latitude, longitude);
      final params = CalculationMethod.umm_al_qura.getParameters();
      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);

      // Sync with Native
      await _syncToNative(latitude, longitude);

      if (mounted) {
        setState(() {
          _locationName = cityCountry;
          _prayerTimes = prayerTimes;
          _nextPrayer = prayerTimes.nextPrayer();
        });
      }
    } on Exception catch (e, stackTrace) {
      String errorMessage = "Error";

      // Check for specific error types
      if (e.toString().contains('LOCATION_SERVICES_DISABLED')) {
        errorMessage = "Enable Location";
      } else if (e.toString().contains('denied')) {
        errorMessage = "Permission Denied";
      } else {
        errorMessage = "Error: ${e.toString().substring(0, 30)}...";
      }

      if (mounted) {
        setState(() {
          _locationName = errorMessage;
        });
      }
      if (kDebugMode) {
        // Print detailed error info to console for debugging
        print("=== ERROR in _initData ===");
        print("Exception: $e");
        print("Stack trace: $stackTrace");
        print("========================");
      }
    }
  }

  Future<void> _syncToNative(double lat, double long) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flutter.lat', lat.toString());
    await prefs.setString('flutter.long', long.toString());
    // Note: Complication update might need a MethodChannel trigger ideally,
    // but Periodic updates will pick this up eventually.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(WSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: WSizes.spaceBetweenItems),
                if (_prayerTimes != null) ...[
                  _buildNextPrayerCard(),
                  const SizedBox(height: WSizes.spaceBetweenSections),
                  _buildPrayerList(),
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

  Widget _buildHeader() {
    final loc = AppLocalizations.of(context)!;

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
                _locationName.isEmpty ? loc.locating : _locationName,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard() {
    if (_nextPrayer == Prayer.none) {
      return const SizedBox(); // Day ended
    }

    final loc = AppLocalizations.of(context)!;
    final nextTime = _prayerTimes!.timeForPrayer(_nextPrayer!)!;
    final prayerName = loc.getPrayerName(_nextPrayer!.name);
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

  Widget _buildPrayerList() {
    final loc = AppLocalizations.of(context)!;
    final prayers = [
      (Prayer.fajr, _prayerTimes!.fajr),
      (Prayer.dhuhr, _prayerTimes!.dhuhr),
      (Prayer.asr, _prayerTimes!.asr),
      (Prayer.maghrib, _prayerTimes!.maghrib),
      (Prayer.isha, _prayerTimes!.isha),
    ];

    return Column(
      children: prayers.map((prayer) {
        final name = loc.getPrayerName(prayer.$1.name);
        final time = DateFormat.jm().format(prayer.$2);
        final isNext = prayer.$1 == _nextPrayer;

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
