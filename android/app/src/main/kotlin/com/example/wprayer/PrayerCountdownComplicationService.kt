package com.example.wprayer

import androidx.wear.watchface.complications.data.*
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import java.time.Instant

class PrayerCountdownComplicationService : BasePrayerComplicationService() {

    override fun getPreviewData(type: ComplicationType): ComplicationData? {
        return when (type) {
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(
                text = PlainComplicationText.Builder("25m").build(),
                contentDescription = PlainComplicationText.Builder("Time until next prayer").build()
            )
            .setTitle(PlainComplicationText.Builder("Asr").build())
            .build()
            
            ComplicationType.LONG_TEXT -> LongTextComplicationData.Builder(
                text = PlainComplicationText.Builder("Asr in 25 mins").build(),
                contentDescription = PlainComplicationText.Builder("Time until next prayer").build()
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
        val instant = Instant.ofEpochMilli(nextPrayerTime.time)
        
        // Use TimeDifferenceComplicationText for a live countdown updated by the system
        val countdownText = TimeDifferenceComplicationText.Builder(
            style = TimeDifferenceStyle.SHORT_DUAL_UNIT,
            countDownTimeReference = CountDownTimeReference(instant)
        ).build()
        
        return when (request.complicationType) {
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(
                text = countdownText,
                contentDescription = PlainComplicationText.Builder("Next Prayer ($prayerName) in...").build()
            )
            .setTitle(PlainComplicationText.Builder(prayerName).build())
            .build()
            
            ComplicationType.LONG_TEXT -> {
                LongTextComplicationData.Builder(
                    text = TimeDifferenceComplicationText.Builder(
                        style = TimeDifferenceStyle.WORDS_SINGLE_UNIT,
                        countDownTimeReference = CountDownTimeReference(instant)
                    )
                    .setText("${prayerName} in ^1") // ^1 is replaced by the time difference
                    .build(),
                    contentDescription = PlainComplicationText.Builder("Time until $prayerName").build()
                ).build()
            }
            
            else -> null
        }
    }
}
