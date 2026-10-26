package com.volumncontroller.volumn_controller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Restarts the [VolumeNotificationService] after device boot
 * if the user previously enabled the persistent notification.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = context.getSharedPreferences("volumn_controller_prefs", Context.MODE_PRIVATE)
        val notificationEnabled = prefs.getBoolean("notification_enabled", false)

        if (notificationEnabled) {
            val serviceIntent = Intent(context, VolumeNotificationService::class.java)
            // startForegroundService is safe from API 26+; the service must call
            // startForeground() within the ANR timeout window.
            context.startForegroundService(serviceIntent)
        }
    }
}
