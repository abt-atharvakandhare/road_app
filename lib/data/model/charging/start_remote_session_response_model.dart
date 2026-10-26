import 'package:json_annotation/json_annotation.dart';

part 'start_remote_session_response_model.g.dart';

@JsonSerializable()
class StartRemoteSessionResponseModel {
  final StartRemoteSessionDataModel data;
  final StartRemoteSessionAction? action;

  StartRemoteSessionResponseModel(this.data, this.action);

  factory StartRemoteSessionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$StartRemoteSessionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$StartRemoteSessionResponseModelToJson(this);

  static const _actionCaseRedirect = 'redirect';

  bool get requiresThreeDs => action?.case_ == _actionCaseRedirect && action?.value?.url != null;

  String? get threeDsRedirectUrl => action?.value?.url;
}

@JsonSerializable()
class StartRemoteSessionDataModel {
  final String id;
  final String status;

  StartRemoteSessionDataModel(this.id, this.status);

  factory StartRemoteSessionDataModel.fromJson(Map<String, dynamic> json) =>
      _$StartRemoteSessionDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$StartRemoteSessionDataModelToJson(this);
}

@JsonSerializable()
class StartRemoteSessionAction {
  @JsonKey(name: 'case')
  final String? case_;
  final StartRemoteSessionActionValue? value;

  StartRemoteSessionAction(this.case_, this.value);

  factory StartRemoteSessionAction.fromJson(Map<String, dynamic> json) =>
      _$StartRemoteSessionActionFromJson(json);

  Map<String, dynamic> toJson() => _$StartRemoteSessionActionToJson(this);
}

@JsonSerializable()
class StartRemoteSessionActionValue {
  final String? url;

  StartRemoteSessionActionValue(this.url);

  factory StartRemoteSessionActionValue.fromJson(Map<String, dynamic> json) =>
      _$StartRemoteSessionActionValueFromJson(json);

  Map<String, dynamic> toJson() => _$StartRemoteSessionActionValueToJson(this);
}
