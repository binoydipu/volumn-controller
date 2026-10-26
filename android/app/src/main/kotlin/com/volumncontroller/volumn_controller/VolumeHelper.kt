package com.volumncontroller.volumn_controller

import android.content.Context
import android.media.AudioManager

/**
 * Singleton helper that provides shared volume control logic
 * used by the notification service, widget providers, and broadcast receiver.
 */
object VolumeHelper {

    /** Maps user-facing stream type names to AudioManager constants. */
    private val STREAM_TYPE_MAP = mapOf(
        "media" to AudioManager.STREAM_MUSIC,
        "ringtone" to AudioManager.STREAM_RING,
        "alarm" to AudioManager.STREAM_ALARM,
        "system" to AudioManager.STREAM_SYSTEM
    )

    /**
     * Resolves a human-readable stream name to the corresponding
     * [AudioManager] stream constant. Defaults to [AudioManager.STREAM_MUSIC].
     */
    fun resolveStreamType(streamName: String): Int {
        return STREAM_TYPE_MAP[streamName] ?: AudioManager.STREAM_MUSIC
    }

    /**
     * Adjusts the volume for the given [streamType] in the specified [direction].
     *
     * @param context   Application or service context.
     * @param streamType One of [AudioManager.STREAM_MUSIC], STREAM_RING, etc.
     * @param direction  [AudioManager.ADJUST_RAISE] or [AudioManager.ADJUST_LOWER].
     */
    fun adjustVolume(context: Context, streamType: Int, direction: Int) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.adjustStreamVolume(streamType, direction, AudioManager.FLAG_SHOW_UI)
    }

    /**
     * Opens Android's native volume panel by performing a zero-delta adjustment
     * with the [AudioManager.FLAG_SHOW_UI] flag.
     */
    fun showVolumePanel(context: Context) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            AudioManager.ADJUST_SAME,
            AudioManager.FLAG_SHOW_UI
        )
    }

    /**
     * Returns a map containing current, min, and max volume for the given [streamType].
     *
     * Keys: "current", "min", "max".
     */
    fun getVolumeInfo(context: Context, streamType: Int): Map<String, Int> {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val current = audioManager.getStreamVolume(streamType)
        val max = audioManager.getStreamMaxVolume(streamType)
        val min = audioManager.getStreamMinVolume(streamType)
        return mapOf(
            "current" to current,
            "min" to min,
            "max" to max
        )
    }
}
