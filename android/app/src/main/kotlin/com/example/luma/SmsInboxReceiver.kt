package com.example.luma

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONArray

class SmsInboxReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        val bodies = messages.mapNotNull { it.messageBody }.joinToString("").trim()
        if (bodies.isEmpty() || !likelyTransaction(bodies)) return

        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        val queue = JSONArray(preferences.getString(QUEUE_KEY, "[]"))
        queue.put(bodies)
        preferences.edit().putString(QUEUE_KEY, queue.toString()).apply()

        postImmediate(context, queue.length())
    }

    private fun postImmediate(context: Context, queuedCount: Int) {
        try {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Expense alerts",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply { description = "New detected expense" }
                manager.createNotificationChannel(channel)
            }
            val launch = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pending = PendingIntent.getActivity(
                context,
                0,
                launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val text = if (queuedCount > 1) {
                "$queuedCount transactions detected — open Luma to categorize"
            } else {
                "New transaction detected — open Luma to categorize"
            }
            val icon = context.applicationInfo.icon.takeIf { it != 0 } ?: android.R.drawable.ic_dialog_info
            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(icon)
                .setContentTitle("Luma")
                .setContentText(text)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pending)
                .build()
            NotificationManagerCompat.from(context).notify(SUMMARY_ID, notification)
        } catch (_: SecurityException) {
            // Notifications permission denied — queue still holds the SMS.
        } catch (_: Exception) {
            // Never crash the receiver.
        }
    }

    companion object {
        const val PREFERENCES = "luma_sms_queue"
        const val QUEUE_KEY = "messages"
        const val CHANNEL_ID = "expense_alerts"
        const val SUMMARY_ID = 9000

        private val bareAmount = Regex("""(debited|paid|spent|withdrawn|transferred)\s+(?:by|for|with)\s+[\d,]+(?:\.\d{1,2})?""")

        fun likelyTransaction(message: String): Boolean {
            val lower = message.lowercase()
            val hasAmount = lower.contains("rs") || lower.contains("inr") || lower.contains("₹") ||
                bareAmount.containsMatchIn(lower)
            val hasTransactionWord = listOf(
                "debited", "debit", "spent", "paid", "payment", "upi",
                "withdrawn", "credited", "credit", "sent", "deducted",
                "transferred", "transfer"
            ).any(lower::contains)
            return hasAmount && hasTransactionWord
        }
    }
}
