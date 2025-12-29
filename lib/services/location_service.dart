import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Attempts to get the current position with an optimized collection window.
  Future<Position> determinePosition() async {
    // 1. Check permissions first
    await _ensurePermissionsGranted();

    Position? bestPosition;

    // 2. Try to get the last known as a secondary baseline IMMEDIATELY
    try {
      bestPosition = await Geolocator.getLastKnownPosition();
      if (bestPosition != null && kDebugMode) {
        if (kDebugMode) {
          print(
            "DEBUG: Initial baseline from last known: ${bestPosition.latitude}, ${bestPosition.longitude} (Acc: ${bestPosition.accuracy})",
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print("DEBUG: Error getting initial last known: $e");
    }

    // 3. Start a collection window. We removed the blocking 'isServiceEnabled' check
    // because on Wear OS, sometimes the stream can wake up the GPS even if the
    // high-level check returns false or is flaky.
    if (kDebugMode) {
      print("DEBUG: Starting 5-second location collection window...");
    }

    final completer = Completer<Position>();
    StreamSubscription<Position>? subscription;

    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      forceLocationManager:
          true, // FORCE GPS to ensure the icon appears on Watch
    );

    // Timeout logic
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        if (bestPosition != null) {
          if (kDebugMode) {
            print(
              "DEBUG: 5s Collection window ended. Returning best fix (Acc: ${bestPosition?.accuracy})",
            );
          }
          completer.complete(bestPosition!);
        } else {
          if (kDebugMode) print("DEBUG: 5s timeout. No fix found.");
          completer.completeError("LOCATION_TIMEOUT");
        }
        subscription?.cancel();
      }
    });

    subscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            if (bestPosition == null ||
                position.accuracy < bestPosition!.accuracy) {
              if (kDebugMode) {
                print(
                  "DEBUG: New best fix: ${position.latitude}, ${position.longitude} (Acc: ${position.accuracy})",
                );
              }
              bestPosition = position;
            }

            if (position.accuracy < 15) {
              if (!completer.isCompleted) {
                if (kDebugMode) {
                  print(
                    "DEBUG: High accuracy fix (<15m) found early. Completing.",
                  );
                }
                completer.complete(position);
                subscription?.cancel();
              }
            }
          },
          onError: (error) {
            if (kDebugMode) print("DEBUG: Stream error: $error");
            if (error.toString().contains("service_disabled")) {
              if (bestPosition != null && !completer.isCompleted) {
                completer.complete(bestPosition!);
                subscription?.cancel();
              }
            }
          },
          cancelOnError: false,
        );

    return completer.future;
  }

  Future<String> getCityCountry(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        long,
      ).timeout(const Duration(seconds: 3));
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String location =
            place.locality ??
            place.subAdministrativeArea ??
            "Location Detected";
        return "$location, ${place.country ?? ""}";
      }
    } catch (e) {
      if (kDebugMode) print("DEBUG: Geocoding failed or timed out: $e");
    }
    return "Location Detected";
  }

  Future<String?> getCountryCode(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        long,
      ).timeout(const Duration(seconds: 3));
      if (placemarks.isNotEmpty) {
        return placemarks[0].isoCountryCode;
      }
    } catch (e) {
      if (kDebugMode) print("DEBUG: Geocoding country code failed: $e");
    }
    return null;
  }

  Future<void> _ensurePermissionsGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Location permissions are permanently denied.',
      );
    }
  }
}
