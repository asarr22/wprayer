import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_state.dart';
import '../services/location_service.dart';

final prayerProvider = StateNotifierProvider<PrayerNotifier, PrayerState>((
  ref,
) {
  return PrayerNotifier();
});

class PrayerNotifier extends StateNotifier<PrayerState> {
  final LocationService _locationService = LocationService();
  static const platform = MethodChannel('com.example.wprayer/location');
  StreamSubscription<Position>? _locationSubscription;
  bool _disposed = false;

  PrayerNotifier() : super(PrayerState()) {
    initData().then((_) => startLocationTracking());
  }

  @override
  void dispose() {
    _disposed = true;
    _locationSubscription?.cancel();
    super.dispose();
  }

  void startLocationTracking() {
    _locationSubscription?.cancel();
    try {
      _locationSubscription = _locationService.getPositionStream().listen(
        (position) {
          if (kDebugMode) {
            print(
              "Location update: ${position.latitude}, ${position.longitude}",
            );
          }
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
