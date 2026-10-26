package com.volumncontroller.volumn_controller

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * 1×2 home-screen widget with two buttons: Vol − and Vol +.
 */
class VolumeWidget1x2 : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_1x2)

            // Volume Down button
            val volDownIntent = Intent(context, VolumeActionReceiver::class.java).apply {
                action = VolumeActionReceiver.ACTION_VOLUME_DOWN
            }
            val volDownPending = PendingIntent.getBroadcast(
                context, appWidgetId * 10,
                volDownIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_vol_down, volDownPending)

            // Volume Up button
            val volUpIntent = Intent(context, VolumeActionReceiver::class.java).apply {
                action = VolumeActionReceiver.ACTION_VOLUME_UP
            }
            val volUpPending = PendingIntent.getBroadcast(
                context, appWidgetId * 10 + 1,
                volUpIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_vol_up, volUpPending)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
