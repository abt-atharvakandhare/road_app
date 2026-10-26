import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:road_mobile/data/user_location/user_location.dart';

part 'map_api_gen2_response_model.g.dart';

// The data format we receive to power pins on the map.
@JsonSerializable()
class MapApiGen2ResponseModel {
  final List<MapItemModel> data;

  MapApiGen2ResponseModel({required this.data});

  factory MapApiGen2ResponseModel.fromJson(Map<String, dynamic> json) => _$MapApiGen2ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MapApiGen2ResponseModelToJson(this);

  void sortClosestTo(UserLocation userLocation) {
    final userLatLng = LatLng(userLocation.latitude, userLocation.longitude);
    data.sort((a, b) {
      final aLatLng = LatLng(a.centroid.lat, a.centroid.lon);
      final bLatLng = LatLng(b.centroid.lat, b.centroid.lon);
      final aDistance = SphericalUtil.computeDistanceBetween(userLatLng, aLatLng);
      final bDistance = SphericalUtil.computeDistanceBetween(userLatLng, bLatLng);
      return aDistance.compareTo(bDistance);
    });
  }
}

@JsonSerializable()
class MapItemModel {
  final int count;
  final CentroidModel centroid;
  final List<String> ids;
  final List<StatusModel> statuses;

  MapItemModel({required this.count, required this.centroid, required this.ids, required this.statuses});

  factory MapItemModel.fromJson(Map<String, dynamic> json) => _$MapItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MapItemModelToJson(this);
}

@JsonSerializable()
class CentroidModel {
  final double lat;
  final double lon;

  CentroidModel({required this.lat, required this.lon});

  factory CentroidModel.fromJson(Map<String, dynamic> json) => _$CentroidModelFromJson(json);

  Map<String, dynamic> toJson() => _$CentroidModelToJson(this);
}

@JsonSerializable()
class StatusModel {
  final String name;

  StatusModel({required this.name});

  factory StatusModel.fromJson(Map<String, dynamic> json) => _$StatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatusModelToJson(this);
}
