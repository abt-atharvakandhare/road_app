import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps_flutter;
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:road_mobile/ui/utils/maps_utils.dart';

extension RMLatLngBounds on google_maps_flutter.LatLngBounds {
  google_maps_flutter.LatLngBounds extend(double extensionFactor) {
    final latDistanceStep = (northeast.latitude - center.latitude) * extensionFactor;
    final longDistanceStep = (northeast.longitude - center.longitude) * extensionFactor;

    return google_maps_flutter.LatLngBounds(
      northeast: google_maps_flutter.LatLng(center.latitude + latDistanceStep, center.longitude + longDistanceStep),
      southwest: google_maps_flutter.LatLng(center.latitude - latDistanceStep, center.longitude - longDistanceStep),
    );
  }

  static google_maps_flutter.LatLngBounds fromCenterAndRadius(
      double latitude, double longitude, double radiusInMeters) {
    double distanceFromCenterToCorner = radiusInMeters * sqrt(2);

    final center = maps_toolkit.LatLng(latitude, longitude);

    final southwestCorner = maps_toolkit.SphericalUtil.computeOffset(center, distanceFromCenterToCorner, 225.0);
    final northeastCorner = maps_toolkit.SphericalUtil.computeOffset(center, distanceFromCenterToCorner, 45.0);

    return google_maps_flutter.LatLngBounds(
      southwest: google_maps_flutter.LatLng(southwestCorner.latitude, southwestCorner.longitude),
      northeast: google_maps_flutter.LatLng(northeastCorner.latitude, northeastCorner.longitude),
    );
  }
}
