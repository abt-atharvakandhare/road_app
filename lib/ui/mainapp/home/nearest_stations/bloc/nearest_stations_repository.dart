import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

/// Filter configuration for fetching nearest stations
class NearestStationsFilterConfig {
  final int? minPowerKw;
  final bool availableOnly;
  final double? heading;
  final Map<String, dynamic>? additionalFilters;

  const NearestStationsFilterConfig({
    this.minPowerKw,
    this.availableOnly = false,
    this.heading,
    this.additionalFilters,
  });

  /// Build API request data from filter config
  Map<String, Object> toApiData() {
    final data = <String, Object>{};

    if (heading != null) {
      data['heading'] = heading!;
    }

    if (minPowerKw != null) {
      data['minPower'] = minPowerKw!;
    }

    if (availableOnly) {
      data['status'] = ['AVAILABLE'];
    }

    if (additionalFilters != null) {
      data.addAll(additionalFilters!.cast<String, Object>());
    }

    return data;
  }
}

@lazySingleton
class NearestStationsRepository {
  final ApiService _apiService;

  NearestStationsRepository(this._apiService);

  /// Fetches the nearest charging locations to the given coordinates
  /// Uses the nearestTo search feature from the API
  /// Returns up to [limit] locations sorted by distance
  /// Filters are applied via [filterConfig]
  Future<MapLocationsResponseModel> getNearestChargingLocations({
    required UserLocation location,
    required NearestStationsFilterConfig filterConfig,
    int limit = 10,
  }) async {
    developer.log(
      'NearestStationsRepository: Fetching nearest $limit stations to lat: ${location.latitude}, lng: ${location.longitude}, '
      'filters: {minPower: ${filterConfig.minPowerKw} kW, availableOnly: ${filterConfig.availableOnly}, heading: ${filterConfig.heading}°}',
      name: 'NearestStations',
    );

    final data = <String, Object>{
      'nearestTo': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'limit': limit,
    };

    // Add filter configuration to request
    data.addAll(filterConfig.toApiData());

    try {
      final apiResponse = await _apiService.post('/1/map/locations', data: data);
      final locationsResponse = MapLocationsResponseModel.fromJson(apiResponse.data);

      developer.log(
        'NearestStationsRepository: Successfully fetched ${locationsResponse.data.length} locations',
        name: 'NearestStations',
      );

      return locationsResponse;
    } catch (e) {
      developer.log(
        'NearestStationsRepository: ERROR - Failed to fetch nearest locations',
        name: 'NearestStations',
        error: e,
      );
      throw RMApiError(cause: 'Failed to fetch nearest charging locations: ${e.toString()}');
    }
  }
}
