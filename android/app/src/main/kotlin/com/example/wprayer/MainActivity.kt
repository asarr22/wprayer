package com.example.wprayer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
	private val CHANNEL = "com.example.wprayer/location"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"syncLocationToWatch" -> {
						val lat = call.argument<Double>("lat")
						val long = call.argument<Double>("long")
						if (lat != null && long != null) {
							syncLocationToWatch(lat, long)
							result.success(null)
						} else {
							result.error("INVALID_ARGS", "lat and long required", null)
						}
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun syncLocationToWatch(lat: Double, long: Double) {
		CoroutineScope(Dispatchers.Default).launch {
			try {
				val putDataMapRequest = PutDataMapRequest.create("/prayer_location").apply {
					dataMap.putDouble("lat", lat)
					dataMap.putDouble("long", long)
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
