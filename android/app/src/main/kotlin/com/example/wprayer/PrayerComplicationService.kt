package com.example.wprayer

import android.content.SharedPreferences
import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.data.LongTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.Prayer
import com.batoulapps.adhan.PrayerTimes
import com.batoulapps.adhan.data.DateComponents
import java.text.SimpleDateFormat
import java.util.*

class PrayerComplicationService : SuspendingComplicationDataSourceService() {

    override fun getPreviewData(type: ComplicationType): ComplicationData? {
        return when (type) {
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(
                text = PlainComplicationText.Builder("15:30").build(),
                contentDescription = PlainComplicationText.Builder("Next Prayer").build()
            )
            .setTitle(PlainComplicationText.Builder("Asr").build())
            .build()
            
            ComplicationType.LONG_TEXT -> LongTextComplicationData.Builder(
                text = PlainComplicationText.Builder("Next Prayer: Asr 15:30").build(),
                contentDescription = PlainComplicationText.Builder("Next Prayer Time").build()
            ).build()
            
            else -> null
        }
    }

    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val prefs: SharedPreferences = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        
        // Get location
        val lat = prefs.getString("flutter.lat", null)?.toDoubleOrNull() ?: 21.5433
        val long = prefs.getString("flutter.long", null)?.toDoubleOrNull() ?: 39.1728
        
        // Get language preference
        val languageCode = prefs.getString("flutter.language_code", null) ?: "en"
        
        // Calculate prayer times
        val coordinates = Coordinates(lat, long)
        val params = CalculationMethod.UMM_AL_QURA.parameters
        val date = DateComponents.from(Date())
        val prayerTimes = PrayerTimes(coordinates, date, params)
        
        // Get next prayer
        var nextPrayer = prayerTimes.nextPrayer()
        var nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer)
        
        // If no prayer left today, get Fajr of tomorrow
        if (nextPrayer == Prayer.NONE) {
            val tomorrow = Calendar.getInstance()
            tomorrow.add(Calendar.DAY_OF_MONTH, 1)
            val tomorrowDate = DateComponents.from(tomorrow.time)
            val tomorrowPrayerTimes = PrayerTimes(coordinates, tomorrowDate, params)
            nextPrayer = Prayer.FAJR
            nextPrayerTime = tomorrowPrayerTimes.fajr
        }
        
        // Get localized prayer name
        val prayerName = getLocalizedPrayerName(nextPrayer, languageCode)
        
        // Format time
        val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
        val timeStr = timeFormat.format(nextPrayerTime)
        
        return when (request.complicationType) {
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(
                text = PlainComplicationText.Builder(timeStr).build(),
                contentDescription = PlainComplicationText.Builder("Next Prayer: $prayerName").build()
            )
            .setTitle(PlainComplicationText.Builder(prayerName).build())
            .build()
            
            ComplicationType.LONG_TEXT -> {
                val nextPrayerLabel = getLocalizedNextPrayerLabel(languageCode)
                LongTextComplicationData.Builder(
                    text = PlainComplicationText.Builder("$nextPrayerLabel: $prayerName $timeStr").build(),
                    contentDescription = PlainComplicationText.Builder("Next Prayer Time").build()
                ).build()
            }
            
            else -> null
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
            else -> when (prayer) { // English (default)
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
    
    private fun getLocalizedNextPrayerLabel(languageCode: String): String {
        return when (languageCode) {
            "ar" -> "الصلاة القادمة"
            else -> "Next Prayer" // English (default)
        }
    }
}