// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsResponseModel _$NotificationsResponseModelFromJson(
  Map<String, dynamic> json,
) => NotificationsResponseModel(
  data: NotificationsResponse.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NotificationsResponseModelToJson(
  NotificationsResponseModel instance,
) => <String, dynamic>{'data': instance.data};

NotificationsResponse _$NotificationsResponseFromJson(
  Map<String, dynamic> json,
) => NotificationsResponse(
  topics: (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$NotificationsResponseToJson(
  NotificationsResponse instance,
) => <String, dynamic>{'topics': instance.topics};
