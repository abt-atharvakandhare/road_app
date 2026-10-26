import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/locations/map_api_gen2_response_model.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/charging_location_filters.dart';

@lazySingleton
class MapRepository {
  final ApiService _apiService;
  final Analytics _analytics;

  MapRepository(this._apiService, this._analytics);

  List<String>? _cachedOperators;

  Future<List<String>> getOperators() async {
    if (_cachedOperators != null) return _cachedOperators!;
    try {
      final response = await _apiService.get('/1/map/config');
      _cachedOperators = List<String>.from(response.data['data']['operators'] ?? []);
      return _cachedOperators!;
    } catch (e) {
      log('Failed to fetch map config operators: $e');
      return [];
    }
  }

  Future<MapApiGen2ResponseModel> getClusteredChargingLocations({
    required List geoBox,
    required int zoomLevel,
    ChargingLocationFilters? filters,
  }) async {
    //                   0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18  19  20  21  22  23  24  25
    const geoHashZoom = [1, 1, 1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 7, 8, 9, 9, 9, 10, 10, 11, 11, 11, 11, 11];
    final gridPrecision = geoHashZoom[zoomLevel];
    log('Zoom level: $zoomLevel, gridPrecision: $gridPrecision');
    Map data = {
      'gridPrecision': gridPrecision,
      'bbox': {'nwLat': geoBox[0][1], 'nwLng': geoBox[0][0], 'seLat': geoBox[1][1], 'seLng': geoBox[1][0]},
    };

    if (filters != null) {
      data.addAll(filters.apiMapWithWorkarounds);
    }

    int? code;

    try {
      final apiResponse = await _apiService.post('/1/map/search', data: data);
      code = apiResponse.statusCode;
      final mapResponse = MapApiGen2ResponseModel.fromJson(apiResponse.data);
      return mapResponse;
    } catch (e) {
      _analytics.logMapDataLoadError(responseCode: code, data: data, response: e.toString());
      rethrow;
    }
  }
}
