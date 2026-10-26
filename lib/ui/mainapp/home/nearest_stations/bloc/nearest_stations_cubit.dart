import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import 'dart:ui';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_repository.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/car_screen_formatting.dart' as car_fmt;
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'nearest_stations_state.dart';
part 'nearest_stations_cubit.freezed.dart';

enum NearestStationsMode {
  highway, // Speed-based mode with 50kW filter, heading, compass, road name
  nearest, // Map-based mode with map filters, no speed check
  carScreen, // CarPlay/Android Auto hybrid mode: auto-switches based on speed, always shows stations
}

/// Highway mode setting for CarPlay/Android Auto.
/// Controls when highway filtering (50kW min, heading-based search) is applied.
enum HighwayMode {
  off,  // Never apply highway filtering
  auto, // Apply when speed >= 50 km/h (default)
  on,   // Always apply highway filtering regardless of speed
}

/// Internal config wrapper that includes UI-specific flags
class _FetchConfig {
  final NearestStationsFilterConfig filterConfig;
  final bool shouldFetchRoadName;

  _FetchConfig({required this.filterConfig, required this.shouldFetchRoadName});
}

class NearestStationsConfig {
  final int stationLimit;
  final int? minPowerKw;
  final NearestStationsMode mode;
  final Map<String, dynamic>? mapFilters; // For nearest mode: filters from MapBloc
  final HighwayMode highwayMode; // For carScreen mode: off / auto / on
  final int minUpdateIntervalSeconds; // Minimum time between updates

  NearestStationsConfig({
    this.stationLimit = 10,
    this.minPowerKw,
    required this.mode,
    this.mapFilters,
    this.highwayMode = HighwayMode.auto,
    this.minUpdateIntervalSeconds = 60,
  });
}

@injectable
class NearestStationsCubit extends Cubit<NearestStationsState> {
  final NearestStationsRepository _nearestStationsRepository;
  final LocationBloc _locationBloc;
  final int _stationLimit;
  final int? _minPowerKw;
  final NearestStationsMode _mode;
  final Map<String, dynamic>? _mapFilters;
  StreamSubscription<LocationState>? _locationSubscription;
  UserLocation? _lastLocation;
  DateTime? _lastFetchTime;
  bool _isFetching = false;

  // For carScreen mode: highway mode setting (off / auto / on)
  HighwayMode _highwayMode;

  // For carScreen mode: user-toggled filters from the car screen UI
  Map<String, dynamic>? _carScreenFilters;

  // For carScreen mode: set of favourite location IDs (passed from CarScreen)
  Set<String> _favouriteLocationIds = {};

  // Threshold for location updates (150m)
  static const double _locationThresholdMeters = 150.0;

  // Minimum time between updates
  final int _minUpdateIntervalSeconds;

  // Highway mode speed threshold (50 km/h)
  static const double _highwaySpeedThresholdKmh = 50.0;

  NearestStationsCubit(this._nearestStationsRepository, this._locationBloc, @factoryParam NearestStationsConfig? config)
    : _stationLimit = config?.stationLimit ?? 10,
      _minPowerKw = config?.minPowerKw,
      _mode = config?.mode ?? NearestStationsMode.highway,
      _mapFilters = config?.mapFilters,
      _highwayMode = config?.highwayMode ?? HighwayMode.auto,
      _minUpdateIntervalSeconds = config?.minUpdateIntervalSeconds ?? 30,
      super(NearestStationsState(stations: [], mode: config?.mode ?? NearestStationsMode.highway)) {
    developer.log(
      'NearestStationsCubit: Initializing (limit: $_stationLimit, minPower: $_minPowerKw kW, mode: $_mode, highwayMode: $_highwayMode)',
      name: 'NearestStations',
    );
    _setupLocationListener();
  }

  /// Highway mode setting (for carScreen mode)
  HighwayMode get highwayMode => _highwayMode;

  /// Latest Phrase-wrapped AppLocalizations, pushed in from the widget tree
  /// via CarScreen. Needed so car-screen formatting picks up Phrase OTA
  /// updates — lookupAppLocalizations returns baked-in ARB strings only.
  AppLocalizations? _localizations;

  void updateLocalizations(AppLocalizations l10n) {
    _localizations = l10n;
  }

  AppLocalizations _fallbackLocalizations() {
    final locale = PlatformDispatcher.instance.locale;
    if (AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return lookupAppLocalizations(locale);
    }
    return lookupAppLocalizations(const Locale('en'));
  }

  /// Update the set of favourite location IDs (for carScreen mode).
  /// Called by CarScreen when FavouritesCubit state changes.
  void setFavouriteLocationIds(Set<String> ids) {
    _favouriteLocationIds = ids;
  }

  /// Update car screen filters (for carScreen mode filter toggles).
  /// Accepts a map of API filter parameters (same format as ChargingLocationFilters.apiMap).
  /// Triggers a re-fetch with the new filters applied.
  void setCarScreenFilters(Map<String, dynamic>? filters) {
    if (_mode != NearestStationsMode.carScreen) {
      return;
    }

    developer.log(
      'NearestStationsCubit: Setting car screen filters: $filters',
      name: 'NearestStations',
    );
    _carScreenFilters = filters;

    // Re-fetch with updated filters
    _lastLocation = null;
    _lastFetchTime = null;

    final currentState = _locationBloc.state;
    if (currentState is LocationProvided) {
      _handleLocationUpdate(currentState.userLocation);
    }
  }

  /// Update the highway mode setting (for carScreen mode)
  void setHighwayMode(HighwayMode mode) {
    if (_mode != NearestStationsMode.carScreen) {
      developer.log(
        'NearestStationsCubit: setHighwayMode called but mode is $_mode, ignoring',
        name: 'NearestStations',
      );
      return;
    }

    developer.log(
      'NearestStationsCubit: Setting highwayMode to $mode',
      name: 'NearestStations',
    );
    _highwayMode = mode;

    // Re-fetch with updated setting by resetting last location and fetch time
    _lastLocation = null;
    _lastFetchTime = null;

    // Trigger a refresh with the current location
    final currentState = _locationBloc.state;
    if (currentState is LocationProvided) {
      _handleLocationUpdate(currentState.userLocation);
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }

  void _setupLocationListener() {
    developer.log('NearestStationsCubit: Setting up location listener', name: 'NearestStations');

    _locationSubscription = _locationBloc.stream.listen((locationState) {
      switch (locationState) {
        case LocationProvided(:final userLocation):
          developer.log(
            'NearestStationsCubit: Location received - Lat: ${userLocation.latitude}, Lng: ${userLocation.longitude}, '
            'Speed: ${userLocation.speed.toStringAsFixed(1)} km/h, Heading: ${userLocation.heading?.toStringAsFixed(1)}°',
            name: 'NearestStations',
          );
          _handleLocationUpdate(userLocation);
          break;
        case ServiceDisabled():
          developer.log('NearestStationsCubit: Location service is disabled', name: 'NearestStations');
          emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Location service is disabled'))));
          break;
        case PermissionDenied():
          developer.log('NearestStationsCubit: Location permission denied', name: 'NearestStations');
          emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Location permission denied'))));
          break;
        default:
          // Initial or PermissionGranted states - no action needed
          break;
      }
    });

    // Check current state
    final currentState = _locationBloc.state;
    if (currentState is LocationProvided) {
      developer.log('NearestStationsCubit: Using current location from LocationBloc', name: 'NearestStations');
      _handleLocationUpdate(currentState.userLocation);
    }
  }

  void _handleLocationUpdate(UserLocation location) {
    // Skip if a fetch is already in progress
    if (_isFetching) {
      developer.log(
        'NearestStationsCubit: Skipping location update - fetch already in progress',
        name: 'NearestStations',
      );
      return;
    }

    // Check if we've moved at least 150m AND waited at least 30 seconds
    if (_lastLocation != null && _lastFetchTime != null) {
      final distance = _lastLocation!.distanceToOtherLocation(location);
      final secondsSinceLastFetch = DateTime.now().difference(_lastFetchTime!).inSeconds;

      // Both conditions must be met: moved enough AND waited long enough
      if (distance < _locationThresholdMeters || secondsSinceLastFetch < _minUpdateIntervalSeconds) {
        developer.log(
          'NearestStationsCubit: Update skipped - distance: ${distance.toStringAsFixed(0)}m (min: ${_locationThresholdMeters}m), '
          'time: ${secondsSinceLastFetch}s (min: ${_minUpdateIntervalSeconds}s), '
          'speed: ${location.speed.toStringAsFixed(1)} km/h',
          name: 'NearestStations',
        );
        return;
      }
    }

    // Update last location and fetch time
    _lastLocation = location;
    _lastFetchTime = DateTime.now();

    // In nearest mode, always fetch stations regardless of speed
    if (_mode == NearestStationsMode.nearest) {
      developer.log('NearestStationsCubit: NEAREST MODE - Always showing stations', name: 'NearestStations');
      _fetchNearestStations(location, limit: _stationLimit, isLowSpeed: false);
      return;
    }

    // In carScreen mode (CarPlay/Android Auto): hybrid behavior
    if (_mode == NearestStationsMode.carScreen) {
      final isHighSpeed = location.speed >= _highwaySpeedThresholdKmh;
      // Highway mode active depends on the highway mode setting:
      //   off  → never active
      //   auto → active when speed >= 50 km/h
      //   on   → always active (for traffic jams where driver still wants highway stations)
      final isHighwayModeActive = switch (_highwayMode) {
        HighwayMode.off => false,
        HighwayMode.auto => isHighSpeed,
        HighwayMode.on => true,
      };

      developer.log(
        'NearestStationsCubit: CAR SCREEN MODE - Speed: ${location.speed.toStringAsFixed(1)} km/h, '
        'HighwayMode: $_highwayMode, HighwayActive: $isHighwayModeActive',
        name: 'NearestStations',
      );

      // Always fetch stations, but with different filters based on highway mode active state
      _fetchNearestStations(location, limit: _stationLimit, isLowSpeed: false, isHighwayModeActive: isHighwayModeActive);
      return;
    }

    assert(_mode == NearestStationsMode.highway, 'NearestStationsCubit: Mode is not highway');

    // Highway mode: check speed threshold
    final isHighSpeed = location.speed >= _highwaySpeedThresholdKmh;
    if (isHighSpeed) {
      developer.log(
        'NearestStationsCubit: HIGHWAY MODE ACTIVATED - Speed: ${location.speed.toStringAsFixed(1)} km/h, Heading: ${location.heading?.toStringAsFixed(1)}°',
        name: 'NearestStations',
      );
    } else {
      developer.log(
        'NearestStationsCubit: Low speed mode - Speed: ${location.speed.toStringAsFixed(1)} km/h',
        name: 'NearestStations',
      );
    }

    // Skip fetching in low-speed mode (highway mode only)
    if (!isHighSpeed) {
      developer.log('NearestStationsCubit: Skipping fetch in low-speed mode', name: 'NearestStations');
      emit(
        NearestStationsState(
          stations: [],
          userLocation: location,
          isLowSpeed: true,
          mode: _mode,
          flow: UIFlow.established(),
        ),
      );
      return;
    }

    // Fetch stations in highway mode
    _fetchNearestStations(location, limit: _stationLimit, isLowSpeed: false);
  }

  /// Build fetch configuration based on current mode and location
  _FetchConfig _buildFetchConfig(UserLocation location, {bool? isHighwayModeActive}) {
    switch (_mode) {
      case NearestStationsMode.nearest:
        // Nearest mode: use map filters, no heading, no power filter override
        return _FetchConfig(
          filterConfig: NearestStationsFilterConfig(additionalFilters: _mapFilters),
          shouldFetchRoadName: false,
        );

      case NearestStationsMode.highway:
        // Highway mode: 50kW filter, heading-based, available only
        final isHighSpeed = location.speed >= _highwaySpeedThresholdKmh;
        return _FetchConfig(
          filterConfig: NearestStationsFilterConfig(
            minPowerKw: _minPowerKw ?? (isHighSpeed ? 50 : null),
            availableOnly: true,
            heading: isHighSpeed ? location.heading : null,
          ),
          shouldFetchRoadName: true,
        );

      case NearestStationsMode.carScreen:
        // CarScreen mode (CarPlay/Android Auto): hybrid behavior
        // When highway mode is active: use highway filters (50kW, directional, available-only)
        // When highway mode is inactive: use nearest filters (all stations)
        // Car screen user filters (from filter UI) are always stacked on top
        final highwayActive = isHighwayModeActive ?? false;
        if (highwayActive) {
          // Only include heading when valid (>= 0); stationary users have -1
          final heading = (location.heading != null && location.heading! >= 0) ? location.heading : null;
          return _FetchConfig(
            filterConfig: NearestStationsFilterConfig(
              minPowerKw: 50,
              availableOnly: true,
              heading: heading,
              additionalFilters: _carScreenFilters,
            ),
            shouldFetchRoadName: false,
          );
        } else {
          return _FetchConfig(
            filterConfig: NearestStationsFilterConfig(additionalFilters: _carScreenFilters),
            shouldFetchRoadName: false,
          );
        }
    }
  }

  Future<String?> _fetchRoadName(UserLocation location) async {
    try {
      developer.log(
        'NearestStationsCubit: Fetching road name for (${location.latitude}, ${location.longitude})',
        name: 'NearestStations',
      );

      final placemarks = await Geocoding().placemarkFromCoordinates(location.latitude, location.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Use thoroughfare which contains the street name without house number
        // Fall back to street if thoroughfare is not available
        final roadName = placemark.thoroughfare ?? placemark.street;

        developer.log(
          'NearestStationsCubit: Road name found: $roadName (thoroughfare: ${placemark.thoroughfare}, street: ${placemark.street})',
          name: 'NearestStations',
        );

        return roadName;
      }
    } catch (e) {
      developer.log('NearestStationsCubit: Error fetching road name', name: 'NearestStations', error: e);
    }
    return null;
  }

  Future<void> _fetchNearestStations(
    UserLocation location, {
    int limit = 10,
    bool isLowSpeed = false,
    bool? isHighwayModeActive,
  }) async {
    // Set fetching flag
    _isFetching = true;

    try {
      // Build fetch configuration based on mode
      final fetchConfig = _buildFetchConfig(location, isHighwayModeActive: isHighwayModeActive);

      developer.log(
        'NearestStationsCubit: Fetching $limit stations (mode: $_mode, '
        'minPower: ${fetchConfig.filterConfig.minPowerKw} kW, heading: ${fetchConfig.filterConfig.heading}°, '
        'speed: ${location.speed.toStringAsFixed(1)} km/h)',
        name: 'NearestStations',
      );

      // Check if cubit is closed before emitting
      if (isClosed) {
        return;
      }

      emit(state.copyWith(flow: UIFlow.loading()));

      try {
        final locationsFuture = _nearestStationsRepository.getNearestChargingLocations(
          location: location,
          filterConfig: fetchConfig.filterConfig,
          limit: limit,
        );
        final roadNameFuture = fetchConfig.shouldFetchRoadName ? _fetchRoadName(location) : Future.value(null);

        final locationsResponse = await locationsFuture;
        final roadName = await roadNameFuture;

        // Check again after async operations complete
        if (isClosed) {
          return;
        }

        // Filter EVSEs by minimum power in highway mode only
        // Note: The backend returns all EVSEs in a location when ANY EVSE matches the minPower filter.
        // This is due to Elasticsearch nested query behavior - it matches entire documents, not individual nested objects.
        // Therefore, we must filter client-side to exclude EVSEs that don't meet the power requirement.
        final filteredLocations = _filterLocationsByMinPower(
          locationsResponse.data,
          fetchConfig.filterConfig.minPowerKw,
        );

        developer.log(
          'NearestStationsCubit: Successfully fetched ${locationsResponse.data.length} stations (${filteredLocations.length} after filtering), road: $roadName',
          name: 'NearestStations',
        );

        emit(
          NearestStationsState(
            stations: filteredLocations,
            userLocation: location,
            currentRoadName: roadName,
            isLowSpeed: isLowSpeed,
            mode: _mode,
            flow: UIFlow.established(),
            isHighwayModeActive: isHighwayModeActive ?? false,
          ),
        );
      } on RMApiError catch (e) {
        // Check if closed before emitting error
        if (isClosed) {
          return;
        }
        developer.log(
          'NearestStationsCubit: API error fetching stations',
          name: 'NearestStations',
          error: e.toString(),
        );
        emit(state.copyWith(flow: UIFlow.error(e)));
      } catch (e, stackTrace) {
        // Check if closed before emitting error
        if (isClosed) {
          return;
        }
        developer.log(
          'NearestStationsCubit: Unexpected error fetching stations',
          name: 'NearestStations',
          error: e,
          stackTrace: stackTrace,
        );
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to fetch nearby stations'))));
      }
    } finally {
      // Always reset fetching flag
      _isFetching = false;
    }
  }

  /// Manual refresh of stations
  Future<void> refresh() async {
    developer.log('NearestStationsCubit: Manual refresh requested', name: 'NearestStations');

    // Get current location from LocationBloc
    final currentState = _locationBloc.state;

    if (currentState is LocationProvided) {
      developer.log(
        'NearestStationsCubit: Refreshing with location: ${currentState.userLocation.latitude}, ${currentState.userLocation.longitude}',
        name: 'NearestStations',
      );
      // Force update by resetting last location and fetch time
      _lastLocation = null;
      _lastFetchTime = null;
      _handleLocationUpdate(currentState.userLocation);
    } else {
      developer.log(
        'NearestStationsCubit: No location available for refresh. Current state: $currentState',
        name: 'NearestStations',
      );

      // Request LocationBloc to check status
      _locationBloc.add(const LocationEvent.checkServiceStatus());
    }
  }

  /// Get formatted locations for CarPlay/Android Auto.
  ///
  /// All user-facing display strings are pre-formatted here in Flutter (where l10n lives).
  /// Native code is a thin rendering layer — it receives display-ready strings and just
  /// puts them in the right template fields. The one exception is distance, which stays
  /// native because it updates in real-time as the user moves.
  List<Map<String, dynamic>> getFormattedLocationsForCarScreen({bool isLoggedIn = true}) {
    return state.stations.map((location) {
      // --- Raw data for native non-display logic (marker colors, map positioning) ---

      // Count available, charging, and total EVSEs
      int availableCount = 0;
      int chargingCount = 0;
      int totalCount = location.evses.length;
      for (final evse in location.evses) {
        if (evse.chargingPortAvailability == ChargingPortAvailability.available) {
          availableCount++;
        } else if (evse.chargingPortAvailability == ChargingPortAvailability.charging) {
          chargingCount++;
        }
      }

      // Max power from ALL EVSEs (not just available ones)
      final maxPowerKw = location.evses.fold<double>(0, (max, evse) {
        final power = evse.maxPower ?? 0;
        return power > max ? power : max;
      });

      // --- Pre-formatted display strings ---

      final l10n = _localizations ?? _fallbackLocalizations();

      final title = location.subOperator?.name ?? location.name ?? location.id ?? '';
      final powerText = '${maxPowerKw.toInt()} kW';
      final availabilityText = l10n.carScreenAvailabilityCount(availableCount, totalCount);

      // Extract primary kWh price from the first connector with tariff data
      final priceText = car_fmt.extractPriceText(location, l10n);

      // Connector breakdown rows grouped by connector standard
      final connectorRows = car_fmt.buildConnectorRows(location, l10n);

      // Address text for detail screen - include city if available
      final city = location.city;
      final address = location.address ?? '';
      final addressText = (city != null && city.isNotEmpty && !address.contains(city)) ? '$address, $city' : address;

      // List view strings
      // subtitle: "Prinsengracht 123, Amsterdam · 22 kW - 3/4 available"
      final availabilityInfo = '$powerText - $availabilityText';
      final subtitle = addressText.isNotEmpty ? '$addressText · $availabilityInfo' : availabilityInfo;
      // summary: "€0.45/kWh" (distance is prepended natively)
      final summary = priceText;

      // Detail view strings
      // detailSubtitle: "3/4 available - 22 kW"
      final detailSubtitle = '$availabilityText - $powerText';
      // detailSummary: address
      final detailSummary = location.address ?? '';

      // Favourite state
      final locationId = location.id ?? '';
      final isFavourite = _favouriteLocationIds.contains(locationId);
      final favouriteButtonLabel = isLoggedIn ? (isFavourite ? l10n.removeFromFavourites : l10n.addToFavourites) : '';

      return {
        // Coordinates for map positioning
        "lat": location.geoLocation?.coordinates[1] ?? 0,
        "lng": location.geoLocation?.coordinates[0] ?? 0,
        // IDs
        "locationId": locationId,
        "evseId": location.evses.isNotEmpty ? (location.evses.first.evseId ?? '') : '',
        // Raw counts for marker color logic only
        "availableCount": availableCount,
        "chargingCount": chargingCount,
        "totalCount": totalCount,
        // Pre-formatted display strings — native renders these as-is
        "title": title,
        "subtitle": subtitle,
        "summary": summary,
        "detailSubtitle": detailSubtitle,
        "detailSummary": detailSummary,
        // Detail screen data
        "connectorRows": connectorRows,
        "priceText": priceText,
        "addressText": addressText,
        // Favourite state
        "isFavourite": isFavourite,
        "favouriteButtonLabel": favouriteButtonLabel,
      };
    }).toList();
  }

  /// Filter locations to only include EVSEs that meet the minimum power requirement.
  ///
  /// This is necessary because the backend Elasticsearch query returns entire locations
  /// when ANY EVSE matches the minPower filter, including all other EVSEs at that location
  /// (even those below the power threshold). This is standard Elasticsearch nested query behavior.
  ///
  /// Returns locations with filtered EVSEs. Locations with no EVSEs after filtering are excluded.
  List<MapLocationV2> _filterLocationsByMinPower(List<MapLocationV2> locations, int? effectiveMinPowerKw) {
    // If no minimum power is set, return all locations unchanged
    if (effectiveMinPowerKw == null) {
      return locations;
    }

    final minPowerKw = effectiveMinPowerKw.toDouble();

    final filteredLocations = <MapLocationV2>[];

    for (final location in locations) {
      // Filter EVSEs that meet the power requirement
      final filteredEvses = location.evses.where((evse) {
        // Check EVSE-level maxPower first (in kW)
        if (evse.maxPower != null && evse.maxPower! >= minPowerKw) {
          return true;
        }

        // If EVSE-level maxPower doesn't meet requirement, check individual connectors
        final hasQualifyingConnector = evse.connectors.any((connector) {
          return connector.maxPower != null && connector.maxPower! >= minPowerKw;
        });

        return hasQualifyingConnector;
      }).toList();

      // Only include locations that have at least one qualifying EVSE
      if (filteredEvses.isNotEmpty) {
        // Create a new location object with filtered EVSEs
        filteredLocations.add(
          MapLocationV2(
            id: location.id,
            name: location.name,
            city: location.city,
            address: location.address,
            subOperator: location.subOperator,
            evses: filteredEvses,
            facilities: location.facilities,
            infraProviderId: location.infraProviderId,
            customNote: location.customNote,
            geoLocation: location.geoLocation,
            cdrAdditionalCharges: location.cdrAdditionalCharges,
          ),
        );
      }
    }

    return filteredLocations;
  }
}
