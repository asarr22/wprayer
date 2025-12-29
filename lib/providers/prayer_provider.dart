import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  StreamSubscription<Position>? _locationSubscription;
  bool _disposed = false;
  DateTime? _lastScheduledDate;

  PrayerNotifier(this.ref) : super(PrayerState()) {
    initData().then((_) => startLocationTracking());

    // Schedule notifications when state or locale changes
    ref.listenSelf((previous, next) {
      final n = next as PrayerState;
      if (n.prayerTimes != null) {
        final prayerDate = n.prayerTimes!.fajr.day;
        if (_lastScheduledDate?.day != prayerDate) {
          _scheduleNotifications();
          _lastScheduledDate = n.prayerTimes!.fajr;
        }
      }
    });

    ref.listen(localeProvider, (previous, next) {
      if (state.prayerTimes != null) {
        _scheduleNotifications();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _locationSubscription?.cancel();
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

    if (kDebugMode) print("DEBUG: Updating native prayer notifications...");
    await _notificationService.schedulePrayerNotifications(
      coordinates: coordinates,
      params: params,
      languageCode: languageCode,
      localizedPrayerNames: localizedNames,
    );
  }

  void startLocationTracking() {
    _locationSubscription?.cancel();
    try {
      _locationSubscription = _locationService.getPositionStream().listen(
        (position) {
          _updateWithPosition(position.latitude, position.longitude);
        },
        onError: (error) {
          if (kDebugMode) print("Location stream error: $error");
          Future.delayed(const Duration(seconds: 30), () {
            if (!_disposed) startLocationTracking();
          });
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (kDebugMode) print("Error starting location tracking: $e");
    }
  }

  Future<void> _updateWithPosition(double latitude, double longitude) async {
    final cityCountry = await _locationService.getCityCountry(
      latitude,
      longitude,
    );

    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.umm_al_qura.getParameters();
    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);

    await _syncToNative(latitude, longitude);

    state = state.copyWith(
      locationName: cityCountry,
      prayerTimes: prayerTimes,
      nextPrayer: prayerTimes.nextPrayer(),
    );
  }

  Future<void> initData({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      double latitude;
      double longitude;
      String? errorMsg;

      try {
        final position = await _locationService.determinePosition();
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (locationError) {
        errorMsg = locationError.toString();
        latitude = 21.4225; // Mecca Fallback
        longitude = 39.8262;
      }

      await _updateWithPosition(latitude, longitude);

      if (isRefresh && errorMsg != null) {
        state = state.copyWith(error: errorMsg);
      }
    } on Exception catch (e) {
      String errorMessage;
      if (e.toString().contains('LOCATION_SERVICES_DISABLED')) {
        errorMessage = "LOCATION_SERVICES_DISABLED";
      } else if (e.toString().contains('denied')) {
        errorMessage = "PERMISSION_DENIED";
      } else {
        errorMessage = e.toString();
      }

      state = state.copyWith(locationName: errorMessage, error: errorMessage);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _syncToNative(double lat, double long) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flutter.lat', lat.toString());
    await prefs.setString('flutter.long', long.toString());
    try {
      await platform.invokeMethod('syncLocationToWatch', {
        'lat': lat,
        'long': long,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) print('Failed to sync to watch: ${e.message}');
    }
  }
}
