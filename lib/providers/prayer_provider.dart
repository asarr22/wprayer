import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_state.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'locale_provider.dart';

final prayerProvider = StateNotifierProvider<PrayerNotifier, PrayerState>((
  ref,
) {
  return PrayerNotifier(ref);
});

class PrayerNotifier extends StateNotifier<PrayerState> {
  final Ref ref;
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  static const platform = MethodChannel('com.example.wprayer/location');
  bool _disposed = false;

  PrayerNotifier(this.ref) : super(PrayerState()) {
    initData();

    ref.listen(localeProvider, (previous, next) {
      if (state.prayerTimes != null) {
        _scheduleNotifications();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _scheduleNotifications() async {
    final prayerTimes = state.prayerTimes;
    if (prayerTimes == null) return;

    final locale = ref.read(localeProvider);
    final languageCode = locale?.languageCode ?? 'en';

    final localizedNames = {
      'fajr': languageCode == 'ar' ? 'الفجر' : 'Fajr',
      'sunrise': languageCode == 'ar' ? 'الشروق' : 'Sunrise',
      'dhuhr': languageCode == 'ar' ? 'الظهر' : 'Dhuhr',
      'asr': languageCode == 'ar' ? 'العصر' : 'Asr',
      'maghrib': languageCode == 'ar' ? 'المغرب' : 'Maghrib',
      'isha': languageCode == 'ar' ? 'العشاء' : 'Isha',
    };

    final coordinates = prayerTimes.coordinates;
    final params = CalculationMethod.umm_al_qura.getParameters();

    await _notificationService.schedulePrayerNotifications(
      coordinates: coordinates,
      params: params,
      languageCode: languageCode,
      localizedPrayerNames: localizedNames,
    );
  }

  Future<void> initData({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      double? latitude;
      double? longitude;
      bool isFromGPS = false;

      // 1. Try GPS/Resilient Search
      try {
        if (kDebugMode) print("DEBUG: Attempting resilient location search...");
        final position = await _locationService.determinePosition();
        latitude = position.latitude;
        longitude = position.longitude;
        isFromGPS = true;
      } catch (e) {
        if (kDebugMode)
          print("DEBUG: Resilient search yielded no fresh fix: $e");
      }

      // 2. Try Cached SharedPreferences (Native or Flutter saved)
      if (latitude == null) {
        final prefs = await SharedPreferences.getInstance();

        // Try reading synchronized key from Native (phone sync)
        final nativeLat = prefs.getString(
          'flutter.lat',
        ); // Reads flutter.flutter.lat
        final nativeLong = prefs.getString('flutter.long');

        if (nativeLat != null && nativeLong != null) {
          latitude = double.tryParse(nativeLat);
          longitude = double.tryParse(nativeLong);
          if (kDebugMode)
            print(
              "DEBUG: Using cached location from Phone Sync: $latitude, $longitude",
            );
        } else {
          // Try reading Flutter's own save
          final ownLat = prefs.getString('lat'); // Reads flutter.lat
          final ownLong = prefs.getString('long');
          if (ownLat != null && ownLong != null) {
            latitude = double.tryParse(ownLat);
            longitude = double.tryParse(ownLong);
            if (kDebugMode)
              print(
                "DEBUG: Using cached location from App History: $latitude, $longitude",
              );
          }
        }
      }

      // 3. Absolute Fallback
      if (latitude == null || longitude == null) {
        latitude = 21.4225; // Mecca
        longitude = 39.8262;
        if (kDebugMode) print("DEBUG: Using absolute fallback (Mecca)");
      }

      await _updateWithPosition(latitude, longitude, isFresh: isFromGPS);
      await _scheduleNotifications();
    } catch (globalError) {
      if (kDebugMode) print("DEBUG: Fatal init error: $globalError");
      state = state.copyWith(error: globalError.toString());
    } finally {
      if (!_disposed) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> _updateWithPosition(
    double lat,
    double lng, {
    bool isFresh = false,
  }) async {
    final cityCountry = await _locationService.getCityCountry(lat, lng);
    final countryCode = await _locationService.getCountryCode(lat, lng);

    // Save to both Native and Flutter keys to ensure sync
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lat', lat.toString()); // flutter.lat
    await prefs.setString('long', lng.toString());

    // Determine calculation method: User Preference > Auto Detect
    final userPrefMethod = prefs.getString('user_calculation_method');
    CalculationMethod calculationMethod;
    String methodString = "MWL"; // Default fallback

    if (userPrefMethod != null) {
      // Use user selection
      methodString = userPrefMethod;
      if (userPrefMethod == "UMM_AL_QURA")
        calculationMethod = CalculationMethod.umm_al_qura;
      else if (userPrefMethod == "EGYPTIAN")
        calculationMethod = CalculationMethod.egyptian;
      else if (userPrefMethod == "KARACHI")
        calculationMethod = CalculationMethod.karachi;
      else if (userPrefMethod == "NORTH_AMERICA")
        calculationMethod = CalculationMethod.north_america;
      else if (userPrefMethod == "DUBAI")
        calculationMethod = CalculationMethod.dubai;
      else if (userPrefMethod == "KUWAIT")
        calculationMethod = CalculationMethod.kuwait;
      else if (userPrefMethod == "QATAR")
        calculationMethod = CalculationMethod.qatar;
      else if (userPrefMethod == "SINGAPORE")
        calculationMethod = CalculationMethod.singapore;
      else if (userPrefMethod == "TEHRAN")
        calculationMethod = CalculationMethod.tehran;
      else if (userPrefMethod == "TURKEY")
        calculationMethod = CalculationMethod.turkey;
      else if (userPrefMethod == "MWL")
        calculationMethod = CalculationMethod.muslim_world_league;
      else
        calculationMethod = CalculationMethod.muslim_world_league;
    } else {
      // Auto detect
      calculationMethod = _getCalculationMethod(countryCode);

      // Convert auto-detected method to string for sync
      if (calculationMethod == CalculationMethod.umm_al_qura)
        methodString = "UMM_AL_QURA";
      else if (calculationMethod == CalculationMethod.egyptian)
        methodString = "EGYPTIAN";
      else if (calculationMethod == CalculationMethod.karachi)
        methodString = "KARACHI";
      else if (calculationMethod == CalculationMethod.north_america)
        methodString = "NORTH_AMERICA";
      else if (calculationMethod == CalculationMethod.dubai)
        methodString = "DUBAI";
      else if (calculationMethod == CalculationMethod.kuwait)
        methodString = "KUWAIT";
      else if (calculationMethod == CalculationMethod.qatar)
        methodString = "QATAR";
      else if (calculationMethod == CalculationMethod.singapore)
        methodString = "SINGAPORE";
      else if (calculationMethod == CalculationMethod.tehran)
        methodString = "TEHRAN";
      else if (calculationMethod == CalculationMethod.turkey)
        methodString = "TURKEY";
      else
        methodString = "MWL";
    }

    final params = calculationMethod.getParameters();

    final coordinates = Coordinates(lat, lng);
    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);

    await prefs.setString('calculation_method', methodString);

    await _syncToNative(lat, lng, methodString);

    if (!_disposed) {
      state = state.copyWith(
        locationName: isFresh ? cityCountry : "$cityCountry (Cached/Saved)",
        prayerTimes: prayerTimes,
        nextPrayer: prayerTimes.nextPrayer(),
      );
    }
  }

  CalculationMethod _getCalculationMethod(String? countryCode) {
    if (countryCode == null) return CalculationMethod.muslim_world_league;

    switch (countryCode.toUpperCase()) {
      case 'SA':
        return CalculationMethod.umm_al_qura;
      case 'EG':
        return CalculationMethod.egyptian;
      case 'PK':
        return CalculationMethod.karachi;
      case 'US':
      case 'CA':
        return CalculationMethod.north_america;
      case 'AE':
        return CalculationMethod.dubai;
      case 'KW':
        return CalculationMethod.kuwait;
      case 'QA':
        return CalculationMethod.qatar;
      case 'SG':
        return CalculationMethod.singapore;
      case 'IR':
        return CalculationMethod.tehran;
      case 'TR':
        return CalculationMethod.turkey;
      default:
        return CalculationMethod.muslim_world_league;
    }
  }

  Future<void> updateCalculationMethod(String? method) async {
    final prefs = await SharedPreferences.getInstance();
    if (method == null) {
      await prefs.remove('user_calculation_method'); // Return to Auto
    } else {
      await prefs.setString('user_calculation_method', method);
    }
    await initData(isRefresh: true);
  }

  Future<void> _syncToNative(double lat, double lng, String method) async {
    try {
      await platform.invokeMethod('syncLocationToWatch', {
        'lat': lat,
        'long': lng,
        'method': method,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) print('Failed to sync to watch: ${e.message}');
    }
  }
}
