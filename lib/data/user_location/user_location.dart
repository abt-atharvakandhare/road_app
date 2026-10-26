import 'package:equatable/equatable.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed; // Speed in km/h
  final double? heading; // Heading in degrees (0-360, where 0=North, 90=East, 180=South, 270=West)

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.speed = 0.0,
    this.heading,
  });

  LatLng get asLatLng => LatLng(latitude, longitude);

  @override
  String toString() {
    return 'UserLocation{latitude: $latitude, longitude: $longitude, accuracy: $accuracy, speed: $speed km/h, heading: $heading°}';
  }

  @override
  List<Object?> get props => [latitude, longitude, speed, heading]; // Include speed and heading for highway mode detection

  num distanceToOtherLocation(UserLocation otherLocation) {
    return SphericalUtil.computeDistanceBetween(asLatLng, otherLocation.asLatLng);
  }
}
