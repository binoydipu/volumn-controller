package com.volumncontroller.volumn_controller

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Foreground service that keeps a persistent notification with
 * quick-action buttons for volume control (Vol −, Vol +, Panel).
 */
class VolumeNotificationService : Service() {

    companion object {
        const val CHANNEL_ID = "volume_controls"
        const val NOTIFICATION_ID = 1
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Read preferred stream type (used by the receiver when actions fire)
        val prefs = getSharedPreferences("volumn_controller_prefs", Context.MODE_PRIVATE)
        val streamType = prefs.getString("volume_stream_type", "media") ?: "media"

        val notification = buildNotification()

        // On API 34+ we must specify the foreground service type in startForeground()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        return START_STICKY
    }

    override fun onDestroy() {
        stopForeground(STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }

    // ---------------------------------------------------------------
    // Private helpers
    // ---------------------------------------------------------------

    /** Creates the low-importance notification channel (no sound/vibration). */
    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Volume Controls",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Persistent volume control notification"
            setSound(null, null)
            enableVibration(false)
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    /** Builds the persistent notification with three action buttons. */
    private fun buildNotification(): Notification {
        // --- PendingIntents for each action ---
        val volDownIntent = Intent(this, VolumeActionReceiver::class.java).apply {
            action = VolumeActionReceiver.ACTION_VOLUME_DOWN
        }
        val volDownPending = PendingIntent.getBroadcast(
            this, 0, volDownIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val volUpIntent = Intent(this, VolumeActionReceiver::class.java).apply {
            action = VolumeActionReceiver.ACTION_VOLUME_UP
        }
        val volUpPending = PendingIntent.getBroadcast(
            this, 1, volUpIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val panelIntent = Intent(this, VolumeActionReceiver::class.java).apply {
            action = VolumeActionReceiver.ACTION_SHOW_PANEL
        }
        val panelPending = PendingIntent.getBroadcast(
            this, 2, panelIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Volumn Controller")
            .setContentText("Volume controls active")
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode_off)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(0, "Vol −", volDownPending)
            .addAction(0, "Vol +", volUpPending)
            .addAction(0, "Panel", panelPending)
            .build()
    }
}
