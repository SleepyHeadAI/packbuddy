package com.sleepyhead.packbuddy

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

enum class WidgetLayoutSize {
    SMALL,
    MEDIUM,
    LARGE
}

open class PackBuddyWidgetProvider : HomeWidgetProvider() {

    protected open val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.SMALL

    companion object {
        const val TAG = "PackBuddyWidget"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val widgetData = HomeWidgetPlugin.getData(context)
        updateSingleWidget(context, appWidgetManager, appWidgetId, widgetData, newOptions)
    }

    fun updateSingleWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences,
        options: Bundle?
    ) {
        try {
            // Android 12+ (API 31+) native responsive layout mapping
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val smallViews = buildRemoteViews(context, widgetData, WidgetLayoutSize.SMALL, widgetId)
                val mediumViews = buildRemoteViews(context, widgetData, WidgetLayoutSize.MEDIUM, widgetId)
                val largeViews = buildRemoteViews(context, widgetData, WidgetLayoutSize.LARGE, widgetId)

                val viewsMap = mapOf(
                    SizeF(100f, 100f) to smallViews,
                    SizeF(210f, 100f) to mediumViews,
                    SizeF(210f, 170f) to largeViews
                )
                val responsiveViews = RemoteViews(viewsMap)
                appWidgetManager.updateAppWidget(widgetId, responsiveViews)
                return
            }

            // Android 11 and below dynamic layout selection based on measured dp
            val opts = options ?: appWidgetManager.getAppWidgetOptions(widgetId)
            val minWidth = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0) ?: 0
            val minHeight = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0) ?: 0

            val chosenSize = when {
                minHeight >= 170 -> WidgetLayoutSize.LARGE
                minWidth >= 210 -> WidgetLayoutSize.MEDIUM
                defaultLayoutSize != WidgetLayoutSize.SMALL -> defaultLayoutSize
                else -> WidgetLayoutSize.SMALL
            }

            val views = buildRemoteViews(context, widgetData, chosenSize, widgetId)
            appWidgetManager.updateAppWidget(widgetId, views)
        } catch (e: Throwable) {
            Log.e(TAG, "Error updating widget $widgetId", e)
            try {
                val fallback = RemoteViews(context.packageName, R.layout.packbuddy_widget_small)
                fallback.setTextViewText(R.id.widget_app_name, "PackBuddy")
                fallback.setTextViewText(R.id.widget_title, "PackBuddy")
                fallback.setTextViewText(R.id.widget_destination, "Tap to open")
                appWidgetManager.updateAppWidget(widgetId, fallback)
            } catch (_: Throwable) {}
        }
    }

    private fun buildRemoteViews(
        context: Context,
        widgetData: SharedPreferences,
        size: WidgetLayoutSize,
        widgetId: Int
    ): RemoteViews {
        val layoutId = when (size) {
            WidgetLayoutSize.SMALL -> R.layout.packbuddy_widget_small
            WidgetLayoutSize.MEDIUM -> R.layout.packbuddy_widget_medium
            WidgetLayoutSize.LARGE -> R.layout.packbuddy_widget_large
        }

        val views = RemoteViews(context.packageName, layoutId)

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

        // Pre-formatted localized texts from Flutter
        val customAppName = widgetData.getString("custom_app_name", null)
        val customDays = widgetData.getString("custom_days", null)
        val customTitle = widgetData.getString("custom_title", null)
        val customSubtitle = widgetData.getString("custom_subtitle", null)
        val customStat1 = widgetData.getString("custom_stat1", null)
        val customStat2 = widgetData.getString("custom_stat2", null)
        val customStat3 = widgetData.getString("custom_stat3", null)

        val widgetTheme = widgetData.getString("widget_theme", "midnight") ?: "midnight"
        val bgRes: Int
        val mapBgRes: Int
        val statBgRes: Int
        val badgeBgRes: Int
        val textColor: Int
        val subtextColor: Int
        val appNameColor: Int

        when (widgetTheme) {
            "sunset" -> {
                bgRes = R.drawable.widget_bg_sunset
                mapBgRes = R.drawable.widget_map_bg_sunset
                statBgRes = R.drawable.widget_stat_bg_sunset
                badgeBgRes = R.drawable.widget_badge_bg_sunset
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#FED7AA")
                appNameColor = android.graphics.Color.parseColor("#FB923C")
            }
            "emerald" -> {
                bgRes = R.drawable.widget_bg_emerald
                mapBgRes = R.drawable.widget_map_bg_emerald
                statBgRes = R.drawable.widget_stat_bg_emerald
                badgeBgRes = R.drawable.widget_badge_bg_emerald
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#A7F3D0")
                appNameColor = android.graphics.Color.parseColor("#34D399")
            }
            "cyberpunk" -> {
                bgRes = R.drawable.widget_bg_cyberpunk
                mapBgRes = R.drawable.widget_map_bg_cyberpunk
                statBgRes = R.drawable.widget_stat_bg_cyberpunk
                badgeBgRes = R.drawable.widget_badge_bg_cyberpunk
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#94A3B8")
                appNameColor = android.graphics.Color.parseColor("#06B6D4")
            }
            "volcano" -> {
                bgRes = R.drawable.widget_bg_volcano
                mapBgRes = R.drawable.widget_map_bg_volcano
                statBgRes = R.drawable.widget_stat_bg_volcano
                badgeBgRes = R.drawable.widget_badge_bg_volcano
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#FFCCBC")
                appNameColor = android.graphics.Color.parseColor("#FF5722")
            }
            "nordicForest", "nordic_forest" -> {
                bgRes = R.drawable.widget_bg_nordic_forest
                mapBgRes = R.drawable.widget_map_bg_nordic_forest
                statBgRes = R.drawable.widget_stat_bg_nordic_forest
                badgeBgRes = R.drawable.widget_badge_bg_nordic_forest
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#BAE6FD")
                appNameColor = android.graphics.Color.parseColor("#38BDF8")
            }
            "goldenHour", "golden_hour" -> {
                bgRes = R.drawable.widget_bg_golden_hour
                mapBgRes = R.drawable.widget_map_bg_golden_hour
                statBgRes = R.drawable.widget_stat_bg_golden_hour
                badgeBgRes = R.drawable.widget_badge_bg_golden_hour
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#FEF3C7")
                appNameColor = android.graphics.Color.parseColor("#F59E0B")
            }
            "galaxy" -> {
                bgRes = R.drawable.widget_bg_galaxy
                mapBgRes = R.drawable.widget_map_bg_galaxy
                statBgRes = R.drawable.widget_stat_bg_galaxy
                badgeBgRes = R.drawable.widget_badge_bg_galaxy
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#E9D5FF")
                appNameColor = android.graphics.Color.parseColor("#C084FC")
            }
            "monochromeDark", "monochrome_dark" -> {
                bgRes = R.drawable.widget_bg_monochrome_dark
                mapBgRes = R.drawable.widget_map_bg_monochrome_dark
                statBgRes = R.drawable.widget_stat_bg_monochrome_dark
                badgeBgRes = R.drawable.widget_badge_bg_monochrome_dark
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#94A3B8")
                appNameColor = android.graphics.Color.parseColor("#CBD5E1")
            }
            "minimalLight", "minimal_light", "light" -> {
                bgRes = R.drawable.widget_bg_minimal_light
                mapBgRes = R.drawable.widget_map_bg_minimal_light
                statBgRes = R.drawable.widget_stat_bg_minimal_light
                badgeBgRes = R.drawable.widget_badge_bg_minimal_light
                textColor = android.graphics.Color.parseColor("#0F172A")
                subtextColor = android.graphics.Color.parseColor("#475569")
                appNameColor = android.graphics.Color.parseColor("#0F172A")
            }
            "sandLight", "sand_light" -> {
                bgRes = R.drawable.widget_bg_sand_light
                mapBgRes = R.drawable.widget_map_bg_sand_light
                statBgRes = R.drawable.widget_stat_bg_sand_light
                badgeBgRes = R.drawable.widget_badge_bg_sand_light
                textColor = android.graphics.Color.parseColor("#292524")
                subtextColor = android.graphics.Color.parseColor("#78716C")
                appNameColor = android.graphics.Color.parseColor("#B45309")
            }
            "oceanLight", "ocean_light", "ocean" -> {
                bgRes = R.drawable.widget_bg_ocean_light
                mapBgRes = R.drawable.widget_map_bg_ocean_light
                statBgRes = R.drawable.widget_stat_bg_ocean_light
                badgeBgRes = R.drawable.widget_badge_bg_ocean_light
                textColor = android.graphics.Color.parseColor("#0C4A6E")
                subtextColor = android.graphics.Color.parseColor("#0369A1")
                appNameColor = android.graphics.Color.parseColor("#0284C7")
            }
            "cherryBlossom", "cherry_blossom" -> {
                bgRes = R.drawable.widget_bg_cherry_blossom
                mapBgRes = R.drawable.widget_map_bg_cherry_blossom
                statBgRes = R.drawable.widget_stat_bg_cherry_blossom
                badgeBgRes = R.drawable.widget_badge_bg_cherry_blossom
                textColor = android.graphics.Color.parseColor("#4C0519")
                subtextColor = android.graphics.Color.parseColor("#9F1239")
                appNameColor = android.graphics.Color.parseColor("#BE123C")
            }
            "vintageSepia", "vintage_sepia" -> {
                bgRes = R.drawable.widget_bg_vintage_sepia
                mapBgRes = R.drawable.widget_map_bg_vintage_sepia
                statBgRes = R.drawable.widget_stat_bg_vintage_sepia
                badgeBgRes = R.drawable.widget_badge_bg_vintage_sepia
                textColor = android.graphics.Color.parseColor("#422006")
                subtextColor = android.graphics.Color.parseColor("#713F12")
                appNameColor = android.graphics.Color.parseColor("#854D0E")
            }
            "matcha" -> {
                bgRes = R.drawable.widget_bg_matcha
                mapBgRes = R.drawable.widget_map_bg_matcha
                statBgRes = R.drawable.widget_stat_bg_matcha
                badgeBgRes = R.drawable.widget_badge_bg_matcha
                textColor = android.graphics.Color.parseColor("#14532D")
                subtextColor = android.graphics.Color.parseColor("#166534")
                appNameColor = android.graphics.Color.parseColor("#3F6212")
            }
            "pastelDream", "pastel_dream" -> {
                bgRes = R.drawable.widget_bg_pastel_dream
                mapBgRes = R.drawable.widget_map_bg_pastel_dream
                statBgRes = R.drawable.widget_stat_bg_pastel_dream
                badgeBgRes = R.drawable.widget_badge_bg_pastel_dream
                textColor = android.graphics.Color.parseColor("#4C1D95")
                subtextColor = android.graphics.Color.parseColor("#6D28D9")
                appNameColor = android.graphics.Color.parseColor("#6D28D9")
            }
            else -> { // midnight
                bgRes = R.drawable.widget_bg_midnight
                mapBgRes = R.drawable.widget_map_bg_midnight
                statBgRes = R.drawable.widget_stat_bg_midnight
                badgeBgRes = R.drawable.widget_badge_bg_midnight
                textColor = android.graphics.Color.parseColor("#FFFFFF")
                subtextColor = android.graphics.Color.parseColor("#94A3B8")
                appNameColor = android.graphics.Color.parseColor("#60A5FA")
            }
        }

        try {
            views.setInt(R.id.widget_container, "setBackgroundResource", bgRes)
            views.setTextColor(R.id.widget_title, textColor)
            views.setTextColor(R.id.widget_destination, subtextColor)
            views.setTextColor(R.id.widget_app_name, appNameColor)
            views.setInt(R.id.widget_days, "setBackgroundResource", badgeBgRes)
            views.setInt(R.id.widget_packing, "setBackgroundResource", statBgRes)
            views.setInt(R.id.widget_budget, "setBackgroundResource", statBgRes)
            views.setInt(R.id.widget_stat3, "setBackgroundResource", statBgRes)
        } catch (_: Throwable) {}

        try {
            views.setInt(R.id.widget_map_container, "setBackgroundResource", mapBgRes)
        } catch (_: Throwable) {}

        val showWorldMap = when (mode) {
            "world_map" -> true
            "trip" -> false
            else -> !hasUpcomingTrip && (visitedCount > 0 || wishlistCount > 0)
        }

        val isTurkish = java.util.Locale.getDefault().language.equals("tr", ignoreCase = true)

        if (size == WidgetLayoutSize.LARGE && showWorldMap) {
            views.setViewVisibility(R.id.widget_title_row, View.GONE)
            views.setViewVisibility(R.id.widget_title, View.GONE)
            views.setViewVisibility(R.id.widget_destination, View.GONE)
            views.setViewVisibility(R.id.widget_bottom_stats, View.GONE)
        } else {
            if (size == WidgetLayoutSize.LARGE) {
                views.setViewVisibility(R.id.widget_title_row, View.VISIBLE)
                views.setViewVisibility(R.id.widget_title, View.VISIBLE)
                views.setViewVisibility(R.id.widget_bottom_stats, View.VISIBLE)
            }
            if (showWorldMap || customSubtitle.isNullOrEmpty()) {
                views.setViewVisibility(R.id.widget_destination, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_destination, View.VISIBLE)
            }
        }

        if (!customTitle.isNullOrEmpty()) {
            views.setTextViewText(R.id.widget_app_name, customAppName ?: "PackBuddy")
            views.setTextViewText(R.id.widget_days, customDays ?: "")
            views.setTextViewText(R.id.widget_title, customTitle)
            if (!customSubtitle.isNullOrEmpty() && !showWorldMap) {
                views.setTextViewText(R.id.widget_destination, customSubtitle)
            }
            views.setTextViewText(R.id.widget_packing, customStat1 ?: "")

            if (showWorldMap) {
                if (size == WidgetLayoutSize.LARGE) {
                    views.setTextViewText(R.id.widget_budget, customStat2 ?: "")
                    if (!customStat3.isNullOrEmpty()) {
                        views.setTextViewText(R.id.widget_stat3, customStat3)
                    }
                } else {
                    val stat2 = if (wishlistCount == 0 && continentsCount > 0 && !customStat3.isNullOrEmpty()) {
                        customStat3
                    } else {
                        customStat2 ?: ""
                    }
                    views.setTextViewText(R.id.widget_budget, stat2)
                }
            } else {
                views.setTextViewText(R.id.widget_budget, customStat2 ?: "")
                if (!customStat3.isNullOrEmpty()) {
                    views.setTextViewText(R.id.widget_stat3, customStat3)
                }
            }
        } else if (showWorldMap) {
            views.setTextViewText(R.id.widget_app_name, if (isTurkish) "PackBuddy • Dünya" else "PackBuddy • World")
            views.setTextViewText(R.id.widget_days, worldPercent)
            views.setTextViewText(
                R.id.widget_title,
                if (visitedCount > 0) {
                    if (isTurkish) "$visitedCount Ülke Gezildi" else (if (visitedCount == 1) "1 Country Visited" else "$visitedCount Countries Visited")
                } else {
                    if (isTurkish) "Dünya Haritası" else "World Map"
                }
            )
            views.setViewVisibility(R.id.widget_destination, View.GONE)
            views.setTextViewText(R.id.widget_packing, if (isTurkish) "✈️ $visitedCount Gezildi" else "✈️ $visitedCount Visited")
            if (size == WidgetLayoutSize.LARGE) {
                views.setTextViewText(R.id.widget_budget, if (isTurkish) "🌟 $wishlistCount Hedef" else "🌟 $wishlistCount Wishlist")
                views.setTextViewText(R.id.widget_stat3, if (isTurkish) "🌍 $continentsCount Kıta" else (if (continentsCount == 1) "🌍 1 Continent" else "🌍 $continentsCount Continents"))
            } else {
                val stat2 = if (wishlistCount == 0 && continentsCount > 0) {
                    if (isTurkish) "🌍 $continentsCount Kıta" else (if (continentsCount == 1) "🌍 1 Continent" else "🌍 $continentsCount Continents")
                } else {
                    if (isTurkish) "🌟 $wishlistCount Hedef" else "🌟 $wishlistCount Wishlist"
                }
                views.setTextViewText(R.id.widget_budget, stat2)
            }
        } else if (hasUpcomingTrip && !tripTitle.isNullOrEmpty()) {
            views.setTextViewText(R.id.widget_app_name, if (isTurkish) "PackBuddy • Seyahat" else "PackBuddy • Trip")
            views.setTextViewText(
                R.id.widget_days,
                if (tripDays > 0) {
                    if (isTurkish) "${tripDays}g" else "${tripDays}d"
                } else if (tripDays == 0) {
                    if (isTurkish) "Bugün" else "Today"
                } else {
                    if (isTurkish) "Hazır" else "Ready"
                }
            )
            views.setTextViewText(R.id.widget_title, tripTitle)
            views.setTextViewText(
                R.id.widget_destination,
                if (!tripDestination.isNullOrEmpty()) tripDestination else (if (isTurkish) "Geri sayım başladı" else "Countdown active")
            )
            views.setViewVisibility(R.id.widget_destination, View.VISIBLE)
            views.setTextViewText(R.id.widget_packing, if (isTurkish) "🎒 $tripPacking" else "🎒 $tripPacking packed")
            views.setTextViewText(R.id.widget_budget, tripBudget)
        } else {
            views.setTextViewText(R.id.widget_app_name, "PackBuddy")
            views.setTextViewText(R.id.widget_days, "✈️")
            views.setTextViewText(R.id.widget_title, if (isTurkish) "PackBuddy Seyahat" else "PackBuddy Travel")
            views.setTextViewText(R.id.widget_destination, if (isTurkish) "Yeni rota oluştur veya haritayı aç" else "Plan a trip or explore the map")
            views.setViewVisibility(R.id.widget_destination, View.VISIBLE)
            views.setTextViewText(R.id.widget_packing, if (isTurkish) "🎒 Bavul Listesi" else "🎒 Packing List")
            views.setTextViewText(R.id.widget_budget, if (isTurkish) "🌍 Dünya Haritası" else "🌍 World Map")
        }

        // Set 3rd stat label for Large layout if view exists
        try {
            if (size == WidgetLayoutSize.LARGE) {
                if (!customStat3.isNullOrEmpty()) {
                    views.setTextViewText(R.id.widget_stat3, customStat3)
                } else if (showWorldMap) {
                    val stat3 = if (isTurkish) "🌍 $continentsCount Kıta" else (if (continentsCount == 1) "🌍 1 Continent" else "🌍 $continentsCount Continents")
                    views.setTextViewText(R.id.widget_stat3, stat3)
                }
            }
        } catch (_: Throwable) {}

        // Map Image Rendering for Medium and Large
        if (size != WidgetLayoutSize.SMALL && showWorldMap) {
            val mapPath = when (size) {
                WidgetLayoutSize.LARGE -> widgetData.getString("map_image_large", null)
                    ?: widgetData.getString("map_image_medium", null)
                WidgetLayoutSize.MEDIUM -> widgetData.getString("map_image_medium", null)
                    ?: widgetData.getString("map_image_large", null)
                WidgetLayoutSize.SMALL -> null
            }

            if (!mapPath.isNullOrEmpty()) {
                val file = File(mapPath)
                if (file.exists() && file.length() > 0) {
                    try {
                        val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                        if (bitmap != null) {
                            views.setImageViewBitmap(R.id.widget_map_image, bitmap)
                            views.setViewVisibility(R.id.widget_map_image, View.VISIBLE)
                            views.setViewVisibility(R.id.widget_map_container, View.VISIBLE)
                        }
                    } catch (t: Throwable) {
                        Log.e(TAG, "Failed to decode map image", t)
                    }
                }
            }
        } else {
            try {
                views.setViewVisibility(R.id.widget_map_container, View.GONE)
            } catch (_: Throwable) {}
        }

        // Open PackBuddy on click
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

        return views
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
