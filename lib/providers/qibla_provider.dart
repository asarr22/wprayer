import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wprayer/services/location_service.dart';
import 'package:wprayer/providers/locale_provider.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class QiblaProvider extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Ref ref;
  QiblaProvider(this.ref) : super(const AsyncValue.loading());

  static Map<String, dynamic> _baseState() => {
    'latitude': null,
    'longitude': null,
    'heading': null,
  };
  StreamSubscription<CompassEvent>? _compassSub;
  final LocationService _locationService = LocationService();

  Future<void> init() async {
    state = const AsyncValue.loading();

    try {
      var data = _baseState();

      // 1. Get location (or fallback)
      try {
        final pos = await _locationService.determinePosition();
        data = {...data, 'latitude': pos.latitude, 'longitude': pos.longitude};
      } catch (e) {
        if (kDebugMode) {
          print('DEBUG: determinePosition failed: $e');
        }

        final prefs = await SharedPreferences.getInstance();
        String? nativeLat = prefs.getString('flutter.lat');
        String? nativeLong = prefs.getString('flutter.long');

        // fallback to old keys if needed
        nativeLat ??= prefs.getString('lat');
        nativeLong ??= prefs.getString('long');

        if (nativeLat != null && nativeLong != null) {
          final lat = double.tryParse(nativeLat);
          final lon = double.tryParse(nativeLong);

          if (lat != null && lon != null) {
            data = {...data, 'latitude': lat, 'longitude': lon};
            final locale = ref.read(localeProvider);
            final loc = AppLocalizations(locale ?? const Locale('en'));
            state = AsyncValue.error(
              Exception(loc.locationFailed),
              StackTrace.current,
            );
            return;
          }
        } else {
          // Absolute fallback to Mecca
          data = {...data, 'latitude': 21.4225, 'longitude': 39.8262};
        }
      }

      // We now have a valid lat/long → publish initial data
      state = AsyncValue.data(data);

      // 2. Start listening to compass
      _compassSub = FlutterCompass.events?.listen((event) {
        final heading = event.heading;
        if (heading != null) {
          // only update if we are in a data state
          state = state.whenData((current) => {...current, 'heading': heading});
        }
      });
    } catch (e, st) {
      final locale = ref.read(localeProvider);
      final loc = AppLocalizations(locale ?? const Locale('en'));
      state = AsyncValue.error(Exception('${loc.error}: $e'), st);
    }
  }

  @override
  dispose() {
    super.dispose();
    _compassSub?.cancel();
  }
}

final qiblaNotifierProvider =
    StateNotifierProvider.autoDispose<
      QiblaProvider,
      AsyncValue<Map<String, dynamic>>
    >((ref) => QiblaProvider(ref));
