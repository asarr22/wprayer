import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wprayer/providers/qibla_provider.dart';
import 'package:wprayer/utils/constants/images.dart';

class QiblaFinderScreen extends ConsumerStatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  ConsumerState<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends ConsumerState<QiblaFinderScreen> {
  StreamSubscription<CompassEvent>? _compassSub;

  static const double _kaabaLat = 21.422487;
  static const double _kaabaLon = 39.826206;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ref.read(qiblaNotifierProvider.notifier).init();
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
    final qiblaAsync = ref.watch(qiblaNotifierProvider);

    // Show only compass dial and needle. If not ready, show centered loader.
    return qiblaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) {
        final heading = data['heading'] as double?;
        final lat = data['latitude'] as double?;
        final lon = data['longitude'] as double?;
        final error = data['error'] as String?;
        final hasError = error != null;

        double? qiblaBearing;
        double? rotationRad;
        if (!hasError && heading != null && lat != null && lon != null) {
          qiblaBearing = _bearingToKaaba(lat, lon);
          final diff = (qiblaBearing - heading + 360) % 360;
          // rotation to apply to needle to point to qibla on screen
          rotationRad = _degToRad(diff);
        }

        // Show only compass dial and needle. If not ready, show centered loader.
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Builder(
                builder: (context) {
                  if (hasError) {
                    return const CircularProgressIndicator();
                  }
                  if (heading == null || lat == null || lon == null) {
                    return const CircularProgressIndicator();
                  }

                  final dialRotation = _degToRad(-heading);
                  final needleRotation = rotationRad ?? 0.0;
                  final size = min(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  );

                  return SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating dial background
                        Transform.rotate(
                          angle: dialRotation,
                          child: Image.asset(
                            WImages.compassDial,
                            width: size,
                            height: size,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Needle pointing to Qibla (relative rotation already computed)
                        Transform.rotate(
                          angle: needleRotation,
                          child: Image.asset(
                            WImages.qiblaNeedle,
                            width: size * 0.9,
                            height: size * 0.9,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
