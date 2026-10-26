// {
//   "data": {
//     "costCurrentTotal": 0,
//     "energy": 397,
//     "stateOfCharge": 80
//   }
// }

// Data model for the above json

import 'package:json_annotation/json_annotation.dart';

part 'current_charging_values_model.g.dart';

@JsonSerializable()
class CurrentChargingValuesResponseModel {
  final CurrentChargingValues data;

  CurrentChargingValuesResponseModel({
    required this.data,
  });

  factory CurrentChargingValuesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CurrentChargingValuesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentChargingValuesResponseModelToJson(this);
}

@JsonSerializable()
class CurrentChargingValues {
  @JsonKey(defaultValue: 0)
  final int costCurrentTotal;
  @JsonKey(defaultValue: 0)
  final int energy;

  /// State of charge percentage (0-100). Null when the charger doesn't report it
  /// (typical of AC chargers — SoC reporting is generally a DC-only feature). UI
  /// should hide the SoC display entirely rather than show a misleading 0%.
  final int? stateOfCharge;

  /// Session start time — not from API, supplied by the caller after decoding.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? sessionStartedAt;

  const CurrentChargingValues({
    required this.costCurrentTotal,
    required this.energy,
    this.stateOfCharge,
    this.sessionStartedAt,
  });

  factory CurrentChargingValues.fromJson(Map<String, dynamic> json) => _$CurrentChargingValuesFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentChargingValuesToJson(this);

  /// Returns a copy with [sessionStartedAt] replaced. Used after decoding JSON to attach
  /// the session start time (which isn't in the API payload).
  CurrentChargingValues withSessionStartedAt(DateTime? startedAt) => CurrentChargingValues(
        costCurrentTotal: costCurrentTotal,
        energy: energy,
        stateOfCharge: stateOfCharge,
        sessionStartedAt: startedAt,
      );

  Map<String, dynamic> toDictionary() {
    return {
      'costCurrentTotal': costCurrentTotal,
      'energy': energy,
      if (stateOfCharge != null) 'stateOfCharge': stateOfCharge,
      if (sessionStartedAt != null) 'sessionStartedAt': sessionStartedAt!.millisecondsSinceEpoch,
    };
  }
}
