package com.eflux.ev

import android.app.Application
import io.maido.intercom.IntercomFlutterPlugin
import java.io.BufferedReader
import java.io.InputStreamReader

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        initializeIntercom()
    }

    private fun initializeIntercom() {
        // TODO: This hardcoded package name check mirrors F.useIntercomForHelp in flavors.dart.
        //  If another flavor adds Intercom support, consider using a per-flavor buildConfigField
        //  or resValue to drive this check instead.
        if (packageName != "com.eflux.ev") return

        try {
            val env = loadEnvFromAssets()
            val appId = env["INTERCOM_APP_ID_PRODUCTION"] ?: return
            val androidApiKey = env["INTERCOM_ANDROID_API_KEY_PRODUCTION"] ?: return

            if (appId.isNotEmpty() && androidApiKey.isNotEmpty()) {
                IntercomFlutterPlugin.initSdk(this, appId = appId, androidApiKey = androidApiKey)
            }
        } catch (e: Exception) {
            // Non-fatal: Intercom will be initialized from Dart as a fallback
            android.util.Log.w("MainApplication", "Failed to initialize Intercom natively: ${e.message}")
        }
    }

    private fun loadEnvFromAssets(): Map<String, String> {
        val env = mutableMapOf<String, String>()
        assets.open("flutter_assets/.env").use { inputStream ->
            BufferedReader(InputStreamReader(inputStream)).use { reader ->
                reader.forEachLine { line ->
                    val trimmed = line.trim()
                    if (trimmed.isNotEmpty() && !trimmed.startsWith("#") && trimmed.contains("=")) {
                        val key = trimmed.substringBefore("=").trim()
                        val value = trimmed.substringAfter("=").trim()
                            .removeSurrounding("\"")
                            .removeSurrounding("'")
                        env[key] = value
                    }
                }
            }
        }
        return env
    }
}
