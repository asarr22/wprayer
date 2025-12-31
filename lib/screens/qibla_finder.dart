import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading;
  double? _latitude;
  double? _longitude;
  String? _error;
  final LocationService _locationService = LocationService();

  static const double _kaabaLat = 21.422487;
  static const double _kaabaLon = 39.826206;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // Use the app's resilient location service used by prayer times
      try {
        final pos = await _locationService.determinePosition();
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      } catch (e) {
        // If determinePosition fails, try cached prefs (phone sync or app cache)
        if (kDebugMode) print('DEBUG: determinePosition failed: $e');
        final prefs = await SharedPreferences.getInstance();
        String? nativeLat = prefs.getString('flutter.lat');
        String? nativeLong = prefs.getString('flutter.long');
        if (nativeLat == null || nativeLong == null) {
          nativeLat = prefs.getString('lat');
          nativeLong = prefs.getString('long');
        }
        if (nativeLat != null && nativeLong != null) {
          final lat = double.tryParse(nativeLat);
          final lon = double.tryParse(nativeLong);
          if (lat != null && lon != null) {
            setState(() {
              _latitude = lat;
              _longitude = lon;
            });
          } else {
            setState(() => _error = 'Unable to determine location.' );
          }
        } else {
          // Absolute fallback to Mecca
          setState(() {
            _latitude = 21.4225;
            _longitude = 39.8262;
          });
        }
      }

      _compassSub = FlutterCompass.events?.listen((event) {
        if (event.heading != null) {
          setState(() => _heading = event.heading);
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  double _degToRad(double deg) => deg * pi / 180.0;
  double _radToDeg(double rad) => rad * 180.0 / pi;

  double _bearingToKaaba(double lat, double lon) {
    final lat1 = _degToRad(lat);
    final lon1 = _degToRad(lon);
    final lat2 = _degToRad(_kaabaLat);
    final lon2 = _degToRad(_kaabaLon);

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final brng = _radToDeg(atan2(y, x));
    return (brng + 360) % 360;
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading;
    final lat = _latitude;
    final lon = _longitude;
    final hasError = _error != null;

    double? qiblaBearing;
    double? rotationRad;
    if (!hasError && heading != null && lat != null && lon != null) {
      qiblaBearing = _bearingToKaaba(lat, lon);
      final diff = (qiblaBearing - heading + 360) % 360;
      // rotation to apply to needle to point to qibla on screen
      rotationRad = _degToRad(diff);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Finder')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                if (hasError) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Geolocator.openAppSettings(),
                    child: const Text('Open App Settings'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                      _init();
                    },
                    child: const Text('Retry'),
                  ),
                ] else if (lat == null || lon == null) ...[
                  const CircularProgressIndicator(),
                ] else ...[
                  Text('Your location: ${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}'),
                  const SizedBox(height: 12),
                  Text('Device heading: ${heading?.toStringAsFixed(2) ?? "-"}°'),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400, width: 2),
                            ),
                          ),
                          if (rotationRad != null)
                            Transform.rotate(
                              angle: rotationRad,
                              child: Icon(Icons.navigation, size: 96, color: Colors.red.shade700),
                            ),
                          Positioned(
                            bottom: 12,
                            child: Column(
                              children: [
                                Text('Qibla bearing: ${qiblaBearing?.toStringAsFixed(2) ?? "-"}°'),
                                const SizedBox(height: 6),
                                Text('Turn so the red arrow points to the Kaaba.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
