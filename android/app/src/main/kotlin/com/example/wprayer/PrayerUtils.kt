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
        
        val lat = prefs.getString("flutter.lat", null)?.toDoubleOrNull() ?: prefs.getString("flutter.flutter.lat", null)?.toDoubleOrNull() ?: 21.4225
        val long = prefs.getString("flutter.long", null)?.toDoubleOrNull() ?: prefs.getString("flutter.flutter.long", null)?.toDoubleOrNull() ?: 39.8262
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
                    
                    val title = when (languageCode) {
                        "ar" -> "وقت الصلاة"
                        "fr" -> "Heure de prière"
                        "es" -> "Hora de oración"
                        "pt" -> "Hora da oração"
                        "zh" -> "祈祷时间"
                        "tr" -> "Namaz Vakti"
                        "ur" -> "نماز کا وقت"
                        "fa" -> "وقت نماز"
                        "ja" -> "礼拝の時間"
                        "de" -> "Gebetszeit"
                        "it" -> "Ora della preghiera"
                        else -> "Prayer Time"
                    }
                    
                    val body = when (languageCode) {
                        "ar" -> "حان الآن موعد صلاة $prayerName"
                        "fr" -> "C'est l'heure de la prière de $prayerName"
                        "es" -> "Es hora de la oración de $prayerName"
                        "pt" -> "É hora da oração de $prayerName"
                        "zh" -> "$prayerName 祈祷的时间到了"
                        "tr" -> "$prayerName namazı vakti geldi"
                        "ur" -> "$prayerName کا وقت ہو گیا ہے"
                        "fa" -> "وقت نماز $prayerName فرا رسیده است"
                        "ja" -> "$prayerName の時間です"
                        "de" -> "Es ist Zeit für das $prayerName-Gebet"
                        "it" -> "È ora della preghiera di $prayerName"
                        else -> "Time for $prayerName prayer"
                    }
                    
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
            "fr" -> when (prayer) {
                Prayer.FAJR -> "Fajr"
                Prayer.SUNRISE -> "Lever"
                Prayer.DHUHR -> "Dhuhr"
                Prayer.ASR -> "Asr"
                Prayer.MAGHRIB -> "Maghrib"
                Prayer.ISHA -> "Isha"
                else -> prayer.name
            }
            "es" -> when (prayer) {
                Prayer.FAJR -> "Fajr"
                Prayer.SUNRISE -> "Amanecer"
                Prayer.DHUHR -> "Dhuhr"
                Prayer.ASR -> "Asr"
                Prayer.MAGHRIB -> "Maghrib"
                Prayer.ISHA -> "Isha"
                else -> prayer.name
            }
            "pt" -> when (prayer) {
                Prayer.FAJR -> "Fajr"
                Prayer.SUNRISE -> "Nascer do sol"
                Prayer.DHUHR -> "Dhuhr"
                Prayer.ASR -> "Asr"
                Prayer.MAGHRIB -> "Maghrib"
                Prayer.ISHA -> "Isha"
                else -> prayer.name
            }
            "zh" -> when (prayer) {
                Prayer.FAJR -> "Fajr"
                Prayer.SUNRISE -> "日出"
                Prayer.DHUHR -> "Dhuhr"
                Prayer.ASR -> "Asr"
                Prayer.MAGHRIB -> "Maghrib"
                Prayer.ISHA -> "Isha"
                else -> prayer.name
            }
            "tr" -> when (prayer) {
                Prayer.FAJR -> "İmsak"
                Prayer.SUNRISE -> "Güneş"
                Prayer.DHUHR -> "Öğle"
                Prayer.ASR -> "İkindi"
                Prayer.MAGHRIB -> "Akşam"
                Prayer.ISHA -> "Yatsı"
                else -> prayer.name
            }
            "ur" -> when (prayer) {
                Prayer.FAJR -> "فجر"
                Prayer.SUNRISE -> "طلوع آفتاب"
                Prayer.DHUHR -> "ظہر"
                Prayer.ASR -> "عصر"
                Prayer.MAGHRIB -> "مغرب"
                Prayer.ISHA -> "عشاء"
                else -> prayer.name
            }
            "fa" -> when (prayer) {
                Prayer.FAJR -> "اذان صبح"
                Prayer.SUNRISE -> "طلوع آفتاب"
                Prayer.DHUHR -> "اذان ظهر"
                Prayer.ASR -> "عصر"
                Prayer.MAGHRIB -> "اذان مغرب"
                Prayer.ISHA -> "اذان عشا"
                else -> prayer.name
            }
            "ja" -> when (prayer) {
                Prayer.FAJR -> "ファジル"
                Prayer.SUNRISE -> "日の出"
                Prayer.DHUHR -> "ズフル"
                Prayer.ASR -> "アスル"
                Prayer.MAGHRIB -> "マグリブ"
                Prayer.ISHA -> "イシャ"
                else -> prayer.name
            }
            "de" -> when (prayer) {
                Prayer.FAJR -> "Fajr"
                Prayer.SUNRISE -> "Sonnenaufgang"
                Prayer.DHUHR -> "Dhuhr"
                Prayer.ASR -> "Asr"
                Prayer.MAGHRIB -> "Maghrib"
                Prayer.ISHA -> "Isha"
                else -> prayer.name
            }
            "it" -> when (prayer) {
                Prayer.FAJR -> "Fajr"
                Prayer.SUNRISE -> "Alba"
                Prayer.DHUHR -> "Dhuhr"
                Prayer.ASR -> "Asr"
                Prayer.MAGHRIB -> "Maghrib"
                Prayer.ISHA -> "Isha"
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
