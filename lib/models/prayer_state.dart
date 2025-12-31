import 'package:adhan/adhan.dart';

class PrayerState {
  final String locationName;
  final bool isLoading;
  final PrayerTimes? prayerTimes;
  final Prayer? nextPrayer;
  final String? error;

  PrayerState({
    this.locationName = "",
    this.isLoading = false,
    this.prayerTimes,
    this.nextPrayer,
    this.error,
  });

  PrayerState copyWith({
    String? locationName,
    bool? isLoading,
    PrayerTimes? prayerTimes,
    Prayer? nextPrayer,
    String? error,
  }) {
    return PrayerState(
      locationName: locationName ?? this.locationName,
      isLoading: isLoading ?? this.isLoading,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      error: error, // Allow setting to null
    );
  }
}
