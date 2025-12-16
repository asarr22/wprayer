import 'package:adhan/adhan.dart';

class WTexts {
  WTexts._();

  static const String appName = "W Prayer";
  static const String nextPrayer = "Next Prayer";
  static const String nextPrayerTime = "Next Prayer Time";
  static const String default_ = "Default";

  static const Map<Prayer, String> prayerNames = {
    Prayer.fajr: "Fajr",
    Prayer.sunrise: "Sunrise",
    Prayer.dhuhr: "Dhuhr",
    Prayer.asr: "Asr",
    Prayer.maghrib: "Maghrib",
    Prayer.isha: "Isha",
  };
}
