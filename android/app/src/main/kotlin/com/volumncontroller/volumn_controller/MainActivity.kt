package com.volumncontroller.volumn_controller

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main entry-point activity. Sets up a [MethodChannel] so the Flutter UI
 * can start/stop the notification service, adjust volume, and manage
 * preferences and permissions.
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.volumncontroller/volume"
        private const val PREFS_NAME = "volumn_controller_prefs"
        private const val REQUEST_NOTIFICATION_PERMISSION = 1001
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // ── Service control ──────────────────────────────────
                    "startNotificationService" -> {
                        val intent = Intent(this, VolumeNotificationService::class.java)
                        startForegroundService(intent)
                        result.success(true)
                    }

                    "stopNotificationService" -> {
                        val intent = Intent(this, VolumeNotificationService::class.java)
                        stopService(intent)
                        result.success(true)
                    }

                    "isNotificationServiceRunning" -> {
                        result.success(isServiceRunning(VolumeNotificationService::class.java))
                    }

                    // ── Volume actions ───────────────────────────────────
                    "adjustVolume" -> {
                        val directionStr = call.argument<String>("direction") ?: "up"
                        val streamName = call.argument<String>("streamType") ?: "media"
                        val streamType = VolumeHelper.resolveStreamType(streamName)
                        val direction = if (directionStr == "up")
                            AudioManager.ADJUST_RAISE else AudioManager.ADJUST_LOWER
                        VolumeHelper.adjustVolume(this, streamType, direction)
                        result.success(true)
                    }

                    "showVolumePanel" -> {
                        VolumeHelper.showVolumePanel(this)
                        result.success(true)
                    }

                    "getVolumeInfo" -> {
                        val streamName = call.argument<String>("streamType") ?: "media"
                        val streamType = VolumeHelper.resolveStreamType(streamName)
                        val info = VolumeHelper.getVolumeInfo(this, streamType)
                        result.success(info)
                    }

                    // ── Preferences ─────────────────────────────────────
                    "setVolumeStreamType" -> {
                        val streamType = call.argument<String>("streamType") ?: "media"
                        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            .edit()
                            .putString("volume_stream_type", streamType)
                            .apply()
                        result.success(true)
                    }

                    "getVolumeStreamType" -> {
                        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        result.success(prefs.getString("volume_stream_type", "media"))
                    }

                    "isNotificationEnabled" -> {
                        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        result.success(prefs.getBoolean("notification_enabled", false))
                    }

                    "setNotificationEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            .edit()
                            .putBoolean("notification_enabled", enabled)
                            .apply()

                        val serviceIntent = Intent(this, VolumeNotificationService::class.java)
                        if (enabled) {
                            startForegroundService(serviceIntent)
                        } else {
                            stopService(serviceIntent)
                        }
                        result.success(true)
                    }

                    // ── Permissions ──────────────────────────────────────
                    "hasNotificationPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            val granted = ContextCompat.checkSelfPermission(
                                this,
                                android.Manifest.permission.POST_NOTIFICATIONS
                            ) == PackageManager.PERMISSION_GRANTED
                            result.success(granted)
                        } else {
                            // Pre-API 33: no runtime permission needed
                            result.success(true)
                        }
                    }

                    "requestNotificationPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            pendingPermissionResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                                REQUEST_NOTIFICATION_PERMISSION
                            )
                        } else {
                            result.success(true)
                        }
                    }

                    "openNotificationSettings" -> {
                        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        }
                        startActivity(intent)
                        result.success(true)
                    }

                    "openBatteryOptimizationSettings" -> {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_NOTIFICATION_PERMISSION) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    /**
     * Checks whether the given [serviceClass] is currently running.
     */
    @Suppress("DEPRECATION")
    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
    }
}
