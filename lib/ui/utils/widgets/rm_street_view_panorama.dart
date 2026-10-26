import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive Google Street View panorama, backed by the native
/// StreetViewPanoramaView (Android) / GMSPanoramaView (iOS) platform views
/// registered in MainActivity / AppDelegate under [viewType].
class RMStreetViewPanorama extends StatelessWidget {
  const RMStreetViewPanorama({
    super.key,
    required this.latitude,
    required this.longitude,
    this.radius = 50,
  });

  static const String viewType = 'road_mobile/street_view';

  final double latitude;
  final double longitude;

  /// Radius in metres used to search for a panorama around the coordinate.
  final double radius;

  Map<String, dynamic> get _creationParams => {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      };

  // The panorama lives inside the drawer's scroll view; without an eager
  // recognizer the scroll view wins every vertical drag and the panorama
  // cannot be panned. The flip side is that any drag starting on the panorama
  // (vertical included) belongs to it, so the drawer only scrolls from touches
  // outside the frame — the same trade-off as a map inside a scroll view.
  static final Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers = {
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        creationParams: _creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: _gestureRecognizers,
      );
    }

    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: _creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: _gestureRecognizers,
      );
    }

    return const SizedBox.shrink();
  }
}
