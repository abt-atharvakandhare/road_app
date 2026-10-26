import 'dart:math' show min;

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart' as google_places;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/locations/geo_location_result.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/services/bloc_transforms/droppable_with_last.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_repo.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;

import '../../map/map_location_item.dart';

part 'map_overlay_event.dart';
part 'map_overlay_state.dart';
part 'map_overlay_bloc.freezed.dart';

@injectable
class MapOverlayBloc extends Bloc<MapOverlayEvent, MapOverlayState> {
  MapOverlayBloc(this._googlePlacesApi, this._mapOverlayRepo) : super(const Initial()) {
    on<MapOverlayEvent>(_eventHandler, transformer: droppableWithLast(restartOnDifferentEventType: true));
  }

  final GlobalKey searchFieldKey = GlobalKey();
  TextEditingController searchFieldController = TextEditingController();

  @override
  Future<void> close() {
    searchFieldController.dispose();
    return super.close();
  }

  final google_places.FlutterGooglePlacesSdk _googlePlacesApi;
  final MapOverlayRepo _mapOverlayRepo;
  google_places.LatLngBounds? _lastVisibleMapRegion;

  EventHandler<MapOverlayEvent, MapOverlayState> get _eventHandler => (event, emit) => switch (event) {
        SearchQuery(:final searchText) => _onSearchQuery(searchText, emit),
        ResetToInitial() => emit(const Initial()),
        WaitForMapToSettle(:final onMapSettled) => _waitForMapToSettle(onMapSettled, emit),
        LoadSearchResults(:final searchBoxText, :final mapItems, :final mapPinPosition) =>
          _loadSearchResults(searchBoxText, mapItems, mapPinPosition, emit),
        MapLocationSelectedOnMap(:final mapItem) => _chargingStationSelectedOnMap(mapItem, emit),
        ShowMapLocation(:final mapLocations) => _showMapLocation(mapLocations, emit),
        MapLocationSelectedInSearch(:final mapLocations) => _chargingStationSelectedInSearch(mapLocations, emit),
        BackToChargingStationResults() => _backToChargingStationResults(emit),
      };

  Future<void> _onSearchQuery(String searchText, Emitter<MapOverlayState> emit) async {
    if (searchText.isEmpty) {
      emit(MapOverlayState.typeaheadSearchResults(searchText, []));
      return;
    }

    try {
      final response =
          await _googlePlacesApi.findAutocompletePredictions(searchText, locationBias: _lastVisibleMapRegion);
      // Predictions without a place id cannot be resolved to a location by fetchPlace.
      final resultsList = [
        for (final prediction in response.predictions)
          if (prediction.placeId case final placeId?)
            GeoLocationResult(
              id: placeId,
              primaryText: prediction.primaryText ?? prediction.fullText ?? '',
              secondaryText: prediction.secondaryText ?? '',
            ),
      ];

      if (emit.isDone) {
        return;
      }
      emit(MapOverlayState.typeaheadSearchResults(searchText, resultsList));
    } catch (e) {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Geocoding: ${e.toString()}'))));
    }
  }

  List<MapLocationsResponseModel>? _cachedLocationsResponses;
  Future<void> _chargingStationSelectedOnMap(MapLocationItem mapItem, Emitter<MapOverlayState> emit) async {
    _cachedLocationsResponses = null;

    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final mapLocationsResponse = await _mapOverlayRepo.getChargingLocationsDetails(mapItem.locationIds);

      if (emit.isDone) {
        return;
      }
      emit(MapOverlayState.showChargingStation(mapLocations: mapLocationsResponse.data, fromFavourites: false));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<void> _showMapLocation(List<MapLocationV2> mapLocations, Emitter<MapOverlayState> emit) async {
    emit(MapOverlayState.showChargingStation(mapLocations: mapLocations, fromFavourites: true));
  }

  Future<void> _waitForMapToSettle(
      Function(BuildContext buildContext) onMapSettled, Emitter<MapOverlayState> emit) async {
    emit(MapOverlayState.waitingForMapToSettle(onMapSettled));
  }

  Future<void> _loadSearchResults(String? searchBoxText, List<MapLocationItem> mapItems, LatLng? mapPinPosition,
      Emitter<MapOverlayState> emit) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));

      final List<MapLocationItem> sortedMapItems;
      if (mapPinPosition != null) {
        final pinToolsMap = maps_toolkit.LatLng(mapPinPosition.latitude, mapPinPosition.longitude);
        sortedMapItems = mapItems.sortedBy((e) {
          final eLatLng = maps_toolkit.LatLng(e.position.latitude, e.position.longitude);
          return maps_toolkit.SphericalUtil.computeDistanceBetween(eLatLng, pinToolsMap);
        });
      } else {
        sortedMapItems = mapItems;
      }

      // Show at most 3 map locations in the search results.
      int locationResultCount = min(sortedMapItems.length, 3);

      List<Future<MapLocationsResponseModel>> locationsResponsesFutures = [];
      for (int i = 0; i < locationResultCount; i++) {
        final locationsResponse = _mapOverlayRepo.getChargingLocationsDetails(sortedMapItems[i].locationIds);
        locationsResponsesFutures.add(locationsResponse);
      }

      final locationsResponses = await Future.wait(locationsResponsesFutures);

      if (emit.isDone) {
        return;
      }

      _cachedLocationsResponses = locationsResponses;
      emit(MapOverlayState.showChargingStationResults(
          searchBoxText: searchBoxText, locations: locationsResponses, mapPinPosition: mapPinPosition));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<void> _chargingStationSelectedInSearch(
      MapLocationsResponseModel mapLocation, Emitter<MapOverlayState> emit) async {
    emit(MapOverlayState.showChargingStation(mapLocations: mapLocation.data, fromFavourites: false));
  }

  Future<void> _backToChargingStationResults(Emitter<MapOverlayState> emit) async {
    if (_cachedLocationsResponses != null) {
      emit(MapOverlayState.showChargingStationResults(locations: _cachedLocationsResponses!));
    } else {
      emit(const MapOverlayState.initial());
    }
  }

  void mapRegionUpdated(double neLat, double neLong, double swLat, double swLong) {
    _lastVisibleMapRegion = google_places.LatLngBounds(
        southwest: google_places.LatLng(lat: swLat, lng: swLong),
        northeast: google_places.LatLng(lat: neLat, lng: neLong));
  }
}
