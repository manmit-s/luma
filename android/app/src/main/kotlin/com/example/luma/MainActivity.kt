package com.example.luma

import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity
import org.json.JSONArray

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"drainSmsQueue" -> {
					val preferences = getSharedPreferences(SmsInboxReceiver.PREFERENCES, MODE_PRIVATE)
					val queue = JSONArray(preferences.getString(SmsInboxReceiver.QUEUE_KEY, "[]"))
					val messages = buildList {
						for (index in 0 until queue.length()) add(queue.getString(index))
					}
					preferences.edit().remove(SmsInboxReceiver.QUEUE_KEY).apply()
					result.success(messages)
				}
				"scanInboxSms" -> {
					val limit = (call.argument<Int>("limit") ?: 50).coerceIn(1, 200)
					result.success(scanInbox(limit))
				}
				// Diagnostics: how many receiver-queued SMS are still waiting.
				// Non-destructive (does NOT drain) so Settings can display it.
				"smsQueueSize" -> {
					val preferences = getSharedPreferences(SmsInboxReceiver.PREFERENCES, MODE_PRIVATE)
					val queue = JSONArray(preferences.getString(SmsInboxReceiver.QUEUE_KEY, "[]"))
					result.success(queue.length())
				}
				// Best-effort jump to the OEM autostart / background-start
				// screen. Xiaomi/Oppo/Vivo/Realme block manifest receivers
				// for apps without it — the #1 real-world cause of "SMS
				// arrived but Luma never saw it".
				"openAutostartSettings" -> {
					result.success(openAutostartSettings())
				}
				"scheduleAudit" -> {
					val hour = (call.argument<Int>("hour") ?: 21).coerceIn(0, 23)
					val minute = (call.argument<Int>("minute") ?: 0).coerceIn(0, 59)
					DailyAudit.schedule(this, hour, minute)
					result.success(null)
				}
				"cancelAudit" -> {
					DailyAudit.cancel(this)
					result.success(null)
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun scanInbox(limit: Int): List<String> {
		val messages = mutableListOf<String>()
		try {
			val cursor = contentResolver.query(
				android.provider.Telephony.Sms.Inbox.CONTENT_URI,
				arrayOf(android.provider.Telephony.Sms.Inbox.BODY),
				null,
				null,
				"${android.provider.Telephony.Sms.Inbox.DATE} DESC"
			)
			cursor?.use {
				val bodyIndex = it.getColumnIndex(android.provider.Telephony.Sms.Inbox.BODY)
				while (it.moveToNext() && messages.size < limit) {
					val body = it.getString(bodyIndex) ?: continue
					if (SmsInboxReceiver.likelyTransaction(body)) {
						messages.add(body)
					}
				}
			}
		} catch (_: SecurityException) {
			// Permission not granted.
		} catch (_: Exception) {
		}
		return messages
	}

	private fun openAutostartSettings(): Boolean {
		val candidates = when (Build.MANUFACTURER.lowercase()) {
			"xiaomi" -> listOf(
				"com.miui.securitycenter/com.miui.permcenter.autostart.AutoStartManagementActivity",
			)
			"oppo", "realme", "oneplus" -> listOf(
				"com.coloros.safecenter/.startupapp.StartupAppListActivity",
				"com.oppo.safe/.permission.startup.StartupAppListActivity",
			)
			"vivo" -> listOf(
				"com.iqoo.secure/.safeguard.PurviewTabActivity",
				"com.vivo.permissionmanager/.activity.BgStartUpManagerActivity",
			)
			"huawei", "honor" -> listOf(
				"com.huawei.systemmanager/.startupmgr.ui.StartupNormalAppListActivity",
			)
			"samsung" -> listOf(
				"com.samsung.android.lool/.battery.BatteryActivity",
			)
			else -> emptyList()
		}
		for (component in candidates) {
			try {
				val slash = component.indexOf('/')
				val intent = Intent().setComponent(
					ComponentName(
						component.substring(0, slash),
						component.substring(slash + 1),
					),
				).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
				startActivity(intent)
				return true
			} catch (_: Exception) {
			}
		}
		return false
	}

	companion object {
		private const val CHANNEL = "luma/sms"
	}
}
