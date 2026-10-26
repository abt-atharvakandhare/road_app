import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClusterCache {
  final Map<String, Future<BitmapDescriptor>> _cache = {};

  Future<BitmapDescriptor>? getCluster(String id) {
    return _cache[id];
  }

  void addCluster(String id, Future<BitmapDescriptor> cluster) {
    _cache[id] = cluster;
  }
}
