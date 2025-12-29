package com.example.wprayer

import android.content.SharedPreferences
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.Wearable
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.Prayer
import com.batoulapps.adhan.PrayerTimes
import com.batoulapps.adhan.data.DateComponents
import java.util.*

abstract class BasePrayerComplicationService : SuspendingComplicationDataSourceService() {

    protected val dataListener = DataClient.OnDataChangedListener { dataEvents ->
        for (event in dataEvents) {
            if (event.type == DataEvent.TYPE_CHANGED) {
                val path = event.dataItem.uri.path
                if (path == "/prayer_location") {
                    val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap
                    try {
                        val lat = dataMap.getDouble("lat")
                        val long = dataMap.getDouble("long")
                        val method = dataMap.getString("method")
                        val prefs: SharedPreferences = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
                        val editor = prefs.edit()
                        editor.putString("flutter.flutter.lat", lat.toString())
                        editor.putString("flutter.flutter.long", long.toString())
                        if (method != null) {
                            editor.putString("flutter.calculation_method", method)
                        }
                        editor.apply()
                        
                        // Also reschedule alarms for the new location
                        PrayerUtils.rescheduleAlarms(applicationContext)
                    } catch (e: Exception) {
                        // ignore malformed data
                    }
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        Wearable.getDataClient(this).addListener(dataListener)
    }

    override fun onDestroy() {
        Wearable.getDataClient(this).removeListener(dataListener)
        super.onDestroy()
    }

    protected fun getNextPrayerData(): Triple<Prayer, Date, String> {
        val prefs: SharedPreferences = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        
        val lat = prefs.getString("flutter.flutter.lat", null)?.toDoubleOrNull() ?: 21.5433
        val long = prefs.getString("flutter.flutter.long", null)?.toDoubleOrNull() ?: 39.1728
        val languageCode = prefs.getString("flutter.language_code", null) ?: "en"
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
        val date = DateComponents.from(Date())
        val prayerTimes = PrayerTimes(coordinates, date, params)
        
        var nextPrayer = prayerTimes.nextPrayer()
        var nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer)
        
        if (nextPrayer == Prayer.NONE) {
            val tomorrow = Calendar.getInstance()
            tomorrow.add(Calendar.DAY_OF_MONTH, 1)
            val tomorrowDate = DateComponents.from(tomorrow.time)
            val tomorrowPrayerTimes = PrayerTimes(coordinates, tomorrowDate, params)
            nextPrayer = Prayer.FAJR
            nextPrayerTime = tomorrowPrayerTimes.fajr
        }
        
        return Triple(nextPrayer, nextPrayerTime!!, languageCode)
    }

    protected fun getLocalizedPrayerName(prayer: Prayer, languageCode: String): String {
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

    protected fun getLocalizedNextPrayerLabel(languageCode: String): String {
        return when (languageCode) {
            "ar" -> "الصلاة القادمة"
            else -> "Next Prayer"
        }
    }
    
    protected fun getLocalizedCountdownLabel(languageCode: String): String {
        return when (languageCode) {
            "ar" -> "الوقت المتبقي"
            else -> "Time Left"
        }
    }
}
