package com.volumncontroller.volumn_controller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager

/**
 * BroadcastReceiver that handles volume-control actions dispatched from
 * the persistent notification and home-screen widgets.
 */
class VolumeActionReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_VOLUME_UP = "com.volumncontroller.ACTION_VOLUME_UP"
        const val ACTION_VOLUME_DOWN = "com.volumncontroller.ACTION_VOLUME_DOWN"
        const val ACTION_SHOW_PANEL = "com.volumncontroller.ACTION_SHOW_PANEL"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val prefs = context.getSharedPreferences("volumn_controller_prefs", Context.MODE_PRIVATE)
        val streamName = prefs.getString("volume_stream_type", "media") ?: "media"
        val streamType = VolumeHelper.resolveStreamType(streamName)

        when (intent.action) {
            ACTION_VOLUME_UP -> {
                VolumeHelper.adjustVolume(context, streamType, AudioManager.ADJUST_RAISE)
            }
            ACTION_VOLUME_DOWN -> {
                VolumeHelper.adjustVolume(context, streamType, AudioManager.ADJUST_LOWER)
            }
            ACTION_SHOW_PANEL -> {
                // Bring up the system volume panel
                VolumeHelper.showVolumePanel(context)
            }
        }
    }
}
