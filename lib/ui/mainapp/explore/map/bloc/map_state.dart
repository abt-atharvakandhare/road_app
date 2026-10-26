part of 'map_bloc.dart';

@freezed
sealed class MapState with _$MapState {
  const factory MapState.chargingStations({
    required List<MapLocationItem> mapItems,
    LatLng? moveToLocation,
    LatLng? searchResultPinLocation,
    @Default(MapSelection.none()) MapSelection selection,
    @Default(UIFlow.established()) UIFlow flow,
  }) = ChargingStations;
}

extension MapStateBuild on MapState {
  // Return true when on map state content changes.
  bool shouldRebuild(MapState other) {
    return switch (this) {
      ChargingStations(:final mapItems, :final searchResultPinLocation, :final selection) =>
        mapItems != other.mapItems ||
            searchResultPinLocation != other.searchResultPinLocation ||
            selection != other.selection,
    };
  }
}
