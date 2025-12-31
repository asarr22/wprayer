import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification channel on startup
  await NotificationService().init();

  // Request notification permission on first run
  try {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('requested_notification_permission') ?? false;
    if (!asked) {
      // Request platform notification permission (Android 13+/iOS)
      await NotificationService().requestPermission();
      await prefs.setBool('requested_notification_permission', true);
    }
  } catch (e) {
    if (kDebugMode) {
      print("DEBUG: Error requesting notification permission: $e");
    }
  }

  // Initialize Quran package in background to avoid blocking startup
  Quran.initialize();

  runApp(const ProviderScope(child: App()));
}
