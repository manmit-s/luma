package com.example.luma

import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity
import org.json.JSONArray

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			if (call.method != "drainSmsQueue") {
				result.notImplemented()
				return@setMethodCallHandler
			}

			val preferences = getSharedPreferences(SmsInboxReceiver.PREFERENCES, MODE_PRIVATE)
			val queue = JSONArray(preferences.getString(SmsInboxReceiver.QUEUE_KEY, "[]"))
			val messages = buildList {
				for (index in 0 until queue.length()) add(queue.getString(index))
			}
			preferences.edit().remove(SmsInboxReceiver.QUEUE_KEY).apply()
			result.success(messages)
		}
	}

	companion object {
		private const val CHANNEL = "luma/sms"
	}
}
