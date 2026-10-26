import 'package:json_annotation/json_annotation.dart';

part 'preauth_limits_model.g.dart';

@JsonSerializable()
class PreauthLimitsResponseModel {
  PreauthLimitsResponseModel({
    required this.data,
  });

  factory PreauthLimitsResponseModel.fromJson(Map<String, dynamic> json) => _$PreauthLimitsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PreauthLimitsResponseModelToJson(this);

  PreauthLimitsModel data;
}

@JsonSerializable()
class PreauthLimitsModel {
  PreauthLimitsModel({
    required this.currency,
    required this.defaultAmount,
  });

  factory PreauthLimitsModel.fromJson(Map<String, dynamic> json) => _$PreauthLimitsModelFromJson(json);

  Map<String, dynamic> toJson() => _$PreauthLimitsModelToJson(this);

  String currency;

  @JsonKey(name: 'default')
  int defaultAmount;
}
