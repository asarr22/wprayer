import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position> determinePosition() async {
    await _ensureServiceEnabled();
    await _ensurePermissionsGranted();

    // Try to get the last known position first.
    // This fixes the 'LOCATION_SERVICES_DISABLED' crash on devices where
    // getCurrentPosition() is flaky even when location is on.
    try {
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }
    } catch (e) {
      // Ignore errors here, move to current position
      if (kDebugMode) {
        print("Debug: Last known position failed: $e");
      }
    }

    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: true, // Often required for Wear OS standalone GPS
        timeLimit: const Duration(seconds: 15),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 15),
      );
    }

    try {
      return await _getCurrentOrStreamPosition(locationSettings);
    } on LocationServiceDisabledException {
      // Give the user a chance to re-enable location and retry once.
      await _ensureServiceEnabled();
      return _getCurrentOrStreamPosition(locationSettings);
    } on PermissionDeniedException {
      // If permissions were revoked mid-flow, request once more.
      await _ensurePermissionsGranted();
      return _getCurrentOrStreamPosition(locationSettings);
    }
  }

  Future<String> getCityCountry(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.locality}, ${place.country}";
      }
    } catch (e) {
      // Ignore Geocoding errors (e.g. no internet)
    }
    return "Unknown Location";
  }

  Future<void> _ensureServiceEnabled() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) return;

      // On some watches, the first check might falsely report disabled.
      await Future.delayed(const Duration(milliseconds: 300));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) return;

      // If still disabled, ask user to enable it.
      await Geolocator.openLocationSettings();
      await Future.delayed(const Duration(seconds: 2));

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceDisabledException();
      }
    } on PlatformException catch (e) {
      if (e.code == 'LOCATION_SERVICES_DISABLED') {
        throw const LocationServiceDisabledException();
      }
      // Re-throw if it's something else
      rethrow;
    }
  }

  Future<void> _ensurePermissionsGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw PermissionDeniedException('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  Future<Position> _getCurrentOrStreamPosition(
    LocationSettings locationSettings,
  ) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } on TimeoutException {
      // Fall back to the first available location from the stream on slow devices.
      return await Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).first.timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw TimeoutException('Timed out while waiting for location'),
      );
    }
  }

  Stream<Position> getPositionStream() {
    LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 5),
        forceLocationManager:
            true, // Use hardware GPS directly if Fused is failing
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
