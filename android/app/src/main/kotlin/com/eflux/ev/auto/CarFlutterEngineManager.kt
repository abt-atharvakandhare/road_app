package com.eflux.ev.auto

import android.content.Context
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Manages a headless FlutterEngine that backs the Android Auto screens when
 * the phone app is not running. The car host only binds PlacesCarAppService,
 * so without this engine there is no Dart side to fetch nearby charging
 * stations — the car screen would sit empty until the user picked up their
 * phone, which violates the Play Store driver-distraction guidelines.
 *
 * Only one Dart pipeline may own the Android Auto method channel at a time:
 * - Car session starts, app not running  -> headless engine is started here.
 * - User opens the app                   -> MainActivity destroys the headless
 *                                           engine and attaches its own.
 * - User closes the app mid-session     -> MainActivity respawns the headless
 *                                           engine from cleanUpFlutterEngine.
 */
object CarFlutterEngineManager {

    private const val TAG = "CarFlutterEngineManager"

    // Resolved in the root library: the `@pragma('vm:entry-point')
    // carScreenMain()` function in lib/main.dart. It must stay there —
    // entrypoints in other files are not compiled into the bundle unless
    // main.dart imports them (fails at runtime with "library not found").
    private const val ENTRYPOINT_FUNCTION = "carScreenMain"

    private var headlessEngine: FlutterEngine? = null

    /**
     * Starts a headless engine running carScreenMain unless a Flutter engine
     * (headless or activity-owned) is already serving the Android Auto channel.
     * Must be called from the main thread.
     */
    @Synchronized
    fun ensureEngine(context: Context) {
        if (AndroidAutoProcessor.getInstance() != null) {
            Log.d(TAG, "Android Auto channel already served by an engine - nothing to do")
            return
        }
        if (headlessEngine != null) {
            Log.w(TAG, "Headless engine exists but has no processor - recreating")
            destroyEngine()
        }

        Log.d(TAG, "Starting headless Flutter engine for Android Auto")
        val appContext = context.applicationContext
        val loader = FlutterInjector.instance().flutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(appContext)
            loader.ensureInitializationComplete(appContext, null)
        }

        val engine = FlutterEngine(appContext)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(),
                ENTRYPOINT_FUNCTION,
            )
        )
        AndroidAutoProcessor(engine)
        headlessEngine = engine
    }

    /** Tears down the headless engine (no-op when none is running). */
    @Synchronized
    fun destroyEngine() {
        headlessEngine?.let { engine ->
            Log.d(TAG, "Destroying headless Flutter engine")
            AndroidAutoProcessor.clearInstance(engine)
            engine.destroy()
        }
        headlessEngine = null
    }
}
