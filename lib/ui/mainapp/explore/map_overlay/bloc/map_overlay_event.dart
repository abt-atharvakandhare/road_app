part of 'map_overlay_bloc.dart';

@freezed
sealed class MapOverlayEvent with _$MapOverlayEvent {
  // Search for text entered in search box.
  const factory MapOverlayEvent.searchQuery(String searchText) = SearchQuery;

  // Reset to initial state.
  const factory MapOverlayEvent.resetToInitial() = ResetToInitial;

  // Turn the overlay into a map state listener that will be called when the map has settled and finished loading.
  const factory MapOverlayEvent.waitForMapToSettle(Function(BuildContext context) onMapSettled) = WaitForMapToSettle;

  const factory MapOverlayEvent.loadSearchResults(
      String? searchBoxText, List<MapLocationItem> mapItems, LatLng? mapPinPosition) = LoadSearchResults;

  // User selected a charging station either from map. Load the full data for the location and show it.
  const factory MapOverlayEvent.mapLocationSelectedOnMap(MapLocationItem mapItem) = MapLocationSelectedOnMap;

  // User selected a charging station from another source, like favourites.
  const factory MapOverlayEvent.showMapLocation(List<MapLocationV2> mapLocations) = ShowMapLocation;

// User selected a charging station from search results
  const factory MapOverlayEvent.mapLocationSelectedInSearch(MapLocationsResponseModel mapLocations) =
      MapLocationSelectedInSearch;

  const factory MapOverlayEvent.backToChargingStationResults() = BackToChargingStationResults;
}
