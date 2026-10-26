import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/data/model/locations/remote_sessions_available_model.dart';

import '../../data/model/locations/locations_response_model.dart';
import 'charging_port_availability.dart';

extension LanLngBoundsUtils on LatLngBounds {
  LatLng get center => LatLng(
        (northeast.latitude + southwest.latitude) / 2,
        (northeast.longitude + southwest.longitude) / 2,
      );

  double getBoundsZoomLevel(Size mapDimensions, double maxZoomLevel) {
    var worldDimension = const Size(1024, 1024);

    double latRad(lat) {
      var sinValue = sin(lat * pi / 180);
      var radX2 = log((1 + sinValue) / (1 - sinValue)) / 2;
      return max(min(radX2, pi), -pi) / 2;
    }

    double zoom(mapPx, worldPx, fraction) {
      return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
    }

    var ne = northeast;
    var sw = southwest;

    var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

    var lngDiff = ne.longitude - sw.longitude;
    var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

    var latZoom = zoom(mapDimensions.height, worldDimension.height, latFraction);
    var lngZoom = zoom(mapDimensions.width, worldDimension.width, lngFraction);

    if (latZoom < 0) return lngZoom;
    if (lngZoom < 0) return latZoom;

    final targetZoom = min(latZoom, lngZoom);
    if (targetZoom > maxZoomLevel) return maxZoomLevel;

    return targetZoom;
  }
}

extension LocationUtils on Location {
  Marker toMarker({void Function()? onTap}) {
    final ChargingPortAvailability portAvailability = chargingPortAvailability;

    final locationLatLng = geoLocation.latLng ?? const LatLng(0, 0);

    final double locationHue;
    switch (portAvailability) {
      case ChargingPortAvailability.available:
        locationHue = BitmapDescriptor.hueGreen;
        break;
      case ChargingPortAvailability.notAvailable:
        locationHue = BitmapDescriptor.hueRed;
        break;
      case ChargingPortAvailability.charging:
        locationHue = BitmapDescriptor.hueBlue;
        break;
    }

    return Marker(
      markerId: MarkerId(id),
      consumeTapEvents: true,
      position: locationLatLng,
      infoWindow: InfoWindow(title: name),
      icon: BitmapDescriptor.defaultMarkerWithHue(locationHue),
      onTap: onTap,
    );
  }
}

extension RemoteSessionLocationUtils on RemoteSessionAvailableModel {
  Marker toMarker({void Function()? onTap}) {
    final ChargingPortAvailability portAvailability = ChargingPortAvailability.fromString(status);

    final locationLatLng = geoLocation.latLng ?? const LatLng(0, 0); // ToDo - skip?

    final double locationHue;
    switch (portAvailability) {
      case ChargingPortAvailability.available:
        locationHue = BitmapDescriptor.hueGreen;
        break;
      case ChargingPortAvailability.notAvailable:
        locationHue = BitmapDescriptor.hueRed;
        break;
      case ChargingPortAvailability.charging:
        locationHue = BitmapDescriptor.hueBlue;
        break;
    }

    return Marker(
      markerId: MarkerId(id),
      consumeTapEvents: true,
      position: locationLatLng,
      infoWindow: InfoWindow(title: id),
      icon: BitmapDescriptor.defaultMarkerWithHue(locationHue),
      onTap: onTap,
    );
  }
}

extension LatLngListUtils on List<LatLng> {
  LatLngBounds? allLocationBounds() {
    if (isEmpty) {
      return null;
    }

    var firstLatLng = first;
    var s = firstLatLng.latitude, n = firstLatLng.latitude, w = firstLatLng.longitude, e = firstLatLng.longitude;
    for (var i = 1; i < length; i++) {
      var latlng = this[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }

    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }
}

extension LatLngMarker on LatLng? {
  Marker toMarker(String id, ChargingPortAvailability portAvailability, {void Function()? onTap}) {
    final locationLatLng = this ?? const LatLng(0, 0); // ToDo - skip?

    final double locationHue;
    switch (portAvailability) {
      case ChargingPortAvailability.available:
        locationHue = BitmapDescriptor.hueGreen;
        break;
      case ChargingPortAvailability.notAvailable:
        locationHue = BitmapDescriptor.hueRed;
        break;
      case ChargingPortAvailability.charging:
        locationHue = BitmapDescriptor.hueBlue;
        break;
    }

    return Marker(
      markerId: MarkerId(id),
      consumeTapEvents: true,
      position: locationLatLng,
      infoWindow: InfoWindow(title: id),
      icon: BitmapDescriptor.defaultMarkerWithHue(locationHue),
      onTap: onTap,
    );
  }
}

extension LatLngProximity on LatLng {
  bool isVeryCloseTo(LatLng other) {
    const double threshold = 0.0001;
    return (latitude - other.latitude).abs() < threshold && (longitude - other.longitude).abs() < threshold;
  }
}
