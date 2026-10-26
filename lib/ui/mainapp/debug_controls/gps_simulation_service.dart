import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/user_location/user_location.dart';

@singleton
class GpsSimulationService {
  Timer? _timer;
  StreamController<UserLocation>? _locationController;

  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;
  double _speedKmh = 100.0;
  double _bearing = 0.0; // 0 = North, 90 = East, 180 = South, 270 = West

  Stream<UserLocation> get locationStream => _locationController?.stream ?? const Stream.empty();
  bool get isSimulating => _timer != null && _timer!.isActive;
  double get currentSpeed => _speedKmh;

  void startSimulation({
    required double startLatitude,
    required double startLongitude,
    double speedKmh = 100.0,
    double bearing = 0.0,
  }) {
    stopSimulation();

    _currentLatitude = startLatitude;
    _currentLongitude = startLongitude;
    _speedKmh = speedKmh;
    _bearing = bearing;

    _locationController = StreamController<UserLocation>.broadcast();

    // Emit initial location
    _emitLocation();

    // Start 1Hz timer (1 update per second)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateLocation();
      _emitLocation();
    });
  }

  void updateSpeed(double speedKmh) {
    _speedKmh = speedKmh;
  }

  void updateBearing(double bearing) {
    _bearing = bearing;
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
    _locationController?.close();
    _locationController = null;
  }

  void _updateLocation() {
    // Calculate distance traveled in one second
    final metersPerSecond = _speedKmh / 3.6;

    // Convert bearing to radians
    final bearingRadians = _bearing * (math.pi / 180.0);

    // Calculate latitude and longitude deltas
    // 1 degree latitude ≈ 111,111 meters
    // 1 degree longitude varies with latitude, using cos(lat) correction
    final latitudeDelta = (metersPerSecond * math.cos(bearingRadians)) / 111111;
    final longitudeDelta = (metersPerSecond * math.sin(bearingRadians)) / (111111 * math.cos(_currentLatitude * (math.pi / 180.0)));

    log('GPS SIM: bearing=$_bearing°, lat Δ=$latitudeDelta, lng Δ=$longitudeDelta, new=($_currentLatitude, $_currentLongitude)');

    _currentLatitude += latitudeDelta;
    _currentLongitude += longitudeDelta;
  }

  void _emitLocation() {
    _locationController?.add(UserLocation(
      latitude: _currentLatitude,
      longitude: _currentLongitude,
      accuracy: 5.0, // Simulate good GPS accuracy
      speed: _speedKmh, // Include simulated speed
      heading: _bearing, // Current bearing
    ));
  }

  void dispose() {
    stopSimulation();
  }
}