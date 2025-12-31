import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _channel = MethodChannel('com.example.wprayer/notifications');

  Future<void> init() async {
    try {
      await _channel.invokeMethod('createChannel');
    } catch (e) {
      if (kDebugMode) print("DEBUG: Error creating native channel: $e");
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final bool enabled = await _channel.invokeMethod(
        'areNotificationsEnabled',
      );
      return enabled;
    } catch (e) {
      return false;
    }
  }

  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      if (kDebugMode) print("DEBUG: Error opening settings: $e");
    }
  }

  Future<void> triggerInstantNativeNotification() async {
    try {
      await _channel.invokeMethod('showInstantTest');
    } catch (e) {
      if (kDebugMode) print("DEBUG: Instant test failed: $e");
    }
  }

  Future<bool> requestPermission() async {
    // 1. Ensure channel exists first
    await init();

    // 2. Try standard request
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    // 3. Check native status as source of truth
    final bool nativeEnabled = await areNotificationsEnabled();

    // 4. Request Exact Alarm permission if needed
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    if (!nativeEnabled) {
      await openSettings();
    }

    return nativeEnabled || status.isGranted;
  }

  Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required CalculationParameters params,
    required String languageCode,
    required Map<String, String> localizedPrayerNames,
  }) async {
    final now = DateTime.now();

    try {
      await _channel.invokeMethod('cancelAllNotifications');
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error cancelling notifications: $e');
    }

    for (int dayOffset = 0; dayOffset <= 1; dayOffset++) {
      final date = DateTime.now().add(Duration(days: dayOffset));
      final dateComponents = DateComponents.from(date);
      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

      final prayers = [
        (Prayer.fajr, prayerTimes.fajr, 1),
        (Prayer.dhuhr, prayerTimes.dhuhr, 2),
        (Prayer.asr, prayerTimes.asr, 3),
        (Prayer.maghrib, prayerTimes.maghrib, 4),
        (Prayer.isha, prayerTimes.isha, 5),
      ];

      for (var pData in prayers) {
        final prayer = pData.$1;
        final time = pData.$2;
        final index = pData.$3;

        // Give a clear buffer to avoid immediate firing on schedule
        if (time.isAfter(now.add(const Duration(seconds: 15)))) {
          final int id = (date.day % 7) * 10 + index;
          final prayerName =
              localizedPrayerNames[prayer.name.toLowerCase()] ?? prayer.name;

          try {
            await _channel.invokeMethod('scheduleNotification', {
              'id': id,
              'name': prayer.name,
              'title': languageCode == 'ar' ? 'وقت الصلاة' : 'Prayer Time',
              'body': languageCode == 'ar'
                  ? 'حان الآن موعد صلاة $prayerName'
                  : 'Time for $prayerName prayer',
              'time': time.millisecondsSinceEpoch,
            });
          } catch (e) {
            if (kDebugMode) {
              print('DEBUG: Error scheduling native notification: $e');
            }
          }
        }
      }
    }
  }

  Future<void> showTestNotification() async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'id': 999,
        'name': 'Test',
        'title': 'Test Notification',
        'body': 'If you see this, native notifications are working.',
        'time': DateTime.now()
            .add(const Duration(seconds: 3))
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error showing test notification: $e');
    }
  }
}
