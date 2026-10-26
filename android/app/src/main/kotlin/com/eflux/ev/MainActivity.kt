package com.eflux.ev

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.xmlpull.v1.XmlPullParser
import com.eflux.ev.auto.AndroidAutoProcessor
import com.eflux.ev.auto.CarFlutterEngineManager
import com.eflux.ev.auto.PlacesSession
import com.eflux.ev.charging.ChargingServiceProcessor
import com.eflux.ev.notifications.LaunchIntentProcessor
import com.eflux.ev.payment.PaymentProcessor
import com.eflux.ev.streetview.StreetViewFactory

class MainActivity: FlutterFragmentActivity() {
    private lateinit var androidAutoProcessor: AndroidAutoProcessor
    private lateinit var paymentProcessor: PaymentProcessor
    private lateinit var chargingServiceProcessor: ChargingServiceProcessor
    private lateinit var launchIntentProcessor: LaunchIntentProcessor

    override fun attachBaseContext(base: Context) {
        // The app is light-only; force the night-mode flag off so the native
        // Google Maps SDK doesn't render its cloud-styled map in dark mode.
        val config = Configuration(base.resources.configuration)
        config.uiMode = (config.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or
            Configuration.UI_MODE_NIGHT_NO
        super.attachBaseContext(base.createConfigurationContext(config))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Hand the Android Auto channel over to this activity's engine: the
        // headless engine (if one was serving a car session) is retired and
        // the AndroidAutoProcessor below takes its place. Its init re-notifies
        // Flutter when a car session is already active.
        CarFlutterEngineManager.destroyEngine()

        // Initialize processors
        androidAutoProcessor = AndroidAutoProcessor(flutterEngine)
        paymentProcessor = PaymentProcessor(this, flutterEngine)
        chargingServiceProcessor = ChargingServiceProcessor(applicationContext, flutterEngine)
        launchIntentProcessor = LaunchIntentProcessor(this, flutterEngine)

        flutterEngine.platformViewsController.registry.registerViewFactory(
            StreetViewFactory.VIEW_TYPE,
            StreetViewFactory(),
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // This engine is going away; drop its Android Auto processor and, if a
        // car session still exists, hand back to a headless engine so the car
        // screen keeps working without the phone app. Alive (not visible) is
        // the right condition: a stopped-but-alive session fires onStart when
        // the user returns, and that notification needs an engine to land on.
        AndroidAutoProcessor.clearInstance(flutterEngine)
        if (PlacesSession.isSessionAlive) {
            CarFlutterEngineManager.ensureEngine(applicationContext)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // Let PaymentProcessor handle payment-related results
        if (!paymentProcessor.handleActivityResult(requestCode, resultCode, data)) {
            // Handle other activity results if needed
        }
    }
}
