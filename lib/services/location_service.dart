import 'dart:async';

import 'package:flutter/foundation.dart';
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
      print("Debug: Last known position failed: $e");
    }

    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (serviceEnabled) return;

    await Geolocator.openLocationSettings();
    // Give the OS time to reflect the state change before re-checking.
    await Future.delayed(const Duration(milliseconds: 500));

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
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
        timeLimit: const Duration(seconds: 15),
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
}
