package com.example.luma

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.io.File
import java.util.Calendar

/** Exact daily audit ("Luma Daily Check", SPEC 42).
 *
 * Fully native so it fires at 21:00 and survives reboot without a Dart
 * isolate: on fire it counts `status = 0` (pending) rows straight from the
 * Drift SQLite file, notifies only when the count is non-zero, then
 * schedules the next day. Hourly state lives in SharedPreferences so boot
 * can reschedule without touching the database.
 */
object DailyAudit {
    const val ACTION_FIRE = "com.example.luma.DAILY_AUDIT_FIRE"
    const val CHANNEL_ID = "daily_audit"
    private const val REQUEST_CODE = 9100
    private const val PREFS = "luma_audit"
    private const val KEY_ENABLED = "enabled"
    private const val KEY_HOUR = "hour"
    private const val KEY_MINUTE = "minute"

    fun schedule(context: Context, hour: Int, minute: Int) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean(KEY_ENABLED, true)
            .putInt(KEY_HOUR, hour)
            .putInt(KEY_MINUTE, minute)
            .apply()
        setExact(context, nextTriggerMillis(hour, minute))
    }

    fun cancel(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean(KEY_ENABLED, false)
            .apply()
        pendingIntent(context)?.let {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(it)
            it.cancel()
        }
        try {
            NotificationManagerCompat.from(context).cancel(NotifyId.SUMMARY)
        } catch (_: Exception) {
        }
    }

    fun rescheduleIfEnabled(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!prefs.getBoolean(KEY_ENABLED, false)) return
        setExact(context, nextTriggerMillis(prefs.getInt(KEY_HOUR, 21), prefs.getInt(KEY_MINUTE, 0)))
    }

    fun nextTriggerMillis(hour: Int, minute: Int, now: Long = System.currentTimeMillis()): Long {
        val cal = Calendar.getInstance().apply {
            timeInMillis = now
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        if (cal.timeInMillis <= now) cal.add(Calendar.DAY_OF_YEAR, 1)
        return cal.timeInMillis
    }

    private fun setExact(context: Context, triggerAt: Long) {
        val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = pendingIntent(context) ?: return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (manager.canScheduleExactAlarms()) {
                    manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, intent)
                    return
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, intent)
                return
            }
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, intent)
        } catch (_: SecurityException) {
            try {
                manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, intent)
            } catch (_: Exception) {
            }
        } catch (_: Exception) {
        }
    }

    private fun pendingIntent(context: Context): PendingIntent? {
        val intent = Intent(context, DailyAuditReceiver::class.java).apply { action = ACTION_FIRE }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return try {
            PendingIntent.getBroadcast(context, REQUEST_CODE, intent, flags)
        } catch (_: Exception) {
            null
        }
    }

    fun fire(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        // Always roll forward so one missed fire never kills the schedule.
        if (prefs.getBoolean(KEY_ENABLED, false)) {
            setExact(context, nextTriggerMillis(prefs.getInt(KEY_HOUR, 21), prefs.getInt(KEY_MINUTE, 0)))
        }
        val pending = countPending(context)
        if (pending <= 0) return
        try {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                manager.createNotificationChannel(
                    NotificationChannel(CHANNEL_ID, "Daily audit", NotificationManager.IMPORTANCE_DEFAULT)
                        .apply { description = "Daily pending-expense reminder" },
                )
            }
            val launch = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val content = PendingIntent.getActivity(
                context, 1, launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val text = if (pending == 1) {
                "You have 1 expense waiting to be completed."
            } else {
                "You have $pending expenses waiting to be completed."
            }
            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle("Luma Daily Check")
                .setContentText(text)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true)
                .setContentIntent(content)
                .build()
            NotificationManagerCompat.from(context).notify(NotifyId.SUMMARY, notification)
        } catch (_: SecurityException) {
        } catch (_: Exception) {
        }
    }

    private fun countPending(context: Context): Int {
        val dbFile = databaseFile(context) ?: return 0
        if (!dbFile.exists()) return 0
        var db: SQLiteDatabase? = null
        return try {
            db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READONLY)
            db.rawQuery("SELECT COUNT(*) FROM expenses WHERE status = 0", null).use { cursor ->
                if (cursor.moveToFirst()) cursor.getInt(0) else 0
            }
        } catch (_: Exception) {
            0
        } finally {
            try {
                db?.close()
            } catch (_: Exception) {
            }
        }
    }

    private fun databaseFile(context: Context): File? {
        return try {
            // path_provider documents dir: <dataDir>/app_flutter/luma.sqlite
            val parent = context.filesDir?.parentFile ?: return null
            File(File(parent, "app_flutter"), "luma.sqlite")
        } catch (_: Exception) {
            null
        }
    }

    private object NotifyId {
        const val SUMMARY = 9200
    }
}

class DailyAuditReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            DailyAudit.ACTION_FIRE -> DailyAudit.fire(context)
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED -> DailyAudit.rescheduleIfEnabled(context)
        }
    }
}
