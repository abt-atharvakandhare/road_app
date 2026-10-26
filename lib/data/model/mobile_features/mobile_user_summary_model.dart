import 'package:json_annotation/json_annotation.dart';

part 'mobile_user_summary_model.g.dart';

@JsonSerializable()
class MobileUserSummaryResponseModel {
  MobileUserSummaryResponseModel({
    required this.data,
  });

  factory MobileUserSummaryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MobileUserSummaryResponseModelFromJson(json);

  final MobileUserSummaryModel data;

  Map<String, dynamic> toJson() => _$MobileUserSummaryResponseModelToJson(this);
}

@JsonSerializable()
class MobileUserSummaryModel {
  MobileUserSummaryModel({
    this.totalMspCards,
    this.totalPaymentInstrumentsByIntent,
    this.canAddPaymentInstruments,
    this.features,
    this.remoteSessionEnabledPartyIds,
  });

  factory MobileUserSummaryModel.fromJson(Map<String, dynamic> json) => _$MobileUserSummaryModelFromJson(json);

  final int? totalMspCards;
  final PaymentInstrumentsByIntent? totalPaymentInstrumentsByIntent;
  final bool? canAddPaymentInstruments;
  final MobileFeaturesModel? features;
  final List<String>? remoteSessionEnabledPartyIds;

  Map<String, dynamic> toJson() => _$MobileUserSummaryModelToJson(this);
}

@JsonSerializable()
class PaymentInstrumentsByIntent {
  PaymentInstrumentsByIntent({
    this.mspRemoteSession,
  });

  factory PaymentInstrumentsByIntent.fromJson(Map<String, dynamic> json) => _$PaymentInstrumentsByIntentFromJson(json);

  @JsonKey(name: 'msp_remote_session')
  final int? mspRemoteSession;

  Map<String, dynamic> toJson() => _$PaymentInstrumentsByIntentToJson(this);
}

@JsonSerializable()
class MobileFeaturesModel {
  MobileFeaturesModel({
    this.piMigrationP1,
  });

  factory MobileFeaturesModel.fromJson(Map<String, dynamic> json) => _$MobileFeaturesModelFromJson(json);

  @JsonKey(name: 'pi_migration_p1')
  final MobileFeatureEnabled? piMigrationP1;

  Map<String, dynamic> toJson() => _$MobileFeaturesModelToJson(this);
}

@JsonSerializable()
class MobileFeatureEnabled {
  MobileFeatureEnabled({
    this.enabled,
  });

  factory MobileFeatureEnabled.fromJson(Map<String, dynamic> json) => _$MobileFeatureEnabledFromJson(json);

  final bool? enabled;

  Map<String, dynamic> toJson() => _$MobileFeatureEnabledToJson(this);
}
