package com.example.wprayer

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.app.NotificationChannel
import android.app.NotificationManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class PrayerNotificationScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    fun showInstantNotification(prayerName: String, title: String, body: String) {
        val channelId = "prayer_notifications_v2"
        val notificationId = 777
        
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        with(NotificationManagerCompat.from(context)) {
            notify(notificationId, builder.build())
        }
        Log.d("PrayerScheduler", "Instant notification triggered")
    }

    fun schedulePrayer(id: Int, prayerName: String, title: String, body: String, timeInMillis: Long) {
        val intent = Intent(context, PrayerNotificationReceiver::class.java).apply {
            putExtra("prayer_name", prayerName)
            putExtra("title", title)
            putExtra("body", body)
            action = "com.example.wprayer.NOTIFICATION"
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeInMillis, pendingIntent)
                } else {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeInMillis, pendingIntent)
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeInMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, timeInMillis, pendingIntent)
            }
            Log.d("PrayerScheduler", "Scheduled $prayerName for $timeInMillis")
        } catch (e: Exception) {
            Log.e("PrayerScheduler", "Schedule failed for $prayerName", e)
        }
    }

    fun cancelAll() {
        Log.d("PrayerScheduler", "Clearing all alarms (0-100)")
        for (i in 0..100) {
            val intent = Intent(context, PrayerNotificationReceiver::class.java).apply {
                action = "com.example.wprayer.NOTIFICATION"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, i, intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_NO_CREATE
            )
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
        }
    }
}
