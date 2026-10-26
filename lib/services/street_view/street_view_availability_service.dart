import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:road_mobile/services/environment/config.dart';

/// Checks whether Google Street View imagery exists near a coordinate, using the
/// Street View Static API metadata endpoint (free of charge, no imagery quota).
class StreetViewAvailabilityService {
  StreetViewAvailabilityService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _metadataUrl = 'https://maps.googleapis.com/maps/api/streetview/metadata';

  /// Radius in metres used to search for a panorama around the coordinate.
  /// Kept in sync with the search radius of the embedded panorama itself.
  static const double searchRadius = 50;

  String get _apiKey => Platform.isIOS ? Config.googleServicesApiKeyIos : Config.googleServicesApiKeyAndroid;

  /// Returns true only when Google confirms imagery near the coordinate.
  /// `ZERO_RESULTS`/`NOT_FOUND`, and any error (network, quota, key
  /// restrictions), count as unavailable: without a positive answer the
  /// panorama would most likely load blank anyway. Cancelling [cancelToken]
  /// also resolves to false.
  Future<bool> isAvailable(double latitude, double longitude, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _metadataUrl,
        queryParameters: {
          'location': '$latitude,$longitude',
          'radius': '${searchRadius.toInt()}',
          'source': 'default',
          'key': _apiKey,
        },
        cancelToken: cancelToken,
      );

      final status = response.data?['status'] as String?;
      return status == 'OK';
    } catch (e) {
      debugPrint('Street View metadata check failed: $e');
      return false;
    }
  }
}
