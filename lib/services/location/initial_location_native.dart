import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:road_mobile/data/user_location/user_location.dart';

/// iOS-only one-shot location read that bypasses geolocator and talks
/// directly to CLLocationManager — the same path the Google Maps SDK uses
/// to render the blue dot. Used to seed [LocationBloc] quickly on cold start.
///
/// Callers are expected to gate on `Platform.isIOS`; the channel is only
/// registered on iOS and will throw `MissingPluginException` elsewhere.
class InitialLocationNative {
  static const _channel = MethodChannel('io.e-flux.mobile/initial_location');

  static Future<UserLocation?> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMapMethod<String, double>('getCurrentLocation');
      if (result == null) return null;

      final lat = result['latitude'];
      final lng = result['longitude'];
      final acc = result['accuracy'];
      if (lat == null || lng == null || acc == null) return null;

      return UserLocation(latitude: lat, longitude: lng, accuracy: acc);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InitialLocationNative.getCurrentLocation failed: $e');
      }
      return null;
    }
  }
}
