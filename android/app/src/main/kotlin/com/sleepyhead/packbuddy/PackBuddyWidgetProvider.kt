package com.sleepyhead.packbuddy

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PackBuddyWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val tag = "PackBuddyWidget"
        for (widgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.packbuddy_widget)

                val mode = widgetData.getString("widget_mode", "auto") ?: "auto"
                val hasUpcomingTrip = widgetData.getBoolean("has_upcoming_trip", false)
                val visitedCount = safeGetInt(widgetData, "map_visited_count", 0)
                val worldPercent = widgetData.getString("map_world_percent", null) ?: "%0.0"
                val wishlistCount = safeGetInt(widgetData, "map_wishlist_count", 0)
                val continentsCount = safeGetInt(widgetData, "map_continents_count", 0)

                val tripTitle = widgetData.getString("trip_title", null)
                val tripDestination = widgetData.getString("trip_destination", null)
                val tripDays = safeGetInt(widgetData, "trip_days", -1)
                val tripPacking = widgetData.getString("trip_packing", null) ?: "0/0"
                val tripBudget = widgetData.getString("trip_budget", null) ?: ""

                // Decide whether to show World Map or Trip
                val showWorldMap = when (mode) {
                    "world_map" -> true
                    "trip" -> false
                    else -> !hasUpcomingTrip && (visitedCount > 0 || wishlistCount > 0)
                }

                if (showWorldMap) {
                    views.setTextViewText(R.id.widget_app_name, "PackBuddy • Dünya Haritası")
                    views.setTextViewText(R.id.widget_days, worldPercent)
                    views.setTextViewText(
                        R.id.widget_title,
                        if (visitedCount > 0) "$visitedCount Ülke Keşfedildi" else "Dünya Gezgin Haritası"
                    )
                    views.setTextViewText(
                        R.id.widget_destination,
                        if (continentsCount > 0) "$continentsCount Kıta • Dünyanın $worldPercent'si" else "Gezdiğin ülkeleri haritada işaretle"
                    )
                    views.setTextViewText(R.id.widget_packing, "✈️ $visitedCount Gezildi")
                    views.setTextViewText(
                        R.id.widget_budget,
                        if (wishlistCount > 0) "🌟 $wishlistCount Hedef" else "🌍 5 Kıta"
                    )
                } else if (hasUpcomingTrip && !tripTitle.isNullOrEmpty()) {
                    views.setTextViewText(R.id.widget_app_name, "PackBuddy • Seyahat")
                    views.setTextViewText(
                        R.id.widget_days,
                        if (tripDays > 0) "${tripDays} gün" else if (tripDays == 0) "Bugün" else "Hazır"
                    )
                    views.setTextViewText(R.id.widget_title, tripTitle)
                    views.setTextViewText(
                        R.id.widget_destination,
                        if (!tripDestination.isNullOrEmpty()) tripDestination else "Geri sayım başladı"
                    )
                    views.setTextViewText(R.id.widget_packing, "🎒 $tripPacking eşya")
                    views.setTextViewText(R.id.widget_budget, tripBudget)
                } else {
                    // Default / Welcome state
                    views.setTextViewText(R.id.widget_app_name, "PackBuddy")
                    views.setTextViewText(R.id.widget_days, "✈️")
                    views.setTextViewText(R.id.widget_title, "PackBuddy Seyahat")
                    views.setTextViewText(R.id.widget_destination, "Yeni rota oluştur veya haritayı aç")
                    views.setTextViewText(R.id.widget_packing, "🎒 Bavul Listesi")
                    views.setTextViewText(R.id.widget_budget, "🌍 Dünya Haritası")
                }

                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    widgetId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Throwable) {
                Log.e(tag, "Error updating PackBuddy widget $widgetId", e)
                try {
                    val fallback = RemoteViews(context.packageName, R.layout.packbuddy_widget)
                    fallback.setTextViewText(R.id.widget_app_name, "PackBuddy")
                    fallback.setTextViewText(R.id.widget_days, "✈️")
                    fallback.setTextViewText(R.id.widget_title, "PackBuddy")
                    fallback.setTextViewText(R.id.widget_destination, "Açmak için dokunun")
                    fallback.setTextViewText(R.id.widget_packing, "🎒 Hazır")
                    fallback.setTextViewText(R.id.widget_budget, "🌍 Harita")

                    val intent = Intent(context, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        widgetId,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    fallback.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                    appWidgetManager.updateAppWidget(widgetId, fallback)
                } catch (t: Throwable) {
                    Log.e(tag, "Fallback also failed", t)
                }
            }
        }
    }

    private fun safeGetInt(prefs: SharedPreferences, key: String, default: Int): Int {
        return try {
            prefs.getInt(key, default)
        } catch (_: Exception) {
            try {
                (prefs.all[key] as? Number)?.toInt() ?: default
            } catch (_: Exception) {
                default
            }
        }
    }
}
