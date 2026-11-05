package com.sleepyhead.packbuddy

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.Display
import android.view.WindowManager
import androidx.annotation.NonNull
import es.antonborri.home_widget.HomeWidgetPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val SECURITY_CHANNEL = "com.sleepyhead.packbuddy/security"
    private val WIDGET_PIN_CHANNEL = "com.sleepyhead.packbuddy/widget_pin"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableHighRefreshRate()
    }

    override fun onResume() {
        super.onResume()
        enableHighRefreshRate()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    private fun enableHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val display: Display? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    display
                } else {
                    @Suppress("DEPRECATION")
                    windowManager.defaultDisplay
                }

                display?.supportedModes?.let { modes ->
                    var bestMode: Display.Mode? = null
                    var maxRate = 60.0f
                    for (mode in modes) {
                        if (mode.refreshRate > maxRate) {
                            maxRate = mode.refreshRate
                            bestMode = mode
                        }
                    }
                    if (bestMode != null) {
                        val params = window.attributes
                        params.preferredDisplayModeId = bestMode.modeId
                        window.attributes = params
                    }
                }
            } catch (_: Exception) {
                // Ignore if device restricts dynamic mode switching
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureScreen" -> {
                    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                "disableSecureScreen" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_PIN_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pinWidget") {
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val appWidgetManager = AppWidgetManager.getInstance(this)
                        if (appWidgetManager.isRequestPinAppWidgetSupported) {
                            val mode = call.argument<String>("mode") ?: "trip"
                            val theme = call.argument<String>("theme") ?: "midnight"
                            val sizeInt = call.argument<Int>("size") ?: 0
                            val providerName = call.argument<String>("provider") ?: "PackBuddyWidgetProvider"

                            val size = when (sizeInt) {
                                2 -> WidgetLayoutSize.LARGE
                                1 -> WidgetLayoutSize.MEDIUM
                                else -> WidgetLayoutSize.SMALL
                            }

                            val widgetData = HomeWidgetPlugin.getData(this)
                            widgetData.edit()
                                .putString("pending_pin_mode", mode)
                                .putString("pending_pin_theme", theme)
                                .putString("${mode}_theme", theme)
                                .putString("widget_theme", theme)
                                .commit()

                            val providerClass = Class.forName("com.sleepyhead.packbuddy.$providerName")
                            val previewViews = PackBuddyWidgetProvider.populateViews(
                                this,
                                widgetData,
                                mode,
                                theme,
                                size,
                                -1, // Preview mode: do not bind active click intents
                                providerClass
                            )

                            val providerComponent = ComponentName(this, providerClass)
                            val bundle = Bundle().apply {
                                putParcelable(AppWidgetManager.EXTRA_APPWIDGET_PREVIEW, previewViews)
                            }
                            val success = appWidgetManager.requestPinAppWidget(providerComponent, bundle, null)
                            result.success(success)
                            return@setMethodCallHandler
                        }
                    }
                    result.success(false)
                } catch (e: Throwable) {
                    result.error("PIN_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
