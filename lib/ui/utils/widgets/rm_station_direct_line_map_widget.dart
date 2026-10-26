import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/maps_utils.dart';

/// A map widget that displays a charging station location and optionally
/// shows the user's location with a dashed route line between them.
class RMStationDirectLineMapWidget extends StatefulWidget {
  const RMStationDirectLineMapWidget({
    super.key,
    required this.stationLocation,
    required this.stationId,
    required this.stationName,
    required this.stationStatus,
    this.userLocation,
    this.aspectRatio = 375.0 / 200.0,
  });

  /// The location of the charging station
  final LatLng stationLocation;

  /// Unique identifier for the station marker
  final String stationId;

  /// Name to display in the marker info window
  final String stationName;

  /// Status of the charging station (determines marker color)
  final ChargingPortAvailability stationStatus;

  /// Optional user location - if provided, the map will zoom to show both
  /// locations and draw a dashed line between them
  final LatLng? userLocation;

  /// Aspect ratio for the map container
  final double aspectRatio;

  /// The dash-to-gap ratio (2:1) used for the route line pattern.
  static const double dashRatio = 2 / 3;
  static const double gapRatio = 1 / 3;

  /// Fixed number of dash/gap repetitions on iOS regardless of distance.
  /// Keeps GMSStyleSpan count constant to avoid iOS memory issues
  /// (the iOS SDK interprets pattern lengths as meters via kGMSLengthRhumb).
  static const int targetRepetitions = 25;

  /// Fixed pixel-based pattern values for Android, where the SDK correctly
  /// interprets pattern lengths as screen pixels.
  static const double androidDashPixels = 20;
  static const double androidGapPixels = 10;

  @override
  State<RMStationDirectLineMapWidget> createState() => _RMStationDirectLineMapWidgetState();
}

class _RMStationDirectLineMapWidgetState extends State<RMStationDirectLineMapWidget> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _markerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    final assetPath = switch (widget.stationStatus) {
      ChargingPortAvailability.available => 'assets/icons/map_marker_available@2x.png',
      ChargingPortAvailability.charging => 'assets/icons/map_marker_unavailable@2x.png',
      ChargingPortAvailability.notAvailable => 'assets/icons/map_marker_unknown@2x.png',
    };

    final data = await rootBundle.load(assetPath);
    final icon = BitmapDescriptor.bytes(data.buffer.asUint8List(), width: 22, height: 28);
    if (mounted) {
      setState(() {
        _markerIcon = icon;
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RMStationDirectLineMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stationStatus != widget.stationStatus) {
      _loadMarkerIcon();
    }
  }

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: MarkerId(widget.stationId),
      position: widget.stationLocation,
      infoWindow: InfoWindow(title: widget.stationName),
      icon: _markerIcon ?? BitmapDescriptor.defaultMarker,
    );

    final polylines = _buildPolylines();
    final initialCameraPosition = _getInitialCameraPosition();

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        markers: {marker},
        polylines: polylines,
        onMapCreated: _onMapCreated,
      ),
    );
  }

  CameraPosition _getInitialCameraPosition() {
    final userLocation = widget.userLocation;
    if (userLocation == null) {
      return CameraPosition(target: widget.stationLocation, zoom: 16.0);
    }

    // Start centered between both points so the map loads the right tiles immediately
    final midLat = (widget.stationLocation.latitude + userLocation.latitude) / 2;
    final midLng = (widget.stationLocation.longitude + userLocation.longitude) / 2;
    return CameraPosition(target: LatLng(midLat, midLng), zoom: 4.0);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Fit bounds to show both locations with padding
    if (widget.userLocation != null) {
      _moveToBounds();
    }
  }

  void _moveToBounds() {
    final userLocation = widget.userLocation;
    if (userLocation == null || _mapController == null) return;

    final bounds = [widget.stationLocation, userLocation].allLocationBounds();
    if (bounds == null) return;

    const padding = 50.0;
    _mapController!.moveCamera(CameraUpdate.newLatLngBounds(bounds, padding));
  }

  Set<Polyline> _buildPolylines() {
    final userLocation = widget.userLocation;
    if (userLocation == null) return {};

    final double dashLength;
    final double gapLength;

    if (Platform.isIOS) {
      // iOS SDK interprets pattern lengths as meters (kGMSLengthRhumb),
      // so scale them to the distance to keep a fixed span count.
      final distance = _haversineMeters(userLocation, widget.stationLocation);
      final cycleLength = distance / RMStationDirectLineMapWidget.targetRepetitions;
      dashLength = cycleLength * RMStationDirectLineMapWidget.dashRatio;
      gapLength = cycleLength * RMStationDirectLineMapWidget.gapRatio;
    } else {
      // Android SDK interprets pattern lengths as screen pixels.
      dashLength = RMStationDirectLineMapWidget.androidDashPixels;
      gapLength = RMStationDirectLineMapWidget.androidGapPixels;
    }

    return {
      Polyline(
        polylineId: const PolylineId('route_to_station'),
        points: [userLocation, widget.stationLocation],
        color: RMColors.rmPrimaryColor,
        width: 3,
        patterns: [
          PatternItem.dash(dashLength),
          PatternItem.gap(gapLength),
        ],
      ),
    };
  }

  /// Approximate distance in meters between two LatLng points using the
  /// haversine formula.
  static double _haversineMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLng = _toRadians(b.longitude - a.longitude);
    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final h = sinDLat * sinDLat +
        cos(_toRadians(a.latitude)) * cos(_toRadians(b.latitude)) * sinDLng * sinDLng;
    return 2 * earthRadius * asin(sqrt(h));
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
