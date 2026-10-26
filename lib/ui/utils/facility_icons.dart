/// Maps facility strings from the API to their corresponding highway icon asset paths
class FacilityIcons {
  static const String _basePath = 'assets/icons';

  /// Map of facility types to their icon asset paths
  static const Map<String, String> _facilityIconMap = {
    'AIRPORT': '$_basePath/highway_airport.svg',
    'BIKE_SHARING': '$_basePath/highway_bike_sharing.svg',
    'BUS_STOP': '$_basePath/highway_bus_stop.svg',
    'CAFE': '$_basePath/highway_cafe.svg',
    'CARPOOL_PARKING': '$_basePath/highway_carpool_parking.svg',
    'FUEL_STATION': '$_basePath/highway_fuel_station.svg',
    'HOTEL': '$_basePath/highway_hotel.svg',
    'MALL': '$_basePath/highway_mall.svg',
    'METRO_STATION': '$_basePath/highway_metro_station.svg',
    'MUSEUM': '$_basePath/highway_museum.svg',
    'NATURE': '$_basePath/highway_nature.svg',
    'PARKING_LOT': '$_basePath/highway_parking_lot.svg',
    'RECREATION_AREA': '$_basePath/highway_recreation_area.svg',
    'RESTAURANT': '$_basePath/highway_restaurant.svg',
    'SPORT': '$_basePath/highway_sport.svg',
    'SUPERMARKET': '$_basePath/highway_supermarket.svg',
    'TAXI_STAND': '$_basePath/highway_taxi_stand.svg',
    'TRAIN_STATION': '$_basePath/highway_train_station.svg',
    'TRAM_STOP': '$_basePath/highway_tram_stop.svg',
    'WIFI': '$_basePath/highway_wifi.svg',
  };

  /// Returns the icon asset path for a given facility string
  /// Returns null if no icon exists for the facility
  static String? getIconPath(String facility) {
    return _facilityIconMap[facility.toUpperCase()];
  }

  /// Returns a list of icon asset paths for a list of facilities
  /// Only returns paths for facilities that have corresponding icons
  static List<String> getIconPaths(List<String>? facilities) {
    if (facilities == null || facilities.isEmpty) {
      return [];
    }

    return facilities
        .map((facility) => getIconPath(facility))
        .whereType<String>()
        .toList();
  }
}
