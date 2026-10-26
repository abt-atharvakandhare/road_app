// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_charging_values_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentChargingValuesResponseModel _$CurrentChargingValuesResponseModelFromJson(
  Map<String, dynamic> json,
) => CurrentChargingValuesResponseModel(
  data: CurrentChargingValues.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CurrentChargingValuesResponseModelToJson(
  CurrentChargingValuesResponseModel instance,
) => <String, dynamic>{'data': instance.data};

CurrentChargingValues _$CurrentChargingValuesFromJson(
  Map<String, dynamic> json,
) => CurrentChargingValues(
  costCurrentTotal: (json['costCurrentTotal'] as num?)?.toInt() ?? 0,
  energy: (json['energy'] as num?)?.toInt() ?? 0,
  stateOfCharge: (json['stateOfCharge'] as num?)?.toInt(),
);

Map<String, dynamic> _$CurrentChargingValuesToJson(
  CurrentChargingValues instance,
) => <String, dynamic>{
  'costCurrentTotal': instance.costCurrentTotal,
  'energy': instance.energy,
  'stateOfCharge': instance.stateOfCharge,
};
