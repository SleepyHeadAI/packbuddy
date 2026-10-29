package com.sleepyhead.packbuddy

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PackBuddyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.packbuddy_widget).apply {
                val title = widgetData.getString("trip_title", null) ?: "PackBuddy"
                val destination = widgetData.getString("trip_destination", null) ?: "Plan your next trip"
                val days = widgetData.getInt("trip_days", 0)
                val packing = widgetData.getString("trip_packing", null) ?: "0/0"
                val budget = widgetData.getString("trip_budget", null) ?: ""

                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_destination, destination)
                setTextViewText(
                    R.id.widget_days,
                    if (days > 0) "${days}d" else if (days == 0 && title != "PackBuddy") "Today" else "-"
                )
                setTextViewText(R.id.widget_packing, packing)
                setTextViewText(R.id.widget_budget, budget)

                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    Intent(context, MainActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
