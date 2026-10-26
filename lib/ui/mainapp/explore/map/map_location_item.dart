import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/maps_utils.dart';

// Metadata and bitmap for an item on the map. Either a cluster or a single location.
enum MapLocationItemStatus {
  available,
  charging,
  unknown;

  String get statusString {
    switch (this) {
      case MapLocationItemStatus.available:
        return 'Available';
      case MapLocationItemStatus.charging:
        return 'Charging';
      case MapLocationItemStatus.unknown:
        return 'Unknown';
    }
  }
}

class MapLocationItem {
  final int count;
  final LatLng position;
  final BitmapDescriptor icon;
  final List<String> locationIds;
  final MapLocationItemStatus status;
  final int availableCount;
  final int chargingCount;
  final int unknownCount;
  final bool isSelected;

  MapLocationItem(this.count, this.position, this.icon, this.locationIds, this.status, this.availableCount,
      this.chargingCount, this.unknownCount, this.isSelected);

  String get availabilityCountString {
    final total = availableCount + chargingCount + unknownCount;
    if (availableCount == 0 || availableCount == total) {
      return '$total';
    }

    return '$availableCount / $total';
  }

  ChargingPortAvailability get chargingStatus {
    if (availableCount > 0) {
      return ChargingPortAvailability.available;
    } else if (chargingCount > 0) {
      return ChargingPortAvailability.charging;
    } else {
      return ChargingPortAvailability.notAvailable;
    }
  }
}

extension ClusterMarkerBuilder on MapLocationItem {
  Marker toMarker({VoidCallback? onTap}) {
    return Marker(
        markerId: MarkerId('maplocation-${position.latitude}-${position.longitude}'),
        anchor: (count < 2) ? const Offset(0.5, 1.0) : const Offset(0.5, 0.5),
        consumeTapEvents: true,
        position: LatLng(position.latitude, position.longitude),
        icon: icon,
        infoWindow: const InfoWindow(title: 'Selected'),
        onTap: onTap);
  }
}

extension ListOfMapLocationItem on List<MapLocationItem> {
  LatLng? itemVeryNear(LatLng latLng) =>
      firstWhereOrNull((element) => (element.position.isVeryCloseTo(latLng)))?.position;

  MapLocationItem? mapItemWithLocationId(String locationId) =>
      firstWhereOrNull((element) => (element.locationIds.contains(locationId)));
}
