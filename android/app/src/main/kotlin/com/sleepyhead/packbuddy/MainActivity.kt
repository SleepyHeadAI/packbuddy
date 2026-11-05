package com.sleepyhead.packbuddy

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.Display
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val SECURITY_CHANNEL = "com.sleepyhead.packbuddy/security"

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
    }
}
