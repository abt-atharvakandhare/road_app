import 'package:json_annotation/json_annotation.dart';

part 'notifications_response_model.g.dart';

@JsonSerializable()
class NotificationsResponseModel {
  NotificationsResponseModel({
    required this.data,
  });

  final NotificationsResponse data;

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) => _$NotificationsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsResponseModelToJson(this);
}

@JsonSerializable()
class NotificationsResponse {
  NotificationsResponse({
    required this.topics,
  });

  final List<String> topics;

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) => _$NotificationsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsResponseToJson(this);
}
