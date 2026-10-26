// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorize_tokenization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorizeTokenizationResponseModel _$AuthorizeTokenizationResponseModelFromJson(
  Map<String, dynamic> json,
) => AuthorizeTokenizationResponseModel(
  data: AuthorizeTokenizationDataModel.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AuthorizeTokenizationResponseModelToJson(
  AuthorizeTokenizationResponseModel instance,
) => <String, dynamic>{'data': instance.data};

AuthorizeTokenizationDataModel _$AuthorizeTokenizationDataModelFromJson(
  Map<String, dynamic> json,
) => AuthorizeTokenizationDataModel(
  action: json['action'] == null
      ? null
      : AuthorizeTokenizationAction.fromJson(
          json['action'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AuthorizeTokenizationDataModelToJson(
  AuthorizeTokenizationDataModel instance,
) => <String, dynamic>{'action': instance.action};

AuthorizeTokenizationAction _$AuthorizeTokenizationActionFromJson(
  Map<String, dynamic> json,
) => AuthorizeTokenizationAction(
  actionCase: $enumDecodeNullable(
    _$ActionCaseEnumMap,
    json['case'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  value: json['value'] == null
      ? null
      : AuthorizeTokenizationActionValue.fromJson(
          json['value'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AuthorizeTokenizationActionToJson(
  AuthorizeTokenizationAction instance,
) => <String, dynamic>{
  'case': _$ActionCaseEnumMap[instance.actionCase],
  'value': instance.value,
};

const _$ActionCaseEnumMap = {
  ActionCase.authorized: 'authorized',
  ActionCase.redirect: 'redirect',
  ActionCase.paymentSessionAction: 'paymentSessionAction',
};

AuthorizeTokenizationActionValue _$AuthorizeTokenizationActionValueFromJson(
  Map<String, dynamic> json,
) => AuthorizeTokenizationActionValue(
  actionData: json['actionData'],
  paymentProviderReference: json['paymentProviderReference'] as String?,
);

Map<String, dynamic> _$AuthorizeTokenizationActionValueToJson(
  AuthorizeTokenizationActionValue instance,
) => <String, dynamic>{
  'actionData': instance.actionData,
  'paymentProviderReference': instance.paymentProviderReference,
};
