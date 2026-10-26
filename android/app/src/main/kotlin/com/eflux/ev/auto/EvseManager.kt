package com.eflux.ev.auto

import android.content.Intent
import android.location.Location
import android.net.Uri
import android.os.Build
import java.util.concurrent.CopyOnWriteArraySet
import android.util.Log
import android.icu.util.LocaleData
import android.icu.util.ULocale
import androidx.car.app.CarContext
import androidx.car.app.HostException
import androidx.car.app.model.CarColor
import androidx.car.app.model.Distance


/**
 * A simple on/off filter toggle received from Flutter.
 */
data class CarScreenFilter(
    val key: String,
    val label: String,
    val enabled: Boolean
)

/**
 * A child option within a filter group.
 */
data class CarScreenFilterChild(
    val key: String,
    val label: String,
    val selected: Boolean
)

/**
 * A filter group (singleChoice or multipleChoice) received from Flutter.
 */
data class CarScreenFilterGroup(
    val key: String,
    val label: String,
    val type: String, // "singleChoice" or "multipleChoice"
    val selectedLabel: String,
    val children: List<CarScreenFilterChild>
)

/**
 * Union type for filter items sent from Flutter.
 */
sealed class CarScreenFilterItem {
    data class Toggle(val filter: CarScreenFilter) : CarScreenFilterItem()
    data class Group(val group: CarScreenFilterGroup) : CarScreenFilterItem()
}

class EvseManager private constructor() {
    companion object {
        val shared = EvseManager()
        private const val TAG = "EvseManager"
    }

    private val _places = mutableListOf<Evse>()
    private val _listeners = CopyOnWriteArraySet<NearbyEvseListener>()
    private val _modeListeners = CopyOnWriteArraySet<HighwayModeListener>()
    private val _filterListeners = CopyOnWriteArraySet<FilterListener>()
    private val _favouriteListeners = CopyOnWriteArraySet<FavouriteListener>()
    private val _uiStringsListeners = CopyOnWriteArraySet<UiStringsListener>()

    /// Favourite stations received from Flutter for the Favourites tab
    var favouriteEvses: List<Evse> = emptyList()
        private set

    /// Whether highway mode filtering is currently active (speed >= 50 km/h and auto is ON)
    var isHighwayModeActive: Boolean = false
        private set

    /// Highway mode: "off", "auto", or "on"
    var highwayMode: String = "auto"
        private set

    /// Car screen filter items received from Flutter (typed: toggle or group)
    var filterItems: List<CarScreenFilterItem> = emptyList()
        private set

    /// Localised UI chrome strings received from Flutter.
    /// Native code reads these with a hardcoded English fallback.
    private var uiStrings: Map<String, String> = emptyMap()

    /** Get a UI string by key, falling back to the provided default if not yet received from Flutter. */
    fun uiString(key: String, fallback: String): String {
        return uiStrings[key] ?: fallback
    }

    fun updateUiStrings(strings: Map<String, String>) {
        Log.d(TAG, "Updating UI strings - ${strings.size} keys")
        uiStrings = strings
        publishUiStringsChanges()
    }

    fun addUiStringsListener(listener: UiStringsListener) {
        _uiStringsListeners.add(listener)
    }

    fun removeUiStringsListener(listener: UiStringsListener) {
        _uiStringsListeners.remove(listener)
    }

    fun setPlaces(newPlaces: List<Evse>) {
        this._places.clear()
        this._places.addAll(newPlaces)
        this.publishChanges()
    }

    fun updateModeState(isHighwayModeActive: Boolean, highwayMode: String) {
        Log.d(TAG, "Updating mode state - highwayModeActive: $isHighwayModeActive, highwayMode: $highwayMode")

        val modeChanged = this.isHighwayModeActive != isHighwayModeActive
        val highwayModeChanged = this.highwayMode != highwayMode

        this.isHighwayModeActive = isHighwayModeActive
        this.highwayMode = highwayMode

        if (modeChanged || highwayModeChanged) {
            publishModeChanges()
        }
    }

    fun addListener(listener: NearbyEvseListener) {
        _listeners.add(listener)
        listener.onNearbyEvsesChange(_places)
    }

    fun removeListener(listener: NearbyEvseListener) {
        _listeners.remove(listener)
    }

    fun addModeListener(listener: HighwayModeListener) {
        _modeListeners.add(listener)
        listener.onHighwayModeChange(isHighwayModeActive, highwayMode)
    }

    fun removeModeListener(listener: HighwayModeListener) {
        _modeListeners.remove(listener)
    }

    fun updateFilterItems(newItems: List<CarScreenFilterItem>) {
        Log.d(TAG, "Updating filter items - ${newItems.size} definitions")
        filterItems = newItems
        publishFilterChanges()
    }

    /** Find a filter group by key (for sub-screen rendering) */
    fun filterGroup(forKey: String): CarScreenFilterGroup? {
        return filterItems.filterIsInstance<CarScreenFilterItem.Group>()
            .map { it.group }
            .firstOrNull { it.key == forKey }
    }

    fun addFilterListener(listener: FilterListener) {
        _filterListeners.add(listener)
        listener.onFilterItemsChange(filterItems)
    }

    fun removeFilterListener(listener: FilterListener) {
        _filterListeners.remove(listener)
    }

    fun updateFavourites(newFavourites: List<Evse>) {
        Log.d(TAG, "Updating favourites - ${newFavourites.size} stations")
        favouriteEvses = newFavourites
        publishFavouriteChanges()
    }

    fun addFavouriteListener(listener: FavouriteListener) {
        _favouriteListeners.add(listener)
        listener.onFavouritesChange(favouriteEvses)
    }

    fun removeFavouriteListener(listener: FavouriteListener) {
        _favouriteListeners.remove(listener)
    }

    fun clearListeners() {
        _listeners.clear()
        _modeListeners.clear()
        _filterListeners.clear()
        _favouriteListeners.clear()
        _uiStringsListeners.clear()
    }

    private fun publishChanges() {
        _listeners.forEach {
            it.onNearbyEvsesChange(_places)
        }
    }

    private fun publishModeChanges() {
        _modeListeners.forEach {
            it.onHighwayModeChange(isHighwayModeActive, highwayMode)
        }
    }

    private fun publishFilterChanges() {
        _filterListeners.forEach {
            it.onFilterItemsChange(filterItems)
        }
    }

    private fun publishFavouriteChanges() {
        _favouriteListeners.forEach {
            it.onFavouritesChange(favouriteEvses)
        }
    }

    private fun publishUiStringsChanges() {
        _uiStringsListeners.forEach {
            it.onUiStringsChange()
        }
    }
}

interface NearbyEvseListener {
    fun onNearbyEvsesChange(evses: List<Evse>)
}

interface HighwayModeListener {
    fun onHighwayModeChange(isHighwayModeActive: Boolean, highwayMode: String)
}

interface FilterListener {
    fun onFilterItemsChange(filterItems: List<CarScreenFilterItem>)
}

interface FavouriteListener {
    fun onFavouritesChange(favourites: List<Evse>)
}

/**
 * Notified when localised UI strings sent by Flutter change (locale switch,
 * Phrase OTA update). Screens should `invalidate()` to re-render with the
 * updated labels.
 */
interface UiStringsListener {
    fun onUiStringsChange()
}

/**
 * Status of an EVSE location based on charger availability.
 */
enum class EvseStatus(val markerColor: CarColor) {
    AVAILABLE(CarColor.GREEN),
    CHARGING(CarColor.BLUE),
    UNKNOWN(CarColor.RED)
}

data class Evse(
    val id: String,
    val latitude: Double,
    val longitude: Double,

    // Raw counts for marker color logic only
    val availableCount: Int,
    val totalCount: Int,
    val chargingCount: Int = 0,

    // Pre-formatted display strings from Flutter (native renders these as-is)
    val title: String,
    val subtitle: String,
    val summary: String,
    val detailSubtitle: String,
    val detailSummary: String,

    // Detail screen data
    val connectorRows: List<Map<String, String>> = emptyList(),
    val priceText: String = "",
    val addressText: String = "",

    // Favourite state
    val isFavourite: Boolean = false,
    val favouriteButtonLabel: String = ""
) {
    /**
     * Computed status based on availability and charging counts.
     */
    val status: EvseStatus
        get() = when {
            availableCount > 0 -> EvseStatus.AVAILABLE
            chargingCount > 0 -> EvseStatus.CHARGING
            else -> EvseStatus.UNKNOWN
        }
}

fun Evse.navigateWithCarContext(carContext: CarContext): Boolean {
    // Use Android Auto's built-in navigation
    val uri = Uri.parse("geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encode(title)})")
    val intent = Intent(CarContext.ACTION_NAVIGATE, uri)

    return try {
        carContext.startCarApp(intent)
        true
    } catch (e: HostException) {
        // If car navigation fails, offer to navigate on phone
        false
    }
}

/**
 * Calculate distance from a given location to this EVSE with proper unit formatting
 * based on system locale (metric vs imperial).
 */
fun Evse.calculateDistance(carContext: CarContext, currentLocation: Location?): Distance {
    val distanceInMeters = if (currentLocation != null) {
        val evseLocation = Location("evse").apply {
            latitude = this@calculateDistance.latitude
            longitude = this@calculateDistance.longitude
        }
        currentLocation.distanceTo(evseLocation).toDouble()
    } else {
        0.0
    }

    // Detect if system uses metric or imperial based on locale's measurement system
    val usesMetric = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        // API 28+: Use LocaleData which properly handles US, UK, and metric locales
        val locale = carContext.resources.configuration.locales[0]
        val measurementSystem = LocaleData.getMeasurementSystem(ULocale.forLocale(locale))
        measurementSystem == LocaleData.MeasurementSystem.SI
    } else {
        // Fallback for API 23-27: Check country code
        // Countries using imperial/miles: US, GB (+ territories), LR, MM
        val imperialCountries = listOf(
            "US", "GB", "LR", "MM",
            // UK territories that use miles
            "KY", "VG", "BM", "MS", "TC", "AI", "FK", "GI", "SH", "GG", "JE", "IM"
        )
        carContext.resources.configuration.locales[0].country !in imperialCountries
    }

    return if (usesMetric) {
        // Metric: show meters or kilometers
        if (distanceInMeters < 1000) {
            // Short distance: meters (no decimals enforced by system)
            Distance.create(distanceInMeters, Distance.UNIT_METERS)
        } else {
            // Long distance: kilometers with 1 decimal
            val distanceInKm = distanceInMeters / 1000.0
            Distance.create(distanceInKm, Distance.UNIT_KILOMETERS_P1)
        }
    } else {
        // Imperial: show yards or miles
        val distanceInYards = distanceInMeters * 1.09361

        if (distanceInYards < 1760) {
            // Short distance: yards (no decimals enforced by system)
            Distance.create(distanceInYards, Distance.UNIT_YARDS)
        } else {
            // Long distance: miles with 1 decimal
            val distanceInMiles = distanceInYards / 1760.0
            Distance.create(distanceInMiles, Distance.UNIT_MILES_P1)
        }
    }
}
