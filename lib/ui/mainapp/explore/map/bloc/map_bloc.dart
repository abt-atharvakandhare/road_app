import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart' as google_places;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/locations/geo_location_result.dart';
import 'package:road_mobile/services/bloc_transforms/droppable_with_last.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/ev_map_tools.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/charging_location_filters.dart';
import 'package:road_mobile/ui/utils/maps_utils.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

import '../map_location_item.dart';
import '../marker_generator.dart';
import 'map_repository.dart';
import 'map_selection.dart';

part 'map_state.dart';
part 'map_event.dart';
part 'map_bloc.freezed.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._mapRepo, this._googlePlacesApi) : super(const MapState.chargingStations(mapItems: [])) {
    on<RemovePinSelection>(_removePinSelection);
    on<UserTappedLocation>(_userTappedLocation);
    on<SelectLocationWithId>(_selectLocationWithId);
    on<RegionUpdated>(_onRegionUpdated, transformer: droppableWithLast());
    on<MapFiltersChanged>(_onMapFiltersChanged);
    on<MapFiltersApplied>(_onMapFiltersApplied);
    on<MoveMapToLocation>(_onMoveMapToLocation);
    on<GeoCodingResultSelected>(_onGeoCodingResultSelected);

    _markerGenerator.loadMarkerBitmaps();
  }

  final MapRepository _mapRepo;
  final google_places.FlutterGooglePlacesSdk _googlePlacesApi;
  final MarkerGenerator _markerGenerator = MarkerGenerator();

  LatLngBounds? mapBounds;
  double? zoomLevel;
  ChargingLocationFilters mapFilters = ChargingLocationFilters.loadFromSharedPrefs();

  LatLng? get lastMapCenter {
    return mapBounds?.center;
  }

  /// Returns the cached list of all operator names from the API.
  Future<List<String>> getOperators() => _mapRepo.getOperators();

  void _removePinSelection(RemovePinSelection event, Emitter<MapState> emit) async {
    final newItems = await _markerGenerator.selectedMapLocationItemsCopy(
      state.mapItems,
      const MapSelection.none(),
    );
    if (event.backToGeocodingSelection) {
      emit(state.copyWith(
          mapItems: newItems, moveToLocation: state.searchResultPinLocation, selection: const MapSelection.none()));
    } else {
      emit(state.copyWith(
        mapItems: newItems,
        moveToLocation: null,
        searchResultPinLocation: null,
        selection: const MapSelection.none(),
      ));
    }
  }

  void _userTappedLocation(UserTappedLocation event, Emitter<MapState> emit) async {
    final newItems = await _markerGenerator.selectedMapLocationItemsCopy(
      state.mapItems,
      MapSelection.byLocation(event.location),
    );
    emit(state.copyWith(
        mapItems: newItems,
        moveToLocation: null,
        searchResultPinLocation: null,
        selection: MapSelection.byLocation(event.location)));
  }

  void _selectLocationWithId(SelectLocationWithId event, Emitter<MapState> emit) async {
    final newItems = await _markerGenerator.selectedMapLocationItemsCopy(
      state.mapItems,
      MapSelection.byId(event.locationId),
    );

    emit(state.copyWith(
      mapItems: newItems,
      moveToLocation: null,
      searchResultPinLocation: null,
      selection: MapSelection.byId(event.locationId),
    ));
  }

  void _onRegionUpdated(RegionUpdated event, Emitter<MapState> emit) async {
    zoomLevel = event.zoomLevel;
    mapBounds = event.mapBounds;
    return await _loadFreshMapData(emit);
  }

  void _onMapFiltersChanged(MapFiltersChanged event, Emitter<MapState> emit) {
    mapFilters = event.newFilters;
    mapFilters.saveToSharedPrefs();
  }

  void _onMapFiltersApplied(MapFiltersApplied event, Emitter<MapState> emit) async {
    mapFilters = event.newFilters;
    mapFilters.saveToSharedPrefs();
    return await _loadFreshMapData(emit);
  }

  void _onMoveMapToLocation(MoveMapToLocation event, Emitter<MapState> emit) async {
    final latLng = LatLng(event.latitude, event.longitude);

    MapSelection newSelection;
    List<MapLocationItem> newMapItems = state.mapItems;

    switch (event.pinSelection) {
      case _EvseLocationIfPresent():
        // The endpoint that powers the map and the endpoint that provides the location details can have very small
        // differences due to someone's decision to round the lat/lng.
        final locationOfNearItem = state.mapItems.itemVeryNear(latLng);

        if (locationOfNearItem != null) {
          newSelection = MapSelection.byLocation(locationOfNearItem);
        } else {
          newSelection = MapSelection.byLocation(latLng);
        }
        break;
      case _LocationId(:final id):
        newSelection = MapSelection.byId(id);
        // Update map items to show the selected marker
        newMapItems = await _markerGenerator.selectedMapLocationItemsCopy(
          state.mapItems,
          newSelection,
        );
        break;
      case _None():
        newSelection = state.selection;
        break;
    }

    emit(MapState.chargingStations(
        mapItems: newMapItems,
        moveToLocation: latLng,
        searchResultPinLocation: state.searchResultPinLocation,
        selection: newSelection));
  }

  void _onGeoCodingResultSelected(GeoCodingResultSelected event, Emitter<MapState> emit) async {
    emit(state.copyWith(moveToLocation: null, flow: const UIFlow.loading()));
    final placeDetail =
        await _googlePlacesApi.fetchPlace(event.selectedResult.id, fields: [google_places.PlaceField.Location]);
    final placeLatLng = placeDetail.place?.latLng;

    if (placeLatLng == null) {
      emit(state.copyWith(
          moveToLocation: null, flow: UIFlow.error(RMApiError(cause: 'No location found for selected result'))));
      return;
    }

    // Move the map. Once move is complete the move complete callback will load the data.
    final position = LatLng(placeLatLng.lat, placeLatLng.lng);
    emit(MapState.chargingStations(
        mapItems: state.mapItems,
        moveToLocation: position,
        searchResultPinLocation: position,
        selection: MapSelection.byLocation(position),
        flow: const UIFlow.loading()));
  }

  Future<void> _loadFreshMapData(Emitter<MapState> emit) async {
    // mapBounds and zoomLevel are both populated from the camera event, but each
    // is force-unwrapped below, so guard both: a camera event can report bounds
    // with a null zoom before the map has fully settled (e.g. a fast filter apply,
    // or a non-rendering map), and zoomLevel! would otherwise throw.
    if (mapBounds == null || zoomLevel == null) {
      log('Map bounds/zoom not ready, not loading map data');
      return;
    }

    try {
      final currentState = state;
      if (currentState is ChargingStations) {
        emit(currentState.copyWith(moveToLocation: null, flow: const UIFlow.loading()));
      } else {
        emit(state.copyWith(flow: const UIFlow.loading()));
      }

      // We extend the bounds by 20% to ensure the clustering does not change for pins near the edge of the screen.
      // Then we filter by the visibile area to keep the number of map markers down to avoid overloading the map.
      final extended = mapBounds!.extend(1.2);
      final List<List<double>> geoBox = [
        [extended.southwest.longitude, extended.northeast.latitude],
        [extended.northeast.longitude, extended.southwest.latitude]
      ];

      final clusteredResponse = await _mapRepo.getClusteredChargingLocations(
          geoBox: geoBox, zoomLevel: zoomLevel!.toInt(), filters: mapFilters);

      final mapItems = await _markerGenerator.computeGenerateClusterMetadata(
        mapBounds!,
        clusteredResponse,
        state.selection,
      );

      emit(state.copyWith(mapItems: mapItems, flow: const UIFlow.established()));
    } on RMApiError catch (e) {
      final currentState = state;
      if (currentState is ChargingStations) {
        emit(currentState.copyWith(moveToLocation: null, flow: UIFlow.error(e)));
      } else {
        emit(state.copyWith(flow: UIFlow.error(e)));
      }
    }
  }
}
