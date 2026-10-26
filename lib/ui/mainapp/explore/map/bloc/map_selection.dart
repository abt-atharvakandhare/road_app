import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_selection.freezed.dart';

@freezed
sealed class MapSelection with _$MapSelection {
  const factory MapSelection.none() = MapSelectionNone;
  const factory MapSelection.byId(String locationId) = MapSelectionById;
  const factory MapSelection.byLocation(LatLng location) = MapSelectionByLocation;
}
