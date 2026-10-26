import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'authorize_tokenization_model.g.dart';

@JsonSerializable()
class AuthorizeTokenizationResponseModel {
  AuthorizeTokenizationResponseModel({required this.data});

  factory AuthorizeTokenizationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorizeTokenizationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizeTokenizationResponseModelToJson(this);

  AuthorizeTokenizationDataModel data;
}

@JsonSerializable()
class AuthorizeTokenizationDataModel {
  AuthorizeTokenizationDataModel({
    this.action,
  });

  factory AuthorizeTokenizationDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorizeTokenizationDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizeTokenizationDataModelToJson(this);

  AuthorizeTokenizationAction? action;
}

enum ActionCase {
  @JsonValue('authorized')
  authorized,
  @JsonValue('redirect')
  redirect,
  @JsonValue('paymentSessionAction')
  paymentSessionAction,
}

@JsonSerializable()
class AuthorizeTokenizationAction {
  AuthorizeTokenizationAction({
    required this.actionCase,
    this.value,
  });

  factory AuthorizeTokenizationAction.fromJson(Map<String, dynamic> json) =>
      _$AuthorizeTokenizationActionFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizeTokenizationActionToJson(this);

  @JsonKey(name: 'case', unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  ActionCase? actionCase;
  AuthorizeTokenizationActionValue? value;
}

@JsonSerializable()
class AuthorizeTokenizationActionValue {
  AuthorizeTokenizationActionValue({this.actionData, this.paymentProviderReference});

  factory AuthorizeTokenizationActionValue.fromJson(Map<String, dynamic> json) =>
      _$AuthorizeTokenizationActionValueFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizeTokenizationActionValueToJson(this);

  /// Present when case == paymentSessionAction. Can be a JSON string or object;
  /// always access via [actionDataMap].
  dynamic actionData;

  /// Present when case == authorized. The `pay_xxx` id that would otherwise come
  /// from actionData.id in the paymentSessionAction case.
  String? paymentProviderReference;

  Map<String, dynamic> get actionDataMap {
    if (actionData is String) return json.decode(actionData as String) as Map<String, dynamic>;
    if (actionData is Map) return actionData as Map<String, dynamic>;
    return {};
  }
}
