// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_user_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MobileUserSummaryResponseModel _$MobileUserSummaryResponseModelFromJson(
  Map<String, dynamic> json,
) => MobileUserSummaryResponseModel(
  data: MobileUserSummaryModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MobileUserSummaryResponseModelToJson(
  MobileUserSummaryResponseModel instance,
) => <String, dynamic>{'data': instance.data};

MobileUserSummaryModel _$MobileUserSummaryModelFromJson(
  Map<String, dynamic> json,
) => MobileUserSummaryModel(
  totalMspCards: (json['totalMspCards'] as num?)?.toInt(),
  totalPaymentInstrumentsByIntent:
      json['totalPaymentInstrumentsByIntent'] == null
      ? null
      : PaymentInstrumentsByIntent.fromJson(
          json['totalPaymentInstrumentsByIntent'] as Map<String, dynamic>,
        ),
  canAddPaymentInstruments: json['canAddPaymentInstruments'] as bool?,
  features: json['features'] == null
      ? null
      : MobileFeaturesModel.fromJson(json['features'] as Map<String, dynamic>),
  remoteSessionEnabledPartyIds:
      (json['remoteSessionEnabledPartyIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$MobileUserSummaryModelToJson(
  MobileUserSummaryModel instance,
) => <String, dynamic>{
  'totalMspCards': instance.totalMspCards,
  'totalPaymentInstrumentsByIntent': instance.totalPaymentInstrumentsByIntent,
  'canAddPaymentInstruments': instance.canAddPaymentInstruments,
  'features': instance.features,
  'remoteSessionEnabledPartyIds': instance.remoteSessionEnabledPartyIds,
};

PaymentInstrumentsByIntent _$PaymentInstrumentsByIntentFromJson(
  Map<String, dynamic> json,
) => PaymentInstrumentsByIntent(
  mspRemoteSession: (json['msp_remote_session'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaymentInstrumentsByIntentToJson(
  PaymentInstrumentsByIntent instance,
) => <String, dynamic>{'msp_remote_session': instance.mspRemoteSession};

MobileFeaturesModel _$MobileFeaturesModelFromJson(Map<String, dynamic> json) =>
    MobileFeaturesModel(
      piMigrationP1: json['pi_migration_p1'] == null
          ? null
          : MobileFeatureEnabled.fromJson(
              json['pi_migration_p1'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MobileFeaturesModelToJson(
  MobileFeaturesModel instance,
) => <String, dynamic>{'pi_migration_p1': instance.piMigrationP1};

MobileFeatureEnabled _$MobileFeatureEnabledFromJson(
  Map<String, dynamic> json,
) => MobileFeatureEnabled(enabled: json['enabled'] as bool?);

Map<String, dynamic> _$MobileFeatureEnabledToJson(
  MobileFeatureEnabled instance,
) => <String, dynamic>{'enabled': instance.enabled};
