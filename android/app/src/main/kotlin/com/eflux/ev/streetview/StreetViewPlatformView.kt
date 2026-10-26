package com.eflux.ev.streetview

import android.content.Context
import android.view.View
import com.google.android.gms.maps.StreetViewPanoramaOptions
import com.google.android.gms.maps.StreetViewPanoramaView
import com.google.android.gms.maps.model.LatLng
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class StreetViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    companion object {
        const val VIEW_TYPE = "road_mobile/street_view"
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        return StreetViewPlatformView(context, args as? Map<String, Any?>)
    }
}

/**
 * Embeds a native Google Street View panorama, positioned near the coordinate
 * passed in the creation params. All user interaction (pan, zoom, navigation)
 * is handled by the native view; there is no channel back to Dart.
 */
class StreetViewPlatformView(context: Context, args: Map<String, Any?>?) : PlatformView {
    private val panoramaView: StreetViewPanoramaView

    init {
        val latitude = args?.get("latitude") as? Double ?: 0.0
        val longitude = args?.get("longitude") as? Double ?: 0.0
        val radius = (args?.get("radius") as? Number)?.toInt() ?: 50

        val options = StreetViewPanoramaOptions()
            .position(LatLng(latitude, longitude), radius)

        // StreetViewPanoramaView normally has its lifecycle forwarded from the host
        // activity/fragment; inside a PlatformView the view exists only between
        // create and dispose, so the lifecycle collapses to these paired calls.
        panoramaView = StreetViewPanoramaView(context, options)
        panoramaView.onCreate(null)
        panoramaView.onResume()
    }

    override fun getView(): View = panoramaView

    override fun dispose() {
        panoramaView.onPause()
        panoramaView.onDestroy()
    }
}
