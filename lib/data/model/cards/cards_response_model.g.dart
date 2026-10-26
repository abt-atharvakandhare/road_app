// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RfidCardsResponseModel _$RfidCardsResponseModelFromJson(
  Map<String, dynamic> json,
) => RfidCardsResponseModel(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => RfidCardModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : MetaModel.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RfidCardsResponseModelToJson(
  RfidCardsResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

RfidCardModel _$RfidCardModelFromJson(Map<String, dynamic> json) =>
    RfidCardModel(
        id: json['id'] as String,
        nameOnCard: json['nameOnCard'] as String?,
        userId: json['userId'] as String,
        token: json['token'] == null
            ? null
            : TokenModel.fromJson(json['token'] as Map<String, dynamic>),
      )
      ..billingPlan = json['billingPlan'] == null
          ? null
          : BillingPlan.fromJson(json['billingPlan'] as Map<String, dynamic>);

Map<String, dynamic> _$RfidCardModelToJson(RfidCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameOnCard': instance.nameOnCard,
      'userId': instance.userId,
      'token': instance.token,
      'billingPlan': instance.billingPlan,
    };

TokenModel _$TokenModelFromJson(Map<String, dynamic> json) => TokenModel(
  id: json['id'] as String?,
  isActive: json['isActive'] as bool?,
  visualNumber: json['visualNumber'] as String?,
);

Map<String, dynamic> _$TokenModelToJson(TokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isActive': instance.isActive,
      'visualNumber': instance.visualNumber,
    };

BillingPlan _$BillingPlanFromJson(Map<String, dynamic> json) =>
    BillingPlan(name: json['name'] as String);

Map<String, dynamic> _$BillingPlanToJson(BillingPlan instance) =>
    <String, dynamic>{'name': instance.name};
