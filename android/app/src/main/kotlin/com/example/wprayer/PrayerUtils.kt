package com.example.wprayer

import android.content.Context
import android.content.SharedPreferences
import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.Prayer
import com.batoulapps.adhan.PrayerTimes
import com.batoulapps.adhan.data.DateComponents
import java.util.*

object PrayerUtils {
    fun rescheduleAlarms(context: Context) {
        val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        
        val lat = prefs.getString("flutter.flutter.lat", null)?.toDoubleOrNull() ?: prefs.getString("flutter.lat", null)?.toDoubleOrNull() ?: 21.4225
        val long = prefs.getString("flutter.flutter.long", null)?.toDoubleOrNull() ?: prefs.getString("flutter.long", null)?.toDoubleOrNull() ?: 39.8262
        val languageCode = prefs.getString("flutter.language_code", "en") ?: "en"
        val methodString = prefs.getString("flutter.calculation_method", "MWL") ?: "MWL"
        
        val coordinates = Coordinates(lat, long)
        val params = when (methodString) {
            "UMM_AL_QURA" -> CalculationMethod.UMM_AL_QURA.parameters
            "EGYPTIAN" -> CalculationMethod.EGYPTIAN.parameters
            "KARACHI" -> CalculationMethod.KARACHI.parameters
            "NORTH_AMERICA" -> CalculationMethod.NORTH_AMERICA.parameters
            "DUBAI" -> CalculationMethod.DUBAI.parameters
            "KUWAIT" -> CalculationMethod.KUWAIT.parameters
            "QATAR" -> CalculationMethod.QATAR.parameters
            "SINGAPORE" -> CalculationMethod.SINGAPORE.parameters
            else -> CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters
        }
        val scheduler = PrayerNotificationScheduler(context)
        
        val calendar = Calendar.getInstance()
        val now = calendar.time

        // Schedule for today and tomorrow
        for (i in 0..1) {
            val dateComponents = DateComponents.from(calendar.time)
            val prayerTimes = PrayerTimes(coordinates, dateComponents, params)
            
            val prayers = listOf(
                Prayer.FAJR to 1,
                Prayer.DHUHR to 2,
                Prayer.ASR to 3,
                Prayer.MAGHRIB to 4,
                Prayer.ISHA to 5
            )

            for ((prayer, index) in prayers) {
                val time = prayerTimes.timeForPrayer(prayer)
                if (time != null && time.after(now)) {
                    val id = (calendar.get(Calendar.DAY_OF_MONTH) % 7) * 10 + index
                    val prayerName = getLocalizedPrayerName(prayer, languageCode)
                    val title = if (languageCode == "ar") "وقت الصلاة" else "Prayer Time"
                    val body = if (languageCode == "ar") "حان الآن موعد صلاة $prayerName" else "Time for $prayerName prayer"
                    
                    scheduler.schedulePrayer(id, prayer.name, title, body, time.time)
                }
            }
            calendar.add(Calendar.DAY_OF_MONTH, 1)
        }
    }

    private fun getLocalizedPrayerName(prayer: Prayer, languageCode: String): String {
        return when (languageCode) {
            "ar" -> when (prayer) {
                Prayer.FAJR -> "الفجر"
                Prayer.SUNRISE -> "الشروق"
                Prayer.DHUHR -> "الظهر"
                Prayer.ASR -> "العصر"
                Prayer.MAGHRIB -> "المغرب"
                Prayer.ISHA -> "العشاء"
                else -> prayer.name
            }
            else -> when (prayer) {
                Prayer.FAJR -> "Fajr"
                Prayer.SUNRISE -> "Sunrise"
                Prayer.DHUHR -> "Dhuhr"
                Prayer.ASR -> "Asr"
                Prayer.MAGHRIB -> "Maghrib"
                Prayer.ISHA -> "Isha"
                else -> prayer.name
            }
        }
    }
}
