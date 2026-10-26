part of 'map_bloc.dart';

@freezed
sealed class MapLocationPinSelection with _$MapLocationPinSelection {
  const factory MapLocationPinSelection.none() = _None;
  const factory MapLocationPinSelection.evseLocationIfPresent() = _EvseLocationIfPresent;
  const factory MapLocationPinSelection.locationId(String id) = _LocationId;
}

@freezed
sealed class MapEvent with _$MapEvent {
  // Get rid of the currently selected location.
  const factory MapEvent.removePinSelection(bool backToGeocodingSelection) = RemovePinSelection;

  // Select and highlight a location on the map.
  const factory MapEvent.userTappedLocation(LatLng location) = UserTappedLocation;

  // Select and highlight a location on the map. Will not move the map or reload the map data.
  // The location should be visible in the map for this to work.
  const factory MapEvent.selectLocationWithId(String locationId) = SelectLocationWithId;

  // Sent from callback when the map is moved.
  const factory MapEvent.regionUpdated({required LatLngBounds mapBounds, required double zoomLevel}) = RegionUpdated;

  // Sent when filters are modified during editing. Persists without reloading the map.
  const factory MapEvent.mapFiltersChanged(ChargingLocationFilters newFilters) = MapFiltersChanged;

  // Sent when filters are committed. Persists and reloads the map.
  const factory MapEvent.mapFiltersApplied(ChargingLocationFilters newFilters) = MapFiltersApplied;

  // Sent from overlay widget when a location is selected. Moves the map to the location.
  const factory MapEvent.moveMapToLocation(double latitude, double longitude, MapLocationPinSelection pinSelection) =
      MoveMapToLocation;

  // User selected a geo coding result.
  const factory MapEvent.geoCodingResultSelected(GeoLocationResult selectedResult) = GeoCodingResultSelected;
}
