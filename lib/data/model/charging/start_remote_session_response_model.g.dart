// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_remote_session_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartRemoteSessionResponseModel _$StartRemoteSessionResponseModelFromJson(
  Map<String, dynamic> json,
) => StartRemoteSessionResponseModel(
  StartRemoteSessionDataModel.fromJson(json['data'] as Map<String, dynamic>),
  json['action'] == null
      ? null
      : StartRemoteSessionAction.fromJson(
          json['action'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$StartRemoteSessionResponseModelToJson(
  StartRemoteSessionResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'action': instance.action};

StartRemoteSessionDataModel _$StartRemoteSessionDataModelFromJson(
  Map<String, dynamic> json,
) =>
    StartRemoteSessionDataModel(json['id'] as String, json['status'] as String);

Map<String, dynamic> _$StartRemoteSessionDataModelToJson(
  StartRemoteSessionDataModel instance,
) => <String, dynamic>{'id': instance.id, 'status': instance.status};

StartRemoteSessionAction _$StartRemoteSessionActionFromJson(
  Map<String, dynamic> json,
) => StartRemoteSessionAction(
  json['case'] as String?,
  json['value'] == null
      ? null
      : StartRemoteSessionActionValue.fromJson(
          json['value'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$StartRemoteSessionActionToJson(
  StartRemoteSessionAction instance,
) => <String, dynamic>{'case': instance.case_, 'value': instance.value};

StartRemoteSessionActionValue _$StartRemoteSessionActionValueFromJson(
  Map<String, dynamic> json,
) => StartRemoteSessionActionValue(json['url'] as String?);

Map<String, dynamic> _$StartRemoteSessionActionValueToJson(
  StartRemoteSessionActionValue instance,
) => <String, dynamic>{'url': instance.url};
