package com.eflux.ev.notifications

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Exposes the launching Intent's FCM extras to Dart as a fallback for
 * [FirebaseMessaging.getInitialMessage], which intermittently returns null on
 * Android cold-starts when the background isolate also handles the message.
 *
 * The Dart side calls `getFcmExtras` on startup if `getInitialMessage()` returned
 * null. We return the data-block fields (e.g. `action`, `url`) while filtering
 * out FCM's own bookkeeping keys (`google.*`, `from`, `collapse_key`).
 */
class LaunchIntentProcessor(
    // Safe to hold because this processor is owned by MainActivity and shares
    // its lifecycle. If this is ever moved to a longer-lived owner
    // (e.g. MainApplication) the activity reference must be reworked to avoid
    // leaking the activity.
    private val activity: Activity,
    flutterEngine: FlutterEngine,
) {
    companion object {
        private const val CHANNEL_NAME = "io.e-flux.mobile/launchIntent"
        private const val METHOD_GET_FCM_EXTRAS = "getFcmExtras"
        private const val FCM_MESSAGE_ID_KEY = "google.message_id"
        private val SKIP_KEY_PREFIXES = listOf("google.", "gcm.")
        private val SKIP_KEYS = setOf("from", "collapse_key", "message_type")
    }

    init {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_GET_FCM_EXTRAS -> result.success(readFcmExtras())
                else -> result.notImplemented()
            }
        }
    }

    private fun readFcmExtras(): Map<String, String>? {
        val extras = activity.intent?.extras ?: return null
        val messageId = extras.getString(FCM_MESSAGE_ID_KEY) ?: return null
        return buildMap {
            // Surface the FCM message ID so the Dart side can dedup against the
            // standard onMessageOpenedApp / getInitialMessage paths.
            put(FCM_MESSAGE_ID_KEY, messageId)
            for (key in extras.keySet()) {
                if (SKIP_KEY_PREFIXES.any { key.startsWith(it) } || key in SKIP_KEYS) continue
                val value = extras.get(key) ?: continue
                put(key, value.toString())
            }
        }
    }
}
