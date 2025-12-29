package com.example.wprayer

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wprayer/location"
    private val NOTIFICATION_CHANNEL = "com.example.wprayer/notifications"
    private lateinit var scheduler: PrayerNotificationScheduler

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        scheduler = PrayerNotificationScheduler(this)

        // Location sync channel for watch complications
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "syncLocationToWatch" -> {
                        val lat = call.argument<Double>("lat")
                        val long = call.argument<Double>("long")
                        val method = call.argument<String>("method") ?: "MWL"
                        if (lat != null && long != null) {
                            syncLocationToWatch(lat, long, method)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGS", "lat and long required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Native notification management channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleNotification" -> {
                        val id = call.argument<Int>("id") ?: 0
                        val name = call.argument<String>("name") ?: "Prayer"
                        val title = call.argument<String>("title") ?: "Prayer Time"
                        val body = call.argument<String>("body") ?: "Time for prayer"
                        val time = call.argument<Long>("time") ?: 0L
                        
                        scheduler.schedulePrayer(id, name, title, body, time)
                        result.success(null)
                    }
                    "cancelAllNotifications" -> {
                        scheduler.cancelAll()
                        result.success(null)
                    }
                    "createChannel" -> {
                        createNotificationChannel()
                        result.success(null)
                    }
                    "areNotificationsEnabled" -> {
                        val enabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
                        result.success(enabled)
                    }
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
                    "showInstantTest" -> {
                        scheduler.showInstantNotification("Test", "Instant Test Notification", "This is a direct test.")
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openNotificationSettings() {
        val intent = Intent().apply {
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
                    action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
                else -> {
                    action = "android.settings.APP_NOTIFICATION_SETTINGS"
                    putExtra("app_package", packageName)
                    putExtra("app_uid", applicationInfo.uid)
                }
            }
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        try {
            startActivity(intent)
        } catch (e: Exception) {
            val fallbackIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(fallbackIntent)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "prayer_notifications_v2"
            val name = "Prayer Reminders"
            val descriptionText = "Notifications for all prayer times"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, name, importance).apply {
                description = descriptionText
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun syncLocationToWatch(lat: Double, long: Double, method: String) {
        CoroutineScope(Dispatchers.Default).launch {
            try {
                val putDataMapRequest = PutDataMapRequest.create("/prayer_location").apply {
                    dataMap.putDouble("lat", lat)
                    dataMap.putDouble("long", long)
                    dataMap.putString("method", method)
                    dataMap.putLong("timestamp", System.currentTimeMillis())
                }
                val putDataRequest = putDataMapRequest.asPutDataRequest().setUrgent()
                Wearable.getDataClient(this@MainActivity).putDataItem(putDataRequest)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
