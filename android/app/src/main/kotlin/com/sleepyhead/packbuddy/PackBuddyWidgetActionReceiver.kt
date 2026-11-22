package com.sleepyhead.packbuddy

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * #17: Receives PackBuddy home-widget button actions (quick expense, view toggles, currency cycling).
 *
 * Declared with android:exported="false": only PendingIntents created by PackBuddy itself can reach
 * it, so other apps on the device cannot inject fake expenses or change widget state. The action is
 * dispatched to the provider class that actually owns the widget id (keeps per-size layouts working).
 */
class PackBuddyWidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return

        val info = AppWidgetManager.getInstance(context).getAppWidgetInfo(widgetId) ?: return
        if (info.provider.packageName != context.packageName) return

        val provider = try {
            Class.forName(info.provider.className).getDeclaredConstructor().newInstance() as? PackBuddyWidgetProvider
        } catch (e: Throwable) {
            Log.w(PackBuddyWidgetProvider.TAG, "Widget action provider resolution failed: ${e.message}")
            null
        } ?: return

        provider.handleWidgetAction(context, intent)
    }
}
