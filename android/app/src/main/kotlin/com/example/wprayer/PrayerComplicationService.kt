package com.example.wprayer

import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.data.LongTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import java.text.SimpleDateFormat
import java.util.*

class PrayerComplicationService : BasePrayerComplicationService() {

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
        val nextData = getNextPrayerData()
        val nextPrayer = nextData.component1()
        val nextPrayerTime = nextData.component2()
        val languageCode = nextData.component3()
        
        val prayerName = getLocalizedPrayerName(nextPrayer, languageCode)
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
}