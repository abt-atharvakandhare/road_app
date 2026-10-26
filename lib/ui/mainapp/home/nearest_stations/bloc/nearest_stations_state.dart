part of 'nearest_stations_cubit.dart';

@freezed
sealed class NearestStationsState with _$NearestStationsState {
  const factory NearestStationsState({
    required List<MapLocationV2> stations,
    UserLocation? userLocation,
    String? currentRoadName,
    @Default(false) bool isLowSpeed,
    @Default(NearestStationsMode.highway) NearestStationsMode mode,
    @Default(UIFlow.established()) UIFlow flow,
    /// Whether highway mode filtering is currently active (for carScreen mode)
    /// This is true when speed >= 50 km/h and isHighwayAutoEnabled is true
    @Default(false) bool isHighwayModeActive,
  }) = _NearestStationsState;
}
