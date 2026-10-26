package com.eflux.ev.auto

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Handles Android Auto method channel communication
 */
class AndroidAutoProcessor(private val flutterEngine: FlutterEngine) {

    companion object {
        // Channel name
        private const val CHANNEL_NAME = "io.e-flux.mobile/auto"

        // Method names
        private const val SEND_LOCATIONS_METHOD = "sendLocations"
        private const val SEND_FILTER_DEFINITIONS_METHOD = "sendFilterDefinitions"
        private const val SEND_FAVOURITES_METHOD = "sendFavourites"
        private const val SEND_UI_STRINGS_METHOD = "sendUiStrings"
        private const val GET_CAR_SESSION_STATE = "getCarSessionState"
        private const val CAR_SYSTEM_STATE_CHANGED = "carSystemStateChanged"
        private const val LOCATION_PERMISSION_CHANGED = "locationPermissionChanged"
        private const val TOGGLE_HIGHWAY_MODE = "toggleHighwayMode"
        private const val TOGGLE_CAR_SCREEN_FILTER = "toggleCarScreenFilter"
        private const val TOGGLE_FAVOURITE = "toggleFavourite"

        // Response messages
        private const val LOCATIONS_RECEIVED = "Locations received"

        // Log tag
        private const val TAG = "AndroidAutoProcessor"

        // Singleton instance for access from Android Auto service
        @Volatile
        private var instance: AndroidAutoProcessor? = null

        fun getInstance(): AndroidAutoProcessor? = instance

        /**
         * Clears the singleton if it is backed by the given engine. Called when
         * that engine is being destroyed so a stale processor (whose channel is
         * dead) can't shadow a replacement engine's processor.
         */
        fun clearInstance(engine: FlutterEngine) {
            if (instance?.flutterEngine === engine) {
                Log.d(TAG, "Clearing Android Auto processor for destroyed engine")
                instance = null
            }
        }
    }

    private val methodChannel: MethodChannel

    init {
        instance = this

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                SEND_LOCATIONS_METHOD -> {
                    handleSendLocations(call.arguments, result)
                }
                SEND_FILTER_DEFINITIONS_METHOD -> {
                    handleSendFilterDefinitions(call.arguments, result)
                }
                SEND_FAVOURITES_METHOD -> {
                    handleSendFavourites(call.arguments, result)
                }
                SEND_UI_STRINGS_METHOD -> {
                    handleSendUiStrings(call.arguments, result)
                }
                GET_CAR_SESSION_STATE -> {
                    // Dart pulls this on startup: the buffered push can be lost
                    // when it fires before the Dart handler is registered.
                    result.success(PlacesSession.isSessionActive)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Check if Android Auto session was already active before the app started
        // This handles the case where Android Auto opens before the main app
        if (PlacesSession.isSessionActive) {
            Log.d(TAG, "Android Auto session was already active - notifying Flutter")
            notifyCarSystemStateChanged(true)
        }
    }

    private fun handleSendLocations(arguments: Any?, result: MethodChannel.Result) {
        // Format: { locations: [...], isHighwayModeActive: bool, highwayMode: string }
        val data = arguments as? Map<*, *>
        if (data == null) {
            Log.e(TAG, "ERROR - Invalid data format")
            result.error("INVALID_ARGUMENTS", "Invalid data format", null)
            return
        }

        @Suppress("UNCHECKED_CAST")
        val locations = data["locations"] as? List<Map<String, Any>>
        if (locations == null) {
            Log.e(TAG, "ERROR - Invalid locations data")
            result.error("INVALID_ARGUMENTS", "Invalid locations data", null)
            return
        }

        // Parse mode state
        val isHighwayModeActive = data["isHighwayModeActive"] as? Boolean ?: false
        val highwayMode = data["highwayMode"] as? String ?: "auto"

        Log.d(TAG, "Received ${locations.size} locations from Flutter (highwayModeActive: $isHighwayModeActive, highwayMode: $highwayMode)")

        val resultLocations = locations.mapNotNull { locationMap ->
            try {
                // Parse connector rows
                @Suppress("UNCHECKED_CAST")
                val rawConnectorRows = locationMap["connectorRows"] as? List<Map<String, String>> ?: emptyList()

                Evse(
                    id = locationMap["locationId"] as? String ?: "",
                    latitude = locationMap["lat"] as Double,
                    longitude = locationMap["lng"] as Double,
                    availableCount = locationMap["availableCount"] as? Int ?: 0,
                    totalCount = locationMap["totalCount"] as? Int ?: 0,
                    chargingCount = locationMap["chargingCount"] as? Int ?: 0,
                    title = locationMap["title"] as? String ?: "",
                    subtitle = locationMap["subtitle"] as? String ?: "",
                    summary = locationMap["summary"] as? String ?: "",
                    detailSubtitle = locationMap["detailSubtitle"] as? String ?: "",
                    detailSummary = locationMap["detailSummary"] as? String ?: "",
                    connectorRows = rawConnectorRows,
                    priceText = locationMap["priceText"] as? String ?: "",
                    addressText = locationMap["addressText"] as? String ?: "",
                    isFavourite = locationMap["isFavourite"] as? Boolean ?: false,
                    favouriteButtonLabel = locationMap["favouriteButtonLabel"] as? String ?: ""
                ).also {
                    Log.d(TAG, "EVSE: ${it.title} - ${it.addressText}")
                }
            } catch (e: Exception) {
                Log.w(TAG, "WARNING - Invalid location data: $locationMap", e)
                null
            }
        }

        Log.d(TAG, "Parsed ${resultLocations.size} valid locations")

        // Update mode state first
        EvseManager.shared.updateModeState(isHighwayModeActive, highwayMode)

        // Update places
        EvseManager.shared.setPlaces(resultLocations)
        result.success(LOCATIONS_RECEIVED)
    }

    fun notifyCarSystemStateChanged(isActive: Boolean) {
        val stateDescription = if (isActive) "active" else "inactive"
        Log.d(TAG, "Notifying Flutter that car system state changed to: $stateDescription")

        methodChannel.invokeMethod(CAR_SYSTEM_STATE_CHANGED, isActive, object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.d(TAG, "Successfully notified Flutter of car system state change to: $stateDescription")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "ERROR - Failed to notify Flutter: $errorMessage")
            }

            override fun notImplemented() {
                Log.e(TAG, "ERROR - Method not implemented in Flutter")
            }
        })
    }

    fun notifyLocationPermissionChanged() {
        Log.d(TAG, "Notifying Flutter that location permission changed")

        methodChannel.invokeMethod(LOCATION_PERMISSION_CHANGED, null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.d(TAG, "Successfully notified Flutter of location permission change")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "ERROR - Failed to notify location permission change: $errorMessage")
            }

            override fun notImplemented() {
                Log.e(TAG, "ERROR - Location permission change method not implemented in Flutter")
            }
        })
    }

    fun toggleHighwayMode() {
        Log.d(TAG, "Requesting Flutter to toggle highway mode")

        methodChannel.invokeMethod(TOGGLE_HIGHWAY_MODE, null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.d(TAG, "Successfully requested highway mode toggle")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "ERROR - Failed to toggle highway mode: $errorMessage")
            }

            override fun notImplemented() {
                Log.e(TAG, "ERROR - Toggle highway mode method not implemented in Flutter")
            }
        })
    }

    fun toggleFavourite(locationId: String) {
        Log.d(TAG, "Requesting Flutter to toggle favourite for $locationId")

        methodChannel.invokeMethod(TOGGLE_FAVOURITE, mapOf(
            "locationId" to locationId
        ), object : MethodChannel.Result {
            override fun success(result: Any?) {
                // Note: OK ack is immediate; the favourite toggle completes asynchronously on the Flutter side
                Log.d(TAG, "Favourite toggle request acknowledged")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "ERROR - Failed to toggle favourite: $errorMessage")
            }

            override fun notImplemented() {
                Log.e(TAG, "ERROR - Toggle favourite method not implemented in Flutter")
            }
        })
    }

    fun toggleCarScreenFilter(key: String, enabled: Boolean) {
        Log.d(TAG, "Requesting Flutter to toggle filter $key to $enabled")

        methodChannel.invokeMethod(TOGGLE_CAR_SCREEN_FILTER, mapOf(
            "key" to key,
            "enabled" to enabled
        ), object : MethodChannel.Result {
            override fun success(result: Any?) {
                Log.d(TAG, "Successfully requested filter toggle")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(TAG, "ERROR - Failed to toggle filter: $errorMessage")
            }

            override fun notImplemented() {
                Log.e(TAG, "ERROR - Toggle filter method not implemented in Flutter")
            }
        })
    }

    @Suppress("UNCHECKED_CAST")
    private fun handleSendUiStrings(arguments: Any?, result: MethodChannel.Result) {
        val strings = arguments as? Map<String, String>
        if (strings == null) {
            Log.e(TAG, "ERROR - Invalid UI strings data")
            result.error("INVALID_ARGUMENTS", "Invalid UI strings data", null)
            return
        }

        Log.d(TAG, "Received ${strings.size} UI strings from Flutter")

        EvseManager.shared.updateUiStrings(strings)
        result.success("UI strings received")
    }

    @Suppress("UNCHECKED_CAST")
    private fun handleSendFilterDefinitions(arguments: Any?, result: MethodChannel.Result) {
        val data = arguments as? Map<*, *>
        if (data == null) {
            Log.e(TAG, "ERROR - Invalid filter definitions data format")
            result.error("INVALID_ARGUMENTS", "Invalid filter definitions data", null)
            return
        }

        val filterList = data["filters"] as? List<Map<String, Any>>
        if (filterList == null) {
            Log.e(TAG, "ERROR - Invalid filters list")
            result.error("INVALID_ARGUMENTS", "Invalid filters list", null)
            return
        }

        val items = filterList.mapNotNull { dict ->
            val key = dict["key"] as? String ?: return@mapNotNull null
            val label = dict["label"] as? String ?: return@mapNotNull null
            val type = dict["type"] as? String ?: return@mapNotNull null

            when (type) {
                "singleChoice", "multipleChoice" -> {
                    val selectedLabel = dict["selectedLabel"] as? String ?: ""
                    val childDicts = dict["children"] as? List<Map<String, Any>> ?: emptyList()
                    val children = childDicts.mapNotNull { childDict ->
                        val childKey = childDict["key"] as? String ?: return@mapNotNull null
                        val childLabel = childDict["label"] as? String ?: return@mapNotNull null
                        val selected = childDict["selected"] as? Boolean ?: return@mapNotNull null
                        CarScreenFilterChild(key = childKey, label = childLabel, selected = selected)
                    }
                    CarScreenFilterItem.Group(CarScreenFilterGroup(
                        key = key, label = label, type = type,
                        selectedLabel = selectedLabel, children = children
                    ))
                }
                else -> { // "toggle"
                    val enabled = dict["enabled"] as? Boolean ?: false
                    CarScreenFilterItem.Toggle(CarScreenFilter(key = key, label = label, enabled = enabled))
                }
            }
        }

        Log.d(TAG, "Received ${items.size} filter items from Flutter")

        EvseManager.shared.updateFilterItems(items)
        result.success("Filter definitions received")
    }

    @Suppress("UNCHECKED_CAST")
    private fun handleSendFavourites(arguments: Any?, result: MethodChannel.Result) {
        val data = arguments as? Map<*, *>
        if (data == null) {
            Log.e(TAG, "ERROR - Invalid favourites data format")
            result.error("INVALID_ARGUMENTS", "Invalid favourites data", null)
            return
        }

        val favouritesList = data["favourites"] as? List<Map<String, Any>>
        if (favouritesList == null) {
            Log.e(TAG, "ERROR - Invalid favourites list")
            result.error("INVALID_ARGUMENTS", "Invalid favourites list", null)
            return
        }

        val evses = favouritesList.mapNotNull { dict ->
            try {
                @Suppress("UNCHECKED_CAST")
                val rawConnectorRows = dict["connectorRows"] as? List<Map<String, String>> ?: emptyList()
                Evse(
                    id = dict["locationId"] as? String ?: "",
                    latitude = dict["lat"] as Double,
                    longitude = dict["lng"] as Double,
                    availableCount = dict["availableCount"] as? Int ?: 0,
                    totalCount = dict["totalCount"] as? Int ?: 0,
                    chargingCount = dict["chargingCount"] as? Int ?: 0,
                    title = dict["title"] as? String ?: "",
                    subtitle = dict["subtitle"] as? String ?: "",
                    summary = dict["summary"] as? String ?: "",
                    detailSubtitle = dict["detailSubtitle"] as? String ?: "",
                    detailSummary = dict["detailSummary"] as? String ?: "",
                    connectorRows = rawConnectorRows,
                    priceText = dict["priceText"] as? String ?: "",
                    addressText = dict["addressText"] as? String ?: "",
                    isFavourite = dict["isFavourite"] as? Boolean ?: true,
                    favouriteButtonLabel = dict["favouriteButtonLabel"] as? String ?: ""
                )
            } catch (e: Exception) {
                Log.w(TAG, "WARNING - Invalid favourite data: $dict", e)
                null
            }
        }

        Log.d(TAG, "Received ${evses.size} favourites from Flutter")
        EvseManager.shared.updateFavourites(evses)
        result.success("Favourites received")
    }
}
