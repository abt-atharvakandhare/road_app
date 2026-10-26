part of 'map_overlay_bloc.dart';

@freezed
sealed class MapOverlayState with _$MapOverlayState {
  // Only showing the text entry box at the top of the screen.
  const factory MapOverlayState.initial({@Default(UIFlow.established()) UIFlow flow}) = Initial;

  // Showing a list of typeahead Google Places results
  const factory MapOverlayState.typeaheadSearchResults(String searchText, List<GeoLocationResult> results,
      {@Default(UIFlow.established()) UIFlow flow}) = TypeAheadSearchResults;

  // Waiting for map to settle so we can switch to showChargingStationResults.
  // This prevents us from loading the map data twice.
  const factory MapOverlayState.waitingForMapToSettle(Function(BuildContext context) onMapSettled,
      {@Default(UIFlow.established()) UIFlow flow}) = WaitingForMapToSettle;

  // Showing a list of charging stations near the location shown on the map.
  const factory MapOverlayState.showChargingStationResults(
      {required List<MapLocationsResponseModel> locations,
      String? searchBoxText,
      LatLng? mapPinPosition,
      @Default(UIFlow.established()) UIFlow flow}) = ShowChargingStationResults;

  // Showing an individual charging station on the map.
  const factory MapOverlayState.showChargingStation({
    required List<MapLocationV2> mapLocations,
    required bool fromFavourites,
    @Default(UIFlow.established()) UIFlow flow,
  }) = ShowChargingStation;
}

extension MapOverlayStateIsShowing on MapOverlayState {
  bool get overlayIsShowing {
    return switch (this) {
      Initial() => false,
      ShowChargingStation() => true,
      _ => true,
    };
  }
}
