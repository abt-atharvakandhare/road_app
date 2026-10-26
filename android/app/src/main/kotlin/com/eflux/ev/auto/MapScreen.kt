package com.eflux.ev.auto

import android.text.Spannable
import android.text.SpannableString
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarLocation
import androidx.car.app.model.Distance
import androidx.car.app.model.DistanceSpan
import androidx.car.app.model.ItemList
import androidx.car.app.model.Metadata
import androidx.car.app.model.Place
import androidx.car.app.model.PlaceListMapTemplate
import androidx.car.app.model.PlaceMarker
import androidx.car.app.model.Row
import androidx.car.app.model.Template
import androidx.car.app.model.Alert
import androidx.car.app.model.CarText
import androidx.car.app.model.ParkedOnlyOnClickListener
import androidx.car.app.ScreenManager
import androidx.car.app.model.MessageTemplate
import androidx.car.app.model.Header
import androidx.car.app.model.CarIcon
import androidx.core.graphics.drawable.IconCompat
import android.location.Location
import android.content.Intent
import android.net.Uri
import com.eflux.ev.R


class MapScreen(carContext: CarContext) : Screen(carContext), NearbyEvseListener, HighwayModeListener, FilterListener, FavouriteListener, UiStringsListener {

    companion object {
        private const val TAG = "MapScreen"

        fun buildNavigationErrorScreen(carContext: CarContext, evse: Evse): Screen {
            return object : Screen(carContext) {
                override fun onGetTemplate(): Template {
                    return MessageTemplate.Builder(EvseManager.shared.uiString("navigationNotAvailable", "Navigation not available"))
                        .setHeader(Header.Builder().setTitle(EvseManager.shared.uiString("navigationError", "Navigation Error")).build())
                        .addAction(
                            Action.Builder()
                                .setTitle(EvseManager.shared.uiString("navigateOnPhone", "Navigate on Phone"))
                                .setOnClickListener(ParkedOnlyOnClickListener.create {
                                    // Try to open navigation on phone
                                    val intent = Intent(Intent.ACTION_VIEW).apply {
                                        data = Uri.parse("geo:${evse.latitude},${evse.longitude}?q=${evse.latitude},${evse.longitude}(${Uri.encode(evse.title)})")
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    }
                                    carContext.startActivity(intent)
                                })
                                .build()
                        )
                        .addAction(Action.BACK)
                        .build()
                }
            }
        }
    }

    private var nearbyEvses: List<Evse> = emptyList()
    private var hasReceivedStationData = false
    private var carLocation: Location? = null
    private var hasLocationPermission: Boolean = false
    private var isHighwayModeActive: Boolean = false
    private var favouriteCount: Int = 0

    init {
        // Register as listener ONCE during initialization (not in onGetTemplate)
        // This ensures we receive station updates even if the main app starts after Android Auto
        EvseManager.shared.addListener(this)
        EvseManager.shared.addModeListener(this)
        EvseManager.shared.addFilterListener(this)
        EvseManager.shared.addFavouriteListener(this)
        EvseManager.shared.addUiStringsListener(this)

        // Get initial mode state
        isHighwayModeActive = EvseManager.shared.isHighwayModeActive

        // Check location permission status - Android Auto has separate permission context from main app
        hasLocationPermission = carContext.checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION) ==
            android.content.pm.PackageManager.PERMISSION_GRANTED

        if (hasLocationPermission) {
            requestLocationUpdates()
        } else {
            // Request permission - this will prompt the user on their phone
            carContext.requestPermissions(
                listOf(android.Manifest.permission.ACCESS_FINE_LOCATION)
            ) { granted, _ ->
                hasLocationPermission = granted.contains(android.Manifest.permission.ACCESS_FINE_LOCATION)
                if (hasLocationPermission) {
                    requestLocationUpdates()
                    // Geolocator (Dart) has no callback for runtime grants and a
                    // headless engine gets no foreground event - tell it to
                    // re-check so the station pipeline unblocks.
                    AndroidAutoProcessor.getInstance()?.notifyLocationPermissionChanged()
                }
                // Refresh template to update current location enabled state
                invalidate()
            }
        }

        // Set up lifecycle observer to clean up listener when screen is destroyed
        lifecycle.addObserver(object : androidx.lifecycle.DefaultLifecycleObserver {
            override fun onDestroy(owner: androidx.lifecycle.LifecycleOwner) {
                Log.d(TAG, "MapScreen destroyed - removing listeners")
                EvseManager.shared.removeListener(this@MapScreen)
                EvseManager.shared.removeModeListener(this@MapScreen)
                EvseManager.shared.removeFilterListener(this@MapScreen)
                EvseManager.shared.removeFavouriteListener(this@MapScreen)
                EvseManager.shared.removeUiStringsListener(this@MapScreen)
            }
        })
    }

    private fun requestLocationUpdates() {
        if (!hasLocationPermission) {
            Log.d(TAG, "Skipping location updates - permission not granted")
            return
        }

        val locationManager = carContext.getSystemService(android.content.Context.LOCATION_SERVICE) as android.location.LocationManager
        try {
            carLocation = locationManager.getLastKnownLocation(android.location.LocationManager.GPS_PROVIDER)
                ?: locationManager.getLastKnownLocation(android.location.LocationManager.NETWORK_PROVIDER)

            if (carLocation != null) {
                Log.d(TAG, "Got car location: ${carLocation?.latitude}, ${carLocation?.longitude}")
                invalidate()
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Location permission not granted", e)
            hasLocationPermission = false
        }
    }

    override fun onGetTemplate(): Template {
        Log.d(TAG, "Building list template with ${nearbyEvses.size} stations (highwayModeActive: $isHighwayModeActive)")
        return buildListTemplate()
    }

    private fun getTemplateTitle(): String {
        return if (isHighwayModeActive)
            EvseManager.shared.uiString("fastChargersAhead", "Fast Chargers Ahead")
        else
            EvseManager.shared.uiString("nearbyStations", "Nearby Stations")
    }

    private fun buildListTemplate(): PlaceListMapTemplate {
        // Never instruct the user to interact with their phone here: this text
        // is visible while driving (Play Store "Visual info on phone" policy).
        val noItemsMessage = if (hasReceivedStationData) {
            EvseManager.shared.uiString("noStationsFound", "No charging stations found nearby")
        } else {
            EvseManager.shared.uiString("searchingStations", "Searching for nearby charging stations…")
        }
        val itemListBuilder = ItemList.Builder()
            .setNoItemsMessage(noItemsMessage)

        nearbyEvses.forEach { evse ->
            // Build the second text line: distance span + optional price text
            val distance = evse.calculateDistance(carContext, carLocation)
            val secondLineText = if (evse.summary.isNotEmpty()) {
                SpannableString("\u200B ${evse.summary}").apply {
                    setSpan(
                        DistanceSpan.create(distance), 0, 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE
                    )
                }
            } else {
                SpannableString(" ").apply {
                    setSpan(
                        DistanceSpan.create(distance), 0, 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE
                    )
                }
            }

            itemListBuilder.addItem(
                Row.Builder()
                    .setTitle(evse.title)
                    .addText(evse.subtitle)
                    // Each item in the list must have a DistanceSpan applied to either the title
                    // or one of its lines of text (to help drivers make decisions)
                    .addText(secondLineText)
                    .setOnClickListener {
                        Log.d(TAG, "Selected EVSE: ${evse.title}")
                        // Push detail screen instead of changing template
                        screenManager.push(EvseDetailScreen(carContext, evse, carLocation))
                    }
                    .setMetadata(
                        Metadata.Builder()
                            .setPlace(
                                Place.Builder(CarLocation.create(evse.latitude, evse.longitude))
                                    .setMarker(
                                        PlaceMarker.Builder()
                                            .setColor(evse.status.markerColor)
                                            .build()
                                    )
                                    .build()
                            )
                            .build()
                    ).build()
            )
        }

        val actionStripBuilder = ActionStrip.Builder()

        // Filters button
        // Count active toggles + selected group children for the badge
        val activeCount = EvseManager.shared.filterItems.sumOf { item ->
            when (item) {
                is CarScreenFilterItem.Toggle -> if (item.filter.enabled) 1 as Int else 0
                is CarScreenFilterItem.Group -> item.group.children.count { it.selected }
            }
        }
        val filtersLabel = EvseManager.shared.uiString("filters", "Filters")
        val filterTitle = if (activeCount > 0) "$filtersLabel ($activeCount)" else filtersLabel
        val filterAction = Action.Builder()
            .setTitle(filterTitle)
            .setOnClickListener {
                Log.d(TAG, "Filter button tapped")
                screenManager.push(FilterScreen(carContext))
            }
            .build()
        actionStripBuilder.addAction(filterAction)

        // Add favourites action
        val favouritesLabel = EvseManager.shared.uiString("tabFavourites", "Favourites")
        val favouritesTitle = if (favouriteCount > 0) "$favouritesLabel ($favouriteCount)" else favouritesLabel
        val favouritesAction = Action.Builder()
            .setTitle(favouritesTitle)
            .setIcon(CarIcon.Builder(IconCompat.createWithResource(carContext, R.drawable.ic_tab_favourites)).build())
            .setOnClickListener {
                Log.d(TAG, "Favourites button tapped")
                screenManager.push(FavouritesScreen(carContext, carLocation))
            }
            .build()
        actionStripBuilder.addAction(favouritesAction)

        val actionStrip = actionStripBuilder.build()

        return PlaceListMapTemplate.Builder()
            .setTitle(getTemplateTitle())
            .setItemList(itemListBuilder.build())
            .setCurrentLocationEnabled(hasLocationPermission)
            .setActionStrip(actionStrip)
            .build()
    }

    override fun onNearbyEvsesChange(evses: List<Evse>) {
        nearbyEvses = evses
        hasReceivedStationData = true
        invalidate()
    }

    override fun onHighwayModeChange(isHighwayModeActive: Boolean, highwayMode: String) {
        Log.d(TAG, "Highway mode state changed - active: $isHighwayModeActive")
        this.isHighwayModeActive = isHighwayModeActive
        invalidate()
    }

    override fun onFilterItemsChange(filterItems: List<CarScreenFilterItem>) {
        Log.d(TAG, "Filter items updated - ${filterItems.size} definitions")
        invalidate()
    }

    override fun onFavouritesChange(favourites: List<Evse>) {
        Log.d(TAG, "Favourites updated - ${favourites.size} stations")
        favouriteCount = favourites.size
        invalidate()
    }

    override fun onUiStringsChange() {
        Log.d(TAG, "UI strings updated - refreshing template")
        invalidate()
    }
}
