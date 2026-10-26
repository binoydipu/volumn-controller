package com.volumncontroller.volumn_controller

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * 1×1 home-screen widget with a single button that opens the system volume panel.
 */
class VolumeWidget1x1 : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_1x1)

            // Single button → open volume panel
            val panelIntent = Intent(context, VolumeActionReceiver::class.java).apply {
                action = VolumeActionReceiver.ACTION_SHOW_PANEL
            }
            val panelPending = PendingIntent.getBroadcast(
                context, appWidgetId,
                panelIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_panel, panelPending)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
