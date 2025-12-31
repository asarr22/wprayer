import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification channel on startup
  await NotificationService().init();

  // Initialize Quran package in background to avoid blocking startup
  Quran.initialize();

  runApp(const ProviderScope(child: App()));
}
