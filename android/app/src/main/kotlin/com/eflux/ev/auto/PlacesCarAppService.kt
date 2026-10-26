package com.eflux.ev.auto


import android.content.Intent
import android.util.Log
import androidx.car.app.CarAppService
import androidx.car.app.Screen
import androidx.car.app.Session
import androidx.car.app.SessionInfo
import androidx.car.app.validation.HostValidator

class PlacesCarAppService : CarAppService() {

    companion object {
        private const val TAG = "PlacesCarAppService"
    }

    override fun createHostValidator(): HostValidator {
        return HostValidator.Builder(applicationContext)
            .addAllowedHosts(androidx.car.app.R.array.hosts_allowlist_sample)
            .build()
    }

    override fun onCreateSession(sessionInfo: SessionInfo): Session {
        Log.d(TAG, "Android Auto session created")
        // The car screen must work without the user touching their phone
        // (Play Store driver-distraction requirement): when the phone app
        // isn't running, boot a headless Flutter engine to serve station data.
        CarFlutterEngineManager.ensureEngine(applicationContext)
        return PlacesSession()
    }
}

class PlacesSession : Session() {

    companion object {
        private const val TAG = "PlacesSession"

        // Visibility-scoped (onStart/onStop): true while the car screen is
        // actually showing. Drives pipeline activation — AndroidAutoProcessor's
        // init check and the getCarSessionState pull — so the Dart side never
        // polls the API for an invisible screen.
        @Volatile
        var isSessionActive: Boolean = false
            private set

        // Lifetime-scoped (onCreate/onDestroy): true while a car session exists
        // at all, visible or not. The respawn decision in
        // MainActivity.cleanUpFlutterEngine must use this one — closing the
        // phone app while the car screen is stopped-but-alive would otherwise
        // skip the headless engine, leaving the returning car screen with no
        // engine to notify.
        @Volatile
        var isSessionAlive: Boolean = false
            private set
    }

    private var isCarAppVisible = false

    init {
        // Set up lifecycle observer
        lifecycle.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
            override fun onCreate(owner: androidx.lifecycle.LifecycleOwner) {
                super.onCreate(owner)
                Log.d(TAG, "Android Auto session onCreate - notifying Flutter of active state")
                isSessionAlive = true
                isSessionActive = true

                // Use the existing AndroidAutoProcessor instance to notify Flutter
                // If AndroidAutoProcessor is not yet initialized (app not running),
                // it will check isSessionActive when it initializes later
                AndroidAutoProcessor.getInstance()?.notifyCarSystemStateChanged(true)
                    ?: Log.w(TAG, "AndroidAutoProcessor not initialized yet - will sync state when app starts")
            }

            override fun onStart(owner: androidx.lifecycle.LifecycleOwner) {
                super.onStart(owner)
                Log.d(TAG, "Android Auto app visible on car display - notifying Flutter of active state")
                isCarAppVisible = true
                isSessionActive = true

                // Notify Flutter that the car system is active
                AndroidAutoProcessor.getInstance()?.notifyCarSystemStateChanged(true)
                    ?: Log.w(TAG, "AndroidAutoProcessor not initialized yet - will sync state when app starts")
            }

            override fun onStop(owner: androidx.lifecycle.LifecycleOwner) {
                super.onStop(owner)
                Log.d(TAG, "Android Auto app no longer visible on car display - notifying Flutter of inactive state")
                isCarAppVisible = false
                isSessionActive = false

                // Notify Flutter that the car system is inactive
                AndroidAutoProcessor.getInstance()?.notifyCarSystemStateChanged(false)
                    ?: Log.w(TAG, "AndroidAutoProcessor not initialized yet - will sync state when app starts")
            }

            override fun onDestroy(owner: androidx.lifecycle.LifecycleOwner) {
                super.onDestroy(owner)
                Log.d(TAG, "Android Auto session onDestroy - notifying Flutter of inactive state")
                isSessionAlive = false
                isSessionActive = false

                // Use the existing AndroidAutoProcessor instance to notify Flutter
                AndroidAutoProcessor.getInstance()?.notifyCarSystemStateChanged(false)
                    ?: Log.w(TAG, "AndroidAutoProcessor not initialized yet - will sync state when app starts")

                // No car session left - a headless engine has nothing to serve
                CarFlutterEngineManager.destroyEngine()
            }
        })
    }

    override fun onCreateScreen(intent: Intent): Screen {
        // Runs in the app's own process; station data arrives via EvseManager,
        // fed over the method channel by whichever Flutter engine is active
        // (the phone app's or the headless Android Auto engine).
        return MapScreen(carContext)
    }
}