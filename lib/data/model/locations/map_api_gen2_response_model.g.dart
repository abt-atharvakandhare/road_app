// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_api_gen2_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapApiGen2ResponseModel _$MapApiGen2ResponseModelFromJson(
  Map<String, dynamic> json,
) => MapApiGen2ResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => MapItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MapApiGen2ResponseModelToJson(
  MapApiGen2ResponseModel instance,
) => <String, dynamic>{'data': instance.data};

MapItemModel _$MapItemModelFromJson(Map<String, dynamic> json) => MapItemModel(
  count: (json['count'] as num).toInt(),
  centroid: CentroidModel.fromJson(json['centroid'] as Map<String, dynamic>),
  ids: (json['ids'] as List<dynamic>).map((e) => e as String).toList(),
  statuses: (json['statuses'] as List<dynamic>)
      .map((e) => StatusModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MapItemModelToJson(MapItemModel instance) =>
    <String, dynamic>{
      'count': instance.count,
      'centroid': instance.centroid,
      'ids': instance.ids,
      'statuses': instance.statuses,
    };

CentroidModel _$CentroidModelFromJson(Map<String, dynamic> json) =>
    CentroidModel(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );

Map<String, dynamic> _$CentroidModelToJson(CentroidModel instance) =>
    <String, dynamic>{'lat': instance.lat, 'lon': instance.lon};

StatusModel _$StatusModelFromJson(Map<String, dynamic> json) =>
    StatusModel(name: json['name'] as String);

Map<String, dynamic> _$StatusModelToJson(StatusModel instance) =>
    <String, dynamic>{'name': instance.name};
