package com.sleepyhead.packbuddy

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.ColorStateList
import android.database.sqlite.SQLiteDatabase
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.UUID

enum class WidgetLayoutSize {
    SMALL,
    MEDIUM,
    LARGE
}

object CurrencyHelper {
    val supportedCurrencies = listOf(
        "TRY", "USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "AED", "SAR"
    )

    val defaultRatesAgainstUsd = mapOf(
        "USD" to 1.0,
        "EUR" to 0.92,
        "GBP" to 0.77,
        "TRY" to 34.25,
        "JPY" to 152.5,
        "CHF" to 0.87,
        "CAD" to 1.38,
        "AUD" to 1.51,
        "AED" to 3.6725,
        "SAR" to 3.75,
        "THB" to 33.8,
        "SGD" to 1.32,
        "KRW" to 1385.0,
        "CNY" to 7.15,
        "INR" to 84.1,
        "BRL" to 5.72,
        "MXN" to 19.85,
        "SEK" to 10.6,
        "NOK" to 10.8,
        "DKK" to 6.88,
        "PLN" to 4.02
    )

    fun getRates(widgetData: SharedPreferences): Map<String, Double> {
        val json = widgetData.getString("currency_rates_json", null) ?: return defaultRatesAgainstUsd
        return try {
            val jsonObject = JSONObject(json)
            val map = mutableMapOf<String, Double>()
            val keys = jsonObject.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                map[key] = jsonObject.optDouble(key, defaultRatesAgainstUsd[key] ?: 1.0)
            }
            if (map.isNotEmpty()) map else defaultRatesAgainstUsd
        } catch (_: Throwable) {
            defaultRatesAgainstUsd
        }
    }

    fun convert(amount: Double, from: String, to: String, rates: Map<String, Double>): Double {
        val fromRate = rates[from] ?: defaultRatesAgainstUsd[from] ?: 1.0
        val toRate = rates[to] ?: defaultRatesAgainstUsd[to] ?: 1.0
        if (fromRate <= 0.0) return amount
        val amountInUsd = amount / fromRate
        return amountInUsd * toRate
    }

    fun getSymbol(currency: String): String {
        return when (currency) {
            "TRY" -> "₺"
            "USD" -> "$"
            "EUR" -> "€"
            "GBP" -> "£"
            "JPY" -> "¥"
            "CHF" -> "CHF "
            "CAD" -> "CA$"
            "AUD" -> "A$"
            "AED" -> "AED "
            "SAR" -> "SAR "
            else -> "$currency "
        }
    }

    fun format(amount: Double, currency: String): String {
        val sym = getSymbol(currency)
        return if (currency == "JPY") {
            String.format(Locale.US, "%s%,.0f", sym, amount)
        } else if (amount >= 1000) {
            String.format(Locale.US, "%s%,.1f", sym, amount)
        } else {
            String.format(Locale.US, "%s%,.2f", sym, amount)
        }
    }
}

open class PackBuddyWidgetProvider : HomeWidgetProvider() {

    protected open val defaultLayoutSize: WidgetLayoutSize = WidgetLayoutSize.SMALL
    protected open val inherentMode: String? = null

    companion object {
        const val TAG = "PackBuddyWidget"

        const val ACTION_CYCLE_CURRENCY = "com.sleepyhead.packbuddy.action.CYCLE_CURRENCY"
        const val ACTION_CYCLE_USD_AMOUNT = "com.sleepyhead.packbuddy.action.CYCLE_USD_AMOUNT"
        const val ACTION_CYCLE_EUR_AMOUNT = "com.sleepyhead.packbuddy.action.CYCLE_EUR_AMOUNT"
        const val ACTION_CYCLE_CONVERSIONS = "com.sleepyhead.packbuddy.action.CYCLE_CONVERSIONS"
        const val ACTION_TOGGLE_EXPENSE_VIEW = "com.sleepyhead.packbuddy.action.TOGGLE_EXPENSE_VIEW"
        const val ACTION_QUICK_EXPENSE_INCREMENT = "com.sleepyhead.packbuddy.action.QUICK_EXPENSE_INCREMENT"
        const val ACTION_TOGGLE_MAP_VIEW = "com.sleepyhead.packbuddy.action.TOGGLE_MAP_VIEW"
        const val ACTION_TOGGLE_TRIP_VIEW = "com.sleepyhead.packbuddy.action.TOGGLE_TRIP_VIEW"

        val usdAmounts = listOf(1, 5, 10, 20, 50, 100, 250, 500, 1000)
        val eurAmounts = listOf(1, 5, 10, 20, 50, 100, 250, 500, 1000)

        fun setBgRes(views: RemoteViews, viewId: Int, resId: Int) {
            try {
                views.setInt(viewId, "setBackgroundResource", resId)
            } catch (_: Throwable) {}
        }

        fun normalizeTheme(raw: String?): String {
            val t = (raw ?: "midnight").trim()
            return when (t) {
                "sandLight", "sand_light", "sahara", "desert" -> "sand_light"
                "minimalLight", "minimal_light", "nordic", "light" -> "minimal_light"
                "oceanLight", "ocean_light", "ocean", "mediterranean" -> "ocean_light"
                "cherryBlossom", "cherry_blossom", "sakura", "sakura_light" -> "cherry_blossom"
                "vintageSepia", "vintage_sepia", "latte" -> "vintage_sepia"
                "matcha", "sage" -> "matcha"
                "pastelDream", "pastel_dream", "lavender" -> "pastel_dream"
                "nordicForest", "nordic_forest", "forest" -> "nordic_forest"
                "goldenHour", "golden_hour", "aurora" -> "golden_hour"
                "galaxy" -> "galaxy"
                "monochromeDark", "monochrome_dark", "monochrome" -> "monochrome_dark"
                "cyberpunk", "neon_cyber" -> "cyberpunk"
                "volcano" -> "volcano"
                "emerald" -> "emerald"
                "sunset" -> "sunset"
                "midnight" -> "midnight"
                else -> "midnight"
            }
        }

        fun getThemeInfo(themeKey: String): WidgetThemeInfo {
            return when (normalizeTheme(themeKey)) {
                "sunset" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_sunset,
                    statResId = R.drawable.widget_stat_bg_sunset,
                    badgeResId = R.drawable.widget_badge_bg_sunset,
                    mapResId = R.drawable.widget_map_bg_sunset,
                    accentColor = 0xFFFF5722.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFFFED7AA.toInt(),
                    badgeColor = 0xFFFF5722.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFFFF5722.toInt(),
                    wishlistColor = 0xFFEC4899.toInt(),
                    isLight = false
                )
                "emerald" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_emerald,
                    statResId = R.drawable.widget_stat_bg_emerald,
                    badgeResId = R.drawable.widget_badge_bg_emerald,
                    mapResId = R.drawable.widget_map_bg_emerald,
                    accentColor = 0xFF10B981.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFFA7F3D0.toInt(),
                    badgeColor = 0xFF059669.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF10B981.toInt(),
                    wishlistColor = 0xFFFBBF24.toInt(),
                    isLight = false
                )
                "cyberpunk" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_cyberpunk,
                    statResId = R.drawable.widget_stat_bg_cyberpunk,
                    badgeResId = R.drawable.widget_badge_bg_cyberpunk,
                    mapResId = R.drawable.widget_map_bg_cyberpunk,
                    accentColor = 0xFF06B6D4.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFF94A3B8.toInt(),
                    badgeColor = 0xFF06B6D4.toInt(),
                    badgeTextColor = 0xFF000000.toInt(),
                    visitedColor = 0xFF06B6D4.toInt(),
                    wishlistColor = 0xFFF43F5E.toInt(),
                    isLight = false
                )
                "volcano" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_volcano,
                    statResId = R.drawable.widget_stat_bg_volcano,
                    badgeResId = R.drawable.widget_badge_bg_volcano,
                    mapResId = R.drawable.widget_map_bg_volcano,
                    accentColor = 0xFFFF3D00.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFFFFCCBC.toInt(),
                    badgeColor = 0xFFDD2C00.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFFFF3D00.toInt(),
                    wishlistColor = 0xFFD50000.toInt(),
                    isLight = false
                )
                "nordic_forest" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_nordic_forest,
                    statResId = R.drawable.widget_stat_bg_nordic_forest,
                    badgeResId = R.drawable.widget_badge_bg_nordic_forest,
                    mapResId = R.drawable.widget_map_bg_nordic_forest,
                    accentColor = 0xFF38BDF8.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFFBAE6FD.toInt(),
                    badgeColor = 0xFF0284C7.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF38BDF8.toInt(),
                    wishlistColor = 0xFFF472B6.toInt(),
                    isLight = false
                )
                "golden_hour" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_golden_hour,
                    statResId = R.drawable.widget_stat_bg_golden_hour,
                    badgeResId = R.drawable.widget_badge_bg_golden_hour,
                    mapResId = R.drawable.widget_map_bg_golden_hour,
                    accentColor = 0xFFF59E0B.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFFFEF3C7.toInt(),
                    badgeColor = 0xFFD97706.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFFF59E0B.toInt(),
                    wishlistColor = 0xFFEF4444.toInt(),
                    isLight = false
                )
                "galaxy" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_galaxy,
                    statResId = R.drawable.widget_stat_bg_galaxy,
                    badgeResId = R.drawable.widget_badge_bg_galaxy,
                    mapResId = R.drawable.widget_map_bg_galaxy,
                    accentColor = 0xFFA855F7.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFFE9D5FF.toInt(),
                    badgeColor = 0xFF9333EA.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFFA855F7.toInt(),
                    wishlistColor = 0xFFEC4899.toInt(),
                    isLight = false
                )
                "monochrome_dark" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_monochrome_dark,
                    statResId = R.drawable.widget_stat_bg_monochrome_dark,
                    badgeResId = R.drawable.widget_badge_bg_monochrome_dark,
                    mapResId = R.drawable.widget_map_bg_monochrome_dark,
                    accentColor = 0xFFE2E8F0.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFF94A3B8.toInt(),
                    badgeColor = 0xFF475569.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFFE2E8F0.toInt(),
                    wishlistColor = 0xFFF59E0B.toInt(),
                    isLight = false
                )
                "minimal_light" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_minimal_light,
                    statResId = R.drawable.widget_stat_bg_minimal_light,
                    badgeResId = R.drawable.widget_badge_bg_minimal_light,
                    mapResId = R.drawable.widget_map_bg_minimal_light,
                    accentColor = 0xFF856404.toInt(),
                    titleTextColor = 0xFF0F172A.toInt(),
                    subtitleTextColor = 0xFF475569.toInt(),
                    badgeColor = 0xFF856404.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF059669.toInt(),
                    wishlistColor = 0xFFE11D48.toInt(),
                    isLight = true
                )
                "sand_light" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_sand_light,
                    statResId = R.drawable.widget_stat_bg_sand_light,
                    badgeResId = R.drawable.widget_badge_bg_sand_light,
                    mapResId = R.drawable.widget_map_bg_sand_light,
                    accentColor = 0xFFD97706.toInt(),
                    titleTextColor = 0xFF292524.toInt(),
                    subtitleTextColor = 0xFF78716C.toInt(),
                    badgeColor = 0xFFD97706.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF16A34A.toInt(),
                    wishlistColor = 0xFFDC2626.toInt(),
                    isLight = true
                )
                "ocean_light" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_ocean_light,
                    statResId = R.drawable.widget_stat_bg_ocean_light,
                    badgeResId = R.drawable.widget_badge_bg_ocean_light,
                    mapResId = R.drawable.widget_map_bg_ocean_light,
                    accentColor = 0xFF0284C7.toInt(),
                    titleTextColor = 0xFF0C4A6E.toInt(),
                    subtitleTextColor = 0xFF0369A1.toInt(),
                    badgeColor = 0xFF0284C7.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF0284C7.toInt(),
                    wishlistColor = 0xFFF43F5E.toInt(),
                    isLight = true
                )
                "cherry_blossom" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_cherry_blossom,
                    statResId = R.drawable.widget_stat_bg_cherry_blossom,
                    badgeResId = R.drawable.widget_badge_bg_cherry_blossom,
                    mapResId = R.drawable.widget_map_bg_cherry_blossom,
                    accentColor = 0xFFE11D48.toInt(),
                    titleTextColor = 0xFF4C0519.toInt(),
                    subtitleTextColor = 0xFF9F1239.toInt(),
                    badgeColor = 0xFFE11D48.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFFE11D48.toInt(),
                    wishlistColor = 0xFF9333EA.toInt(),
                    isLight = true
                )
                "vintage_sepia" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_vintage_sepia,
                    statResId = R.drawable.widget_stat_bg_vintage_sepia,
                    badgeResId = R.drawable.widget_badge_bg_vintage_sepia,
                    mapResId = R.drawable.widget_map_bg_vintage_sepia,
                    accentColor = 0xFF854D0E.toInt(),
                    titleTextColor = 0xFF422006.toInt(),
                    subtitleTextColor = 0xFF713F12.toInt(),
                    badgeColor = 0xFF854D0E.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF854D0E.toInt(),
                    wishlistColor = 0xFFB91C1C.toInt(),
                    isLight = true
                )
                "matcha" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_matcha,
                    statResId = R.drawable.widget_stat_bg_matcha,
                    badgeResId = R.drawable.widget_badge_bg_matcha,
                    mapResId = R.drawable.widget_map_bg_matcha,
                    accentColor = 0xFF4D7C0F.toInt(),
                    titleTextColor = 0xFF14532D.toInt(),
                    subtitleTextColor = 0xFF166534.toInt(),
                    badgeColor = 0xFF4D7C0F.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF4D7C0F.toInt(),
                    wishlistColor = 0xFFDC2626.toInt(),
                    isLight = true
                )
                "pastel_dream" -> WidgetThemeInfo(
                    bgResId = R.drawable.widget_bg_pastel_dream,
                    statResId = R.drawable.widget_stat_bg_pastel_dream,
                    badgeResId = R.drawable.widget_badge_bg_pastel_dream,
                    mapResId = R.drawable.widget_map_bg_pastel_dream,
                    accentColor = 0xFF8B5CF6.toInt(),
                    titleTextColor = 0xFF4C1D95.toInt(),
                    subtitleTextColor = 0xFF6D28D9.toInt(),
                    badgeColor = 0xFF8B5CF6.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF8B5CF6.toInt(),
                    wishlistColor = 0xFFF43F5E.toInt(),
                    isLight = true
                )
                else -> WidgetThemeInfo( // "midnight"
                    bgResId = R.drawable.widget_bg_midnight,
                    statResId = R.drawable.widget_stat_bg_midnight,
                    badgeResId = R.drawable.widget_badge_bg_midnight,
                    mapResId = R.drawable.widget_map_bg_midnight,
                    accentColor = 0xFF3B82F6.toInt(),
                    titleTextColor = 0xFFFFFFFF.toInt(),
                    subtitleTextColor = 0xFF94A3B8.toInt(),
                    badgeColor = 0xFF2563EB.toInt(),
                    badgeTextColor = 0xFFFFFFFF.toInt(),
                    visitedColor = 0xFF22C55E.toInt(),
                    wishlistColor = 0xFFF59E0B.toInt(),
                    isLight = false
                )
            }
        }

        fun populateViews(
            context: Context,
            widgetData: SharedPreferences,
            mode: String,
            widgetTheme: String,
            size: WidgetLayoutSize,
            widgetId: Int,
            receiverClass: Class<*>
        ): RemoteViews {
            // Select Dedicated Pixel-Perfect Layout
            val layoutId = when (mode) {
                "quick_expense" -> when (size) {
                    WidgetLayoutSize.SMALL -> R.layout.packbuddy_expense_small
                    WidgetLayoutSize.MEDIUM -> R.layout.packbuddy_expense_medium
                    WidgetLayoutSize.LARGE -> R.layout.packbuddy_expense_large
                }
                "currency_converter" -> when (size) {
                    WidgetLayoutSize.SMALL -> R.layout.packbuddy_currency_small
                    WidgetLayoutSize.MEDIUM -> R.layout.packbuddy_currency_medium
                    WidgetLayoutSize.LARGE -> R.layout.packbuddy_currency_large
                }
                "world_map" -> when (size) {
                    WidgetLayoutSize.SMALL -> R.layout.packbuddy_map_small
                    WidgetLayoutSize.MEDIUM -> R.layout.packbuddy_map_medium
                    WidgetLayoutSize.LARGE -> R.layout.packbuddy_map_large
                }
                else -> when (size) { // "trip"
                    WidgetLayoutSize.SMALL -> R.layout.packbuddy_trip_small
                    WidgetLayoutSize.MEDIUM -> R.layout.packbuddy_trip_medium
                    WidgetLayoutSize.LARGE -> R.layout.packbuddy_trip_large
                }
            }

            val views = RemoteViews(context.packageName, layoutId)

            val theme = getThemeInfo(widgetTheme)

            // Fallback launch intent for outer container
            val actionUri = when (mode) {
                "quick_expense" -> "packbuddy://add_expense"
                "currency_converter" -> "packbuddy://currency"
                "world_map" -> "packbuddy://map"
                "trip" -> "packbuddy://trip"
                else -> "packbuddy://home"
            }
            val launchUri = android.net.Uri.parse(actionUri)
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                launchUri
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            fun makeBroadcastPendingIntent(action: String, actionCode: Int): PendingIntent {
                val intent = Intent(context, receiverClass).apply {
                    this.action = action
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                }
                return PendingIntent.getBroadcast(
                    context,
                    Math.abs(widgetId) * 100 + actionCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            }

            // Mode-Isolated Content Population & Styling
            when (mode) {
                "quick_expense" -> {
                    setBgRes(views, R.id.widget_container, theme.bgResId)
                    views.setTextColor(R.id.widget_app_name, theme.accentColor)

                    val appName = widgetData.getString("quick_expense_app_name", "PackBuddy • Bütçe") ?: "PackBuddy • Bütçe"
                    val spent = widgetData.getString("trip_budget", null)?.takeIf { it.isNotBlank() }
                        ?: widgetData.getString("quick_expense_title", null)?.takeIf { it.isNotBlank() }
                        ?: "₺0.00"
                    val remaining = widgetData.getString("remaining_budget", null)?.takeIf { it.isNotBlank() }
                    val lastExpense = widgetData.getString("last_expense_text", null)?.takeIf { it.isNotBlank() }
                    val remainingLabel = widgetData.getString("quick_expense_remaining_label", "Kalan Bütçe") ?: "Kalan Bütçe"
                    val spentLabel = widgetData.getString("quick_expense_spent_label", "Harcanan") ?: "Harcanan"
                    val spentCardLabel = widgetData.getString("quick_expense_spent_card_label", "Harcanan Bütçe") ?: "Harcanan Bütçe"
                    val lastLabel = widgetData.getString("quick_expense_last_label", "Son Harcama") ?: "Son Harcama"
                    val noLast = widgetData.getString("quick_expense_no_last", "Henüz harcama kaydedilmedi") ?: "Henüz harcama kaydedilmedi"
                    val addAction = widgetData.getString("quick_expense_add_action", "+ Harcama Ekle") ?: "+ Harcama Ekle"
                    val quickLog = widgetData.getString("quick_expense_quick_log", "Hızlı Kayıt") ?: "Hızlı Kayıt"
                    val showRemaining = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_quick_expense_show_remaining" else "pending_pin_quick_expense_show_remaining",
                        "quick_expense_show_remaining",
                        true
                    )
                    val showLast = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_quick_expense_show_last" else "pending_pin_quick_expense_show_last",
                        "quick_expense_show_last",
                        true
                    )
                    val expMode = safeGetInt(widgetData, "widget_${widgetId}_exp_mode", 0)

                    try {
                        views.setTextViewText(R.id.widget_app_name, appName)

                        if (size == WidgetLayoutSize.LARGE) {
                            setBgRes(views, R.id.widget_badge, theme.badgeResId)
                            setBgRes(views, R.id.widget_spent_card, theme.statResId)
                            setBgRes(views, R.id.widget_remaining_card, theme.statResId)
                            setBgRes(views, R.id.widget_last_card, theme.statResId)
                            setBgRes(views, R.id.widget_large_add_btn, theme.badgeResId)

                            views.setTextColor(R.id.widget_badge, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_spent_card_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_spent_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_remaining_card_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_remaining_val, theme.visitedColor)
                            views.setTextColor(R.id.widget_last_expense_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_last_expense_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_large_add_text, theme.badgeTextColor)

                            views.setTextViewText(R.id.widget_badge, quickLog)
                            views.setTextViewText(R.id.widget_spent_card_label, if (expMode == 1 && remaining != null) remainingLabel else spentCardLabel)
                            views.setTextViewText(R.id.widget_spent_val, if (expMode == 1 && remaining != null) remaining else spent)
                            views.setTextViewText(R.id.widget_last_expense_label, lastLabel)
                            views.setTextViewText(R.id.widget_last_expense_val, if (showLast) (lastExpense ?: noLast) else noLast)
                            views.setViewVisibility(R.id.widget_last_card, if (showLast) View.VISIBLE else View.GONE)
                            views.setTextViewText(R.id.widget_large_add_text, addAction)

                            if (remaining != null && showRemaining) {
                                views.setTextViewText(R.id.widget_remaining_card_label, if (expMode == 1) spentCardLabel else remainingLabel)
                                views.setTextViewText(R.id.widget_remaining_val, if (expMode == 1) spent else remaining)
                                views.setViewVisibility(R.id.widget_remaining_card, View.VISIBLE)
                            } else {
                                views.setViewVisibility(R.id.widget_remaining_card, View.GONE)
                            }

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_spent_card, makeBroadcastPendingIntent(ACTION_TOGGLE_EXPENSE_VIEW, 5))
                                views.setOnClickPendingIntent(R.id.widget_badge, makeBroadcastPendingIntent(ACTION_QUICK_EXPENSE_INCREMENT, 6))
                                views.setOnClickPendingIntent(R.id.widget_large_add_btn, pendingIntent)
                            }
                        } else if (size == WidgetLayoutSize.MEDIUM) {
                            setBgRes(views, R.id.widget_badge, theme.badgeResId)
                            setBgRes(views, R.id.widget_spent_card, theme.statResId)
                            setBgRes(views, R.id.widget_action_btn, theme.badgeResId)

                            views.setTextColor(R.id.widget_badge, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_spent_card_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_spent_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_remaining_val, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_last_expense_val, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_action_icon, theme.badgeColor)
                            views.setTextColor(R.id.widget_action_text, theme.badgeTextColor)

                            views.setTextViewText(R.id.widget_badge, quickLog)
                            views.setTextViewText(R.id.widget_spent_card_label, if (expMode == 1 && remaining != null) remainingLabel else spentCardLabel)
                            views.setTextViewText(R.id.widget_action_text, addAction.replace("+ ", ""))
                            if (expMode == 1 && remaining != null) {
                                views.setTextViewText(R.id.widget_spent_val, remaining)
                                views.setTextViewText(R.id.widget_remaining_val, "$spentLabel: $spent")
                                views.setViewVisibility(R.id.widget_remaining_val, View.VISIBLE)
                            } else {
                                views.setTextViewText(R.id.widget_spent_val, spent)
                                if (remaining != null && showRemaining) {
                                    views.setTextViewText(R.id.widget_remaining_val, "$remainingLabel: $remaining")
                                    views.setViewVisibility(R.id.widget_remaining_val, View.VISIBLE)
                                } else {
                                    views.setViewVisibility(R.id.widget_remaining_val, View.GONE)
                                }
                            }
                            if (showLast && lastExpense != null) {
                                views.setTextViewText(R.id.widget_last_expense_val, "$lastLabel: $lastExpense")
                                views.setViewVisibility(R.id.widget_last_expense_val, View.VISIBLE)
                            } else if (showLast) {
                                views.setTextViewText(R.id.widget_last_expense_val, widgetData.getString("trip_title", "PackBuddy") ?: "PackBuddy")
                                views.setViewVisibility(R.id.widget_last_expense_val, View.VISIBLE)
                            } else {
                                views.setViewVisibility(R.id.widget_last_expense_val, View.GONE)
                            }

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_spent_val, makeBroadcastPendingIntent(ACTION_TOGGLE_EXPENSE_VIEW, 5))
                                views.setOnClickPendingIntent(R.id.widget_action_btn, pendingIntent)
                            }
                        } else { // SMALL
                            setBgRes(views, R.id.widget_badge, theme.badgeResId)
                            setBgRes(views, R.id.widget_bottom_card, theme.statResId)
                            views.setTextColor(R.id.widget_badge, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_spent_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_spent_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_bottom_label, theme.accentColor)
                            views.setTextColor(R.id.widget_bottom_val, theme.subtitleTextColor)

                            views.setTextViewText(R.id.widget_badge, "+")
                            if (expMode == 1 && remaining != null) {
                                views.setTextViewText(R.id.widget_spent_label, remainingLabel)
                                views.setTextViewText(R.id.widget_spent_val, remaining)
                            } else {
                                views.setTextViewText(R.id.widget_spent_label, spentLabel)
                                views.setTextViewText(R.id.widget_spent_val, spent)
                            }
                            if (remaining != null && showRemaining) {
                                views.setTextViewText(R.id.widget_bottom_label, if (expMode == 1) spentLabel else remainingLabel)
                                views.setTextViewText(R.id.widget_bottom_val, if (expMode == 1) spent else remaining)
                                views.setViewVisibility(R.id.widget_bottom_val, View.VISIBLE)
                            } else {
                                views.setTextViewText(R.id.widget_bottom_label, addAction)
                                views.setViewVisibility(R.id.widget_bottom_val, View.GONE)
                            }

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_badge, makeBroadcastPendingIntent(ACTION_QUICK_EXPENSE_INCREMENT, 6))
                                views.setOnClickPendingIntent(R.id.widget_spent_val, makeBroadcastPendingIntent(ACTION_TOGGLE_EXPENSE_VIEW, 5))
                                views.setOnClickPendingIntent(R.id.widget_bottom_card, pendingIntent)
                            }
                        }
                    } catch (_: Throwable) {}
                }

                "currency_converter" -> {
                    setBgRes(views, R.id.widget_container, theme.bgResId)
                    views.setTextColor(R.id.widget_app_name, theme.accentColor)

                    val targetCurrency = widgetData.getString("widget_${widgetId}_currency", null)
                        ?: widgetData.getString("user_currency", "TRY")
                        ?: "TRY"
                    val rates = CurrencyHelper.getRates(widgetData)

                    val usdIdx = safeGetInt(widgetData, "widget_${widgetId}_usd_idx", 0) % usdAmounts.size
                    val eurIdx = safeGetInt(widgetData, "widget_${widgetId}_eur_idx", 0) % eurAmounts.size
                    val convBaseEur = widgetData.getBoolean("widget_${widgetId}_conv_base_eur", false)

                    val usdAmt = usdAmounts[usdIdx]
                    val eurAmt = eurAmounts[eurIdx]

                    val primarySrc = if (targetCurrency == "USD") "EUR" else "USD"
                    val secondarySrc = if (targetCurrency == "EUR") "GBP" else if (targetCurrency == "USD") "TRY" else "EUR"

                    val primarySrcAmt = if (primarySrc == "USD") usdAmt else eurAmt
                    val secondarySrcAmt = if (secondarySrc == "EUR") eurAmt else if (secondarySrc == "USD") usdAmt else if (secondarySrc == "TRY") 100 else eurAmt

                    val primaryConverted = CurrencyHelper.convert(primarySrcAmt.toDouble(), primarySrc, targetCurrency, rates)
                    val secondaryConverted = CurrencyHelper.convert(secondarySrcAmt.toDouble(), secondarySrc, targetCurrency, rates)

                    val primaryLabelText = "$primarySrcAmt $primarySrc"
                    val primaryValText = CurrencyHelper.format(primaryConverted, targetCurrency)

                    val secondaryLabelText = "$secondarySrcAmt $secondarySrc"
                    val secondaryValText = CurrencyHelper.format(secondaryConverted, targetCurrency)

                    val appName = widgetData.getString("currency_converter_app_name", "PackBuddy • Kur") ?: "PackBuddy • Kur"
                    val convTitle = widgetData.getString("currency_converter_conversions_title", "Hızlı Çevrimler") ?: "Hızlı Çevrimler"
                    val liveStatus = widgetData.getString("currency_converter_live_status", "● Canlı Kurlar") ?: "● Canlı Kurlar"
                    val syncStatus = widgetData.getString("currency_converter_sync_status", "✓ Otomatik Çift Yönlü Senkron") ?: "✓ Otomatik Çift Yönlü Senkron"
                    val offlineStatus = widgetData.getString("currency_converter_offline_status", "Çevrim Çevrimdışı Hazır") ?: "Çevrim Çevrimdışı Hazır"
                    val showLiveRate = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_currency_show_live_rate" else "pending_pin_currency_show_live_rate",
                        "currency_show_live_rate",
                        true
                    )
                    val showReverseRate = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_currency_show_reverse_rate" else "pending_pin_currency_show_reverse_rate",
                        "currency_show_reverse_rate",
                        true
                    )

                    val convBase = if (convBaseEur) "EUR" else "USD"
                    val convSym = CurrencyHelper.getSymbol(convBase)
                    val conv1 = "$convSym" + "10 ≈ " + CurrencyHelper.format(CurrencyHelper.convert(10.0, convBase, targetCurrency, rates), targetCurrency)
                    val conv2 = "$convSym" + "50 ≈ " + CurrencyHelper.format(CurrencyHelper.convert(50.0, convBase, targetCurrency, rates), targetCurrency)
                    val conv3 = "$convSym" + "100 ≈ " + CurrencyHelper.format(CurrencyHelper.convert(100.0, convBase, targetCurrency, rates), targetCurrency)

                    val revRate = CurrencyHelper.convert(1.0, targetCurrency, "USD", rates)
                    val revRateText = "1 $targetCurrency ≈ " + CurrencyHelper.format(revRate, "USD")

                    try {
                        views.setTextViewText(R.id.widget_app_name, appName)
                        views.setTextViewText(R.id.widget_badge, targetCurrency)
                        views.setTextViewText(R.id.widget_usd_label, primaryLabelText)
                        views.setTextViewText(R.id.widget_usd_val, primaryValText)
                        views.setTextViewText(R.id.widget_eur_label, secondaryLabelText)
                        views.setTextViewText(R.id.widget_eur_val, secondaryValText)

                        if (size == WidgetLayoutSize.LARGE) {
                            setBgRes(views, R.id.widget_badge, theme.badgeResId)
                            setBgRes(views, R.id.widget_usd_box, theme.statResId)
                            setBgRes(views, R.id.widget_eur_box, theme.statResId)
                            setBgRes(views, R.id.widget_conversions_box, theme.statResId)

                            views.setTextColor(R.id.widget_badge, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_usd_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_usd_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_eur_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_eur_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_conversions_title, theme.titleTextColor)
                            views.setTextColor(R.id.widget_conv_1, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_conv_2, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_conv_3, theme.accentColor)
                            views.setTextColor(R.id.widget_sync_status, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_offline_status, 0xFF10B981.toInt())

                            views.setTextViewText(R.id.widget_conversions_title, "$convTitle ($convBase)")
                            views.setTextViewText(R.id.widget_conv_1, conv1)
                            views.setTextViewText(R.id.widget_conv_2, conv2)
                            views.setTextViewText(R.id.widget_conv_3, conv3)
                            views.setTextViewText(R.id.widget_sync_status, syncStatus)
                            views.setTextViewText(R.id.widget_offline_status, offlineStatus)
                            views.setViewVisibility(R.id.widget_sync_status, if (showLiveRate) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_offline_status, if (showLiveRate) View.VISIBLE else View.GONE)

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_badge, makeBroadcastPendingIntent(ACTION_CYCLE_CURRENCY, 1))
                                views.setOnClickPendingIntent(R.id.widget_usd_box, makeBroadcastPendingIntent(ACTION_CYCLE_USD_AMOUNT, 2))
                                views.setOnClickPendingIntent(R.id.widget_eur_box, makeBroadcastPendingIntent(ACTION_CYCLE_EUR_AMOUNT, 3))
                                views.setOnClickPendingIntent(R.id.widget_conversions_box, makeBroadcastPendingIntent(ACTION_CYCLE_CONVERSIONS, 4))
                            }
                        } else if (size == WidgetLayoutSize.MEDIUM) {
                            setBgRes(views, R.id.widget_usd_box, theme.statResId)
                            setBgRes(views, R.id.widget_eur_box, theme.statResId)
                            setBgRes(views, R.id.widget_action_btn, theme.statResId)

                            views.setTextColor(R.id.widget_usd_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_usd_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_eur_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_eur_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_live_status, theme.visitedColor)
                            views.setTextColor(R.id.widget_reverse_rate, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_currency_icon, theme.accentColor)
                            views.setTextColor(R.id.widget_badge, theme.titleTextColor)

                            views.setTextViewText(R.id.widget_live_status, liveStatus)
                            views.setTextViewText(R.id.widget_reverse_rate, revRateText)
                            views.setViewVisibility(R.id.widget_live_status, if (showLiveRate) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_reverse_rate, if (showReverseRate) View.VISIBLE else View.GONE)

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_action_btn, makeBroadcastPendingIntent(ACTION_CYCLE_CURRENCY, 1))
                                views.setOnClickPendingIntent(R.id.widget_usd_box, makeBroadcastPendingIntent(ACTION_CYCLE_USD_AMOUNT, 2))
                                views.setOnClickPendingIntent(R.id.widget_eur_box, makeBroadcastPendingIntent(ACTION_CYCLE_EUR_AMOUNT, 3))
                            }
                        } else { // SMALL
                            setBgRes(views, R.id.widget_badge, theme.badgeResId)
                            setBgRes(views, R.id.widget_usd_box, theme.statResId)
                            setBgRes(views, R.id.widget_bottom_card, theme.statResId)

                            views.setTextColor(R.id.widget_badge, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_usd_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_usd_val, theme.titleTextColor)
                            views.setTextColor(R.id.widget_eur_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_eur_val, theme.accentColor)

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_badge, makeBroadcastPendingIntent(ACTION_CYCLE_CURRENCY, 1))
                                views.setOnClickPendingIntent(R.id.widget_usd_box, makeBroadcastPendingIntent(ACTION_CYCLE_USD_AMOUNT, 2))
                                views.setOnClickPendingIntent(R.id.widget_bottom_card, makeBroadcastPendingIntent(ACTION_CYCLE_EUR_AMOUNT, 3))
                            }
                        }
                    } catch (_: Throwable) {}
                }

                "world_map" -> {
                    setBgRes(views, R.id.widget_container, theme.bgResId)
                    setBgRes(views, R.id.widget_badge, theme.badgeResId)
                    views.setTextColor(R.id.widget_app_name, theme.accentColor)
                    views.setTextColor(R.id.widget_badge, theme.badgeTextColor)

                    val appName = widgetData.getString("world_map_app_name", "PackBuddy • Dünya") ?: "PackBuddy • Dünya"
                    val percent = widgetData.getString("map_world_percent", "%0.0") ?: "%0.0"
                    val visitedCount = safeGetInt(widgetData, "map_visited_count", 0)
                    val wishlistCount = safeGetInt(widgetData, "map_wishlist_count", 0)
                    val continentsCount = safeGetInt(widgetData, "map_continents_count", 0)
                    val title = widgetData.getString("world_map_title", "$visitedCount Ülke Gezildi") ?: "$visitedCount Ülke Gezildi"
                    val subtitle = widgetData.getString("world_map_subtitle", "Keşif Oranı") ?: "Keşif Oranı"
                    val stat1 = widgetData.getString("world_map_stat1", "✈️ $visitedCount Gezildi") ?: "✈️ $visitedCount Gezildi"
                    val stat2 = widgetData.getString("world_map_stat2", "🌟 $wishlistCount Hedef") ?: "🌟 $wishlistCount Hedef"
                    val stat3 = widgetData.getString("world_map_stat3", "🌍 $continentsCount Kıta") ?: "🌍 $continentsCount Kıta"
                    val showContinents = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_map_show_continents" else "pending_pin_map_show_continents",
                        "map_show_continents",
                        true
                    )
                    val showWishlist = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_map_show_wishlist" else "pending_pin_map_show_wishlist",
                        "map_show_wishlist",
                        true
                    )
                    val mapMode = safeGetInt(widgetData, "widget_${widgetId}_map_mode", 0)

                    val badgeDisplay = when (mapMode) {
                        1 -> "$visitedCount"
                        2 -> "$continentsCount🌍"
                        else -> percent
                    }

                    val pctNum = try {
                        percent.replace("%", "").trim().toDouble().toInt().coerceIn(0, 100)
                    } catch (_: Exception) { 0 }

                    try {
                        val cleanAppName = if (appName.startsWith("PackBuddy") && !appName.startsWith("🌐")) "🌐 $appName" else appName
                        views.setTextViewText(R.id.widget_app_name, cleanAppName)
                        views.setTextViewText(R.id.widget_badge, badgeDisplay)

                        if (size == WidgetLayoutSize.LARGE) {
                            setBgRes(views, R.id.widget_map_container, theme.mapResId)
                            setBgRes(views, R.id.widget_bottom_stats, theme.statResId)

                            views.setTextColor(R.id.widget_lived, theme.visitedColor)
                            views.setTextColor(R.id.widget_packing, theme.accentColor)
                            views.setTextColor(R.id.widget_budget, theme.wishlistColor)
                            views.setTextColor(R.id.widget_stat3, theme.accentColor)

                            val livedCount = safeGetInt(widgetData, "map_lived_count", 0)
                            val livedText = widgetData.getString("world_map_lived_stat", "● Yaşandı ($livedCount)") ?: "● Yaşandı ($livedCount)"
                            views.setTextViewText(R.id.widget_lived, livedText)
                            views.setTextViewText(R.id.widget_packing, stat1)
                            views.setTextViewText(R.id.widget_budget, stat2)
                            views.setTextViewText(R.id.widget_stat3, stat3)
                            views.setViewVisibility(R.id.widget_budget, if (showWishlist) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_stat3, if (showContinents) View.VISIBLE else View.GONE)
                        } else if (size == WidgetLayoutSize.MEDIUM) {
                            setBgRes(views, R.id.widget_map_container, theme.mapResId)
                            setBgRes(views, R.id.widget_stat3, theme.statResId)

                            views.setTextColor(R.id.widget_title, theme.titleTextColor)
                            views.setTextColor(R.id.widget_destination, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_packing, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_budget, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_stat3, theme.accentColor)

                            views.setTextViewText(R.id.widget_title, title)
                            views.setTextViewText(R.id.widget_destination, subtitle)
                            views.setTextViewText(R.id.widget_packing, stat1)
                            views.setTextViewText(R.id.widget_budget, stat2)
                            views.setTextViewText(R.id.widget_stat3, stat3)

                            views.setProgressBar(R.id.widget_progress, 100, pctNum, false)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                views.setColorStateList(R.id.widget_progress, "setProgressTintList", ColorStateList.valueOf(theme.accentColor))
                            }

                            views.setViewVisibility(R.id.widget_budget, if (showWishlist) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_stat3, if (showContinents) View.VISIBLE else View.GONE)
                        } else { // SMALL
                            views.setTextColor(R.id.widget_visited_count, theme.accentColor)
                            views.setTextColor(R.id.widget_title, theme.titleTextColor)
                            views.setTextColor(R.id.widget_destination, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_packing, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_budget, theme.subtitleTextColor)

                            val smallAppName = if (appName.startsWith("PackBuddy") && !appName.startsWith("🌐")) "🌐 PackBuddy" else "PackBuddy"
                            views.setTextViewText(R.id.widget_app_name, smallAppName)
                            views.setTextViewText(R.id.widget_visited_count, visitedCount.toString())
                            views.setTextViewText(R.id.widget_title, title)
                            views.setTextViewText(R.id.widget_destination, if (showContinents) (stat3.ifBlank { subtitle }) else subtitle)
                            views.setTextViewText(R.id.widget_packing, "✈️ $visitedCount")
                            views.setTextViewText(R.id.widget_budget, "🌟 $wishlistCount")

                            views.setProgressBar(R.id.widget_progress, 100, pctNum, false)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                views.setColorStateList(R.id.widget_progress, "setProgressTintList", ColorStateList.valueOf(theme.accentColor))
                            }

                            views.setViewVisibility(R.id.widget_budget, if (showWishlist) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_destination, if (showContinents) View.VISIBLE else View.GONE)
                        }

                        // Render World Map Bitmap
                        if (size != WidgetLayoutSize.SMALL) {
                            val mapPath = if (showWishlist) {
                                when (size) {
                                    WidgetLayoutSize.LARGE -> widgetData.getString("map_image_large", null)
                                        ?: widgetData.getString("map_image_medium", null)
                                    WidgetLayoutSize.MEDIUM -> widgetData.getString("map_image_medium", null)
                                        ?: widgetData.getString("map_image_large", null)
                                    WidgetLayoutSize.SMALL -> null
                                }
                            } else {
                                when (size) {
                                    WidgetLayoutSize.LARGE -> widgetData.getString("map_image_large_nowishlist", null)
                                        ?: widgetData.getString("map_image_large", null)
                                        ?: widgetData.getString("map_image_medium_nowishlist", null)
                                        ?: widgetData.getString("map_image_medium", null)
                                    WidgetLayoutSize.MEDIUM -> widgetData.getString("map_image_medium_nowishlist", null)
                                        ?: widgetData.getString("map_image_medium", null)
                                        ?: widgetData.getString("map_image_large_nowishlist", null)
                                        ?: widgetData.getString("map_image_large", null)
                                    WidgetLayoutSize.SMALL -> null
                                }
                            }
                            if (!mapPath.isNullOrEmpty()) {
                                val file = File(mapPath)
                                if (file.exists() && file.length() > 0) {
                                    val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                                    if (bitmap != null) {
                                        views.setImageViewBitmap(R.id.widget_map_image, bitmap)
                                        views.setViewVisibility(R.id.widget_map_image, View.VISIBLE)
                                    }
                                }
                            }
                        }

                        if (widgetId > 0) {
                            views.setOnClickPendingIntent(R.id.widget_badge, makeBroadcastPendingIntent(ACTION_TOGGLE_MAP_VIEW, 7))
                        }
                    } catch (_: Throwable) {}
                }

                else -> { // "trip"
                    setBgRes(views, R.id.widget_container, theme.bgResId)
                    views.setTextColor(R.id.widget_app_name, theme.accentColor)
                    views.setTextColor(R.id.widget_title, theme.titleTextColor)
                    views.setTextColor(R.id.widget_destination, theme.subtitleTextColor)

                    val appName = widgetData.getString("trip_app_name", "PackBuddy • Seyahat") ?: "PackBuddy • Seyahat"
                    val daysVal = safeGetInt(widgetData, "trip_days", 0)
                    val tripMode = safeGetInt(widgetData, "widget_${widgetId}_trip_mode", 0)
                    val daysDisplay = when (tripMode) {
                        1 -> "${Math.max(1, (daysVal + 6) / 7)}w"
                        2 -> (widgetData.getString("trip_packing", "0/0") ?: "0/0")
                        else -> "${daysVal}d"
                    }

                    val title = widgetData.getString("trip_title", "PackBuddy") ?: "PackBuddy"
                    val destination = widgetData.getString("trip_destination", "") ?: ""
                    val packing = widgetData.getString("trip_packing", "0/0") ?: "0/0"
                    val budget = widgetData.getString("trip_budget", "") ?: ""
                    val footer = widgetData.getString("trip_footer", "Geri sayım başladı") ?: "Geri sayım başladı"
                    val showCountdown = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_trip_show_countdown" else "pending_pin_trip_show_countdown",
                        "trip_show_countdown",
                        true
                    )
                    val showPacking = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_trip_show_packing" else "pending_pin_trip_show_packing",
                        "trip_show_packing",
                        true
                    )
                    val showBudget = safeGetBoolean(
                        widgetData,
                        if (widgetId > 0) "widget_${widgetId}_trip_show_budget" else "pending_pin_trip_show_budget",
                        "trip_show_budget",
                        true
                    )

                    val packingLabel = widgetData.getString("trip_packing_label", "Bagaj") ?: "Bagaj"
                    val spentLabel = widgetData.getString("trip_spent_label", "Harcanan") ?: "Harcanan"

                    val packingParts = packing.replace("🎒", "").trim().split("/")
                    val packedNum = packingParts.getOrNull(0)?.toIntOrNull() ?: 0
                    val totalNum = packingParts.getOrNull(1)?.toIntOrNull() ?: 0
                    val packingPct = if (totalNum > 0) ((packedNum * 100) / totalNum).coerceIn(0, 100) else 0

                    try {
                        val cleanAppName = if (appName.startsWith("PackBuddy") && !appName.startsWith("✈️")) "✈️ $appName" else appName
                        views.setTextViewText(R.id.widget_app_name, cleanAppName)
                        views.setTextViewText(R.id.widget_days, daysDisplay)
                        views.setTextViewText(R.id.widget_title, title)
                        views.setTextViewText(R.id.widget_destination, destination)

                        if (size == WidgetLayoutSize.LARGE) {
                            setBgRes(views, R.id.widget_days, theme.badgeResId)
                            setBgRes(views, R.id.widget_destination_card, theme.statResId)
                            setBgRes(views, R.id.widget_packing_card, theme.statResId)
                            setBgRes(views, R.id.widget_budget_card, theme.statResId)

                            views.setTextColor(R.id.widget_days, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_title, theme.titleTextColor)
                            views.setTextColor(R.id.widget_destination, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_packing, theme.titleTextColor)
                            views.setTextColor(R.id.widget_packing_pct, theme.titleTextColor)
                            views.setTextColor(R.id.widget_budget, theme.titleTextColor)
                            views.setTextColor(R.id.widget_footer, theme.subtitleTextColor)

                            views.setTextViewText(R.id.widget_days, daysDisplay.uppercase(Locale.ROOT))
                            views.setTextViewText(R.id.widget_packing, "$packingLabel: $packedNum/$totalNum")
                            views.setTextViewText(R.id.widget_packing_pct, "$packingPct%")
                            views.setProgressBar(R.id.widget_packing_progress, 100, packingPct, false)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                views.setColorStateList(R.id.widget_packing_progress, "setProgressTintList", ColorStateList.valueOf(theme.accentColor))
                            }

                            views.setTextViewText(R.id.widget_budget, "$spentLabel: $budget")
                            views.setTextViewText(R.id.widget_footer, footer)

                            views.setViewVisibility(R.id.widget_days, if (showCountdown) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_packing_card, if (showPacking) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_budget_card, if (showBudget) View.VISIBLE else View.GONE)

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_days, makeBroadcastPendingIntent(ACTION_TOGGLE_TRIP_VIEW, 8))
                                views.setOnClickPendingIntent(R.id.widget_packing_card, makeBroadcastPendingIntent(ACTION_TOGGLE_TRIP_VIEW, 8))
                            }
                        } else if (size == WidgetLayoutSize.MEDIUM) {
                            setBgRes(views, R.id.widget_days, theme.badgeResId)
                            setBgRes(views, R.id.widget_packing_box, theme.statResId)
                            setBgRes(views, R.id.widget_budget_box, theme.statResId)

                            views.setTextColor(R.id.widget_days, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_title, theme.titleTextColor)
                            views.setTextColor(R.id.widget_destination, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_packing_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_packing_pct, theme.titleTextColor)
                            views.setTextColor(R.id.widget_packing, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_budget_label, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_budget, theme.accentColor)

                            views.setTextViewText(R.id.widget_packing_label, packingLabel)
                            views.setTextViewText(R.id.widget_packing_pct, "$packingPct%")
                            views.setTextViewText(R.id.widget_packing, "$packedNum/$totalNum")
                            views.setProgressBar(R.id.widget_packing_progress, 100, packingPct, false)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                views.setColorStateList(R.id.widget_packing_progress, "setProgressTintList", ColorStateList.valueOf(theme.accentColor))
                            }

                            views.setTextViewText(R.id.widget_budget_label, spentLabel)
                            views.setTextViewText(R.id.widget_budget, budget)

                            views.setViewVisibility(R.id.widget_days, if (showCountdown) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_packing_box, if (showPacking) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_budget_box, if (showBudget) View.VISIBLE else View.GONE)

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_days, makeBroadcastPendingIntent(ACTION_TOGGLE_TRIP_VIEW, 8))
                            }
                        } else { // SMALL
                            setBgRes(views, R.id.widget_days, theme.badgeResId)
                            setBgRes(views, R.id.widget_bottom_card, theme.statResId)

                            views.setTextColor(R.id.widget_days, theme.badgeTextColor)
                            views.setTextColor(R.id.widget_title, theme.titleTextColor)
                            views.setTextColor(R.id.widget_destination, theme.subtitleTextColor)
                            views.setTextColor(R.id.widget_packing, theme.accentColor)

                            val smallAppName = if (appName.startsWith("PackBuddy") && !appName.startsWith("✈️")) "✈️ PackBuddy" else "PackBuddy"
                            views.setTextViewText(R.id.widget_app_name, smallAppName)
                            val smallPackingText = if (showPacking) "$packingLabel: $packedNum/$totalNum" else budget
                            views.setTextViewText(R.id.widget_packing, smallPackingText)

                            views.setProgressBar(R.id.widget_packing_progress, 100, packingPct, false)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                views.setColorStateList(R.id.widget_packing_progress, "setProgressTintList", ColorStateList.valueOf(theme.accentColor))
                            }
                            views.setViewVisibility(R.id.widget_packing_progress, if (showPacking) View.VISIBLE else View.GONE)

                            views.setViewVisibility(R.id.widget_days, if (showCountdown) View.VISIBLE else View.GONE)
                            views.setViewVisibility(R.id.widget_bottom_card, if (showPacking || showBudget) View.VISIBLE else View.GONE)

                            if (widgetId > 0) {
                                views.setOnClickPendingIntent(R.id.widget_days, makeBroadcastPendingIntent(ACTION_TOGGLE_TRIP_VIEW, 8))
                            }
                        }
                    } catch (_: Throwable) {}
                }
            }

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

        private fun safeGetDouble(prefs: SharedPreferences, key: String, default: Double): Double {
            return try {
                prefs.getFloat(key, default.toFloat()).toDouble()
            } catch (_: Exception) {
                try {
                    (prefs.all[key] as? Number)?.toDouble() ?: default
                } catch (_: Exception) {
                    default
                }
            }
        }

        fun safeGetBoolean(prefs: SharedPreferences, primaryKey: String, fallbackKey: String, default: Boolean): Boolean {
            return try {
                if (prefs.contains(primaryKey)) {
                    val raw = prefs.all[primaryKey]
                    when (raw) {
                        is Boolean -> raw
                        is String -> raw.toBoolean()
                        is Number -> raw.toInt() != 0
                        else -> default
                    }
                } else if (prefs.contains(fallbackKey)) {
                    val raw = prefs.all[fallbackKey]
                    when (raw) {
                        is Boolean -> raw
                        is String -> raw.toBoolean()
                        is Number -> raw.toInt() != 0
                        else -> default
                    }
                } else {
                    default
                }
            } catch (_: Exception) {
                default
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action ?: return
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return

        val widgetData = HomeWidgetPlugin.getData(context)

        when (action) {
            ACTION_CYCLE_CURRENCY -> {
                val currentCur = widgetData.getString("widget_${widgetId}_currency", null)
                    ?: widgetData.getString("user_currency", "TRY")
                    ?: "TRY"
                val list = CurrencyHelper.supportedCurrencies
                val idx = list.indexOf(currentCur)
                val nextCur = list[(if (idx >= 0) idx + 1 else 0) % list.size]
                widgetData.edit().putString("widget_${widgetId}_currency", nextCur).apply()
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
            }
            ACTION_CYCLE_USD_AMOUNT -> {
                val curIdx = widgetData.getInt("widget_${widgetId}_usd_idx", 0)
                val nextIdx = (curIdx + 1) % usdAmounts.size
                widgetData.edit().putInt("widget_${widgetId}_usd_idx", nextIdx).apply()
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
            }
            ACTION_CYCLE_EUR_AMOUNT -> {
                val curIdx = widgetData.getInt("widget_${widgetId}_eur_idx", 0)
                val nextIdx = (curIdx + 1) % eurAmounts.size
                widgetData.edit().putInt("widget_${widgetId}_eur_idx", nextIdx).apply()
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
            }
            ACTION_CYCLE_CONVERSIONS -> {
                val curVal = widgetData.getBoolean("widget_${widgetId}_conv_base_eur", false)
                widgetData.edit().putBoolean("widget_${widgetId}_conv_base_eur", !curVal).apply()
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
            }
            ACTION_TOGGLE_EXPENSE_VIEW -> {
                val curMode = widgetData.getInt("widget_${widgetId}_exp_mode", 0)
                widgetData.edit().putInt("widget_${widgetId}_exp_mode", (curMode + 1) % 3).apply()
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
            }
            ACTION_QUICK_EXPENSE_INCREMENT -> {
                val tripId = widgetData.getString("active_trip_id", "") ?: ""
                val currency = widgetData.getString("active_trip_currency", null)
                    ?: widgetData.getString("user_currency", "TRY")
                    ?: "TRY"
                if (tripId.isNotEmpty()) {
                    val step = when (currency) {
                        "JPY" -> 1000.0
                        "EUR", "USD", "GBP" -> 10.0
                        else -> 50.0
                    }
                    insertQuickExpense(context, tripId, currency, step, "Hızlı Harcama")
                    val prevSpent = safeGetDouble(widgetData, "trip_budget_spent_num", 0.0)
                    val newSpent = prevSpent + step
                    val limit = safeGetDouble(widgetData, "trip_budget_limit_num", 0.0)
                    val remaining = if (limit > 0) Math.max(0.0, limit - newSpent) else 0.0
                    val formattedSpent = CurrencyHelper.format(newSpent, currency)
                    val formattedRemaining = CurrencyHelper.format(remaining, currency)
                    val lastText = "Hızlı: +" + CurrencyHelper.format(step, currency)

                    widgetData.edit()
                        .putFloat("trip_budget_spent_num", newSpent.toFloat())
                        .putString("trip_budget", formattedSpent)
                        .putString("remaining_budget", formattedRemaining)
                        .putString("last_expense_text", lastText)
                        .apply()

                    updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
                } else {
                    try {
                        val launchUri = android.net.Uri.parse("packbuddy://add_expense")
                        val actIntent = Intent(context, MainActivity::class.java).apply {
                            data = launchUri
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        }
                        context.startActivity(actIntent)
                    } catch (_: Throwable) {}
                }
            }
            ACTION_TOGGLE_MAP_VIEW -> {
                val curMode = widgetData.getInt("widget_${widgetId}_map_mode", 0)
                widgetData.edit().putInt("widget_${widgetId}_map_mode", (curMode + 1) % 3).apply()
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
            }
            ACTION_TOGGLE_TRIP_VIEW -> {
                val curMode = widgetData.getInt("widget_${widgetId}_trip_mode", 0)
                widgetData.edit().putInt("widget_${widgetId}_trip_mode", (curMode + 1) % 3).apply()
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData, null)
            }
        }
    }

    private fun insertQuickExpense(context: Context, tripId: String, currency: String, amount: Double, title: String) {
        try {
            val dbFile = context.getDatabasePath("packbuddy.db")
            if (!dbFile.exists()) return
            val db = SQLiteDatabase.openDatabase(
                dbFile.absolutePath,
                null,
                SQLiteDatabase.OPEN_READWRITE
            )
            val cv = ContentValues().apply {
                put("id", UUID.randomUUID().toString())
                put("user_id", "")
                put("trip_id", tripId)
                put("title", title)
                put("amount", amount)
                put("currency", currency)
                put("category", "General")
                put("date", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
                    timeZone = TimeZone.getTimeZone("UTC")
                }.format(Date()))
                put("created_at", System.currentTimeMillis())
                put("updated_at", System.currentTimeMillis())
                put("is_deleted", 0)
            }
            db.insertWithOnConflict("expenses", null, cv, SQLiteDatabase.CONFLICT_REPLACE)
            db.close()
        } catch (e: Throwable) {
            Log.e(TAG, "Error inserting quick expense into SQLite", e)
        }
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

                val viewsMap = when (defaultLayoutSize) {
                    WidgetLayoutSize.SMALL -> mapOf(
                        SizeF(40f, 40f) to smallViews,
                        SizeF(230f, 40f) to mediumViews,
                        SizeF(230f, 210f) to largeViews
                    )
                    WidgetLayoutSize.MEDIUM -> mapOf(
                        SizeF(40f, 40f) to smallViews,
                        SizeF(210f, 40f) to mediumViews,
                        SizeF(210f, 210f) to largeViews
                    )
                    WidgetLayoutSize.LARGE -> mapOf(
                        SizeF(40f, 40f) to smallViews,
                        SizeF(210f, 40f) to mediumViews,
                        SizeF(210f, 210f) to largeViews
                    )
                }
                val responsiveViews = RemoteViews(viewsMap)
                appWidgetManager.updateAppWidget(widgetId, responsiveViews)
                return
            }

            // Android 11 and below dynamic layout selection based on measured dp
            val opts = options ?: appWidgetManager.getAppWidgetOptions(widgetId)
            val minWidth = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0) ?: 0
            val minHeight = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0) ?: 0

            val chosenSize = when {
                defaultLayoutSize == WidgetLayoutSize.SMALL -> {
                    if (minWidth >= 230 && minHeight >= 210) WidgetLayoutSize.LARGE
                    else if (minWidth >= 230) WidgetLayoutSize.MEDIUM
                    else WidgetLayoutSize.SMALL
                }
                defaultLayoutSize == WidgetLayoutSize.MEDIUM -> {
                    if (minHeight >= 210 && minWidth >= 210) WidgetLayoutSize.LARGE
                    else if (minWidth < 210) WidgetLayoutSize.SMALL
                    else WidgetLayoutSize.MEDIUM
                }
                defaultLayoutSize == WidgetLayoutSize.LARGE -> {
                    if (minWidth < 210 && minHeight < 210) WidgetLayoutSize.SMALL
                    else if (minHeight < 210) WidgetLayoutSize.MEDIUM
                    else WidgetLayoutSize.LARGE
                }
            }

            val views = buildRemoteViews(context, widgetData, chosenSize, widgetId)
            appWidgetManager.updateAppWidget(widgetId, views)
        } catch (e: Throwable) {
            Log.e(TAG, "Error updating widget $widgetId", e)
            try {
                val fallback = RemoteViews(context.packageName, R.layout.packbuddy_trip_small)
                fallback.setTextViewText(R.id.widget_app_name, "PackBuddy")
                fallback.setTextViewText(R.id.widget_title, "PackBuddy")
                fallback.setTextViewText(R.id.widget_destination, "Tap to open")
                appWidgetManager.updateAppWidget(widgetId, fallback)
            } catch (_: Throwable) {}
        }
    }

    fun buildRemoteViews(
        context: Context,
        widgetData: SharedPreferences,
        size: WidgetLayoutSize,
        widgetId: Int
    ): RemoteViews {
        val widgetModeKey = "widget_${widgetId}_mode"
        val widgetThemeKey = "widget_${widgetId}_theme"
        val widgetConfiguredKey = "widget_${widgetId}_configured"

        if (widgetId > 0 && !widgetData.contains(widgetConfiguredKey)) {
            val pendingPinMode = widgetData.getString("pending_pin_mode", null)
            val pendingPinTheme = widgetData.getString("pending_pin_theme", null)
            val assignMode = inherentMode ?: pendingPinMode ?: widgetData.getString("widget_mode", "trip") ?: "trip"
            val assignTheme = pendingPinTheme ?: widgetData.getString("${assignMode}_theme", null) ?: "midnight"

            val editor = widgetData.edit()
            editor.putString(widgetModeKey, assignMode)
            editor.putString(widgetThemeKey, assignTheme)

            editor.putBoolean(
                "widget_${widgetId}_map_show_continents",
                safeGetBoolean(widgetData, "pending_pin_map_show_continents", "map_show_continents", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_map_show_wishlist",
                safeGetBoolean(widgetData, "pending_pin_map_show_wishlist", "map_show_wishlist", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_trip_show_countdown",
                safeGetBoolean(widgetData, "pending_pin_trip_show_countdown", "trip_show_countdown", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_trip_show_packing",
                safeGetBoolean(widgetData, "pending_pin_trip_show_packing", "trip_show_packing", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_trip_show_budget",
                safeGetBoolean(widgetData, "pending_pin_trip_show_budget", "trip_show_budget", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_currency_show_live_rate",
                safeGetBoolean(widgetData, "pending_pin_currency_show_live_rate", "currency_show_live_rate", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_currency_show_reverse_rate",
                safeGetBoolean(widgetData, "pending_pin_currency_show_reverse_rate", "currency_show_reverse_rate", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_quick_expense_show_remaining",
                safeGetBoolean(widgetData, "pending_pin_quick_expense_show_remaining", "quick_expense_show_remaining", true)
            )
            editor.putBoolean(
                "widget_${widgetId}_quick_expense_show_last",
                safeGetBoolean(widgetData, "pending_pin_quick_expense_show_last", "quick_expense_show_last", true)
            )

            editor.putBoolean(widgetConfiguredKey, true)
            editor.commit()
        }

        val mode = inherentMode
            ?: widgetData.getString(widgetModeKey, null)
            ?: widgetData.getString("pending_pin_mode", null)
            ?: widgetData.getString("widget_mode", "trip")
            ?: "trip"

        val widgetTheme = widgetData.getString("${mode}_theme", null)
            ?: widgetData.getString("pending_pin_theme", null)
            ?: widgetData.getString(widgetThemeKey, null)
            ?: widgetData.getString("widget_theme", "midnight")
            ?: "midnight"

        return populateViews(context, widgetData, mode, widgetTheme, size, widgetId, this.javaClass)
    }
}

data class WidgetThemeInfo(
    val bgResId: Int,
    val statResId: Int,
    val badgeResId: Int,
    val mapResId: Int,
    val accentColor: Int,
    val titleTextColor: Int,
    val subtitleTextColor: Int,
    val badgeColor: Int,
    val badgeTextColor: Int,
    val visitedColor: Int,
    val wishlistColor: Int,
    val isLight: Boolean
)

data class Tuple8<A, B, C, D, E, F, G, H>(
    val first: A,
    val second: B,
    val third: C,
    val fourth: D,
    val fifth: E,
    val sixth: F,
    val seventh: G,
    val eighth: H
)
