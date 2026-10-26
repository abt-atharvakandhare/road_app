import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';

part 'charging_sessions_response_model.g.dart';

@JsonSerializable()
class ChargingSessionsResponseModel {
  final List<ChargingSessionModel> data;
  // final MetaModel? meta;

  ChargingSessionsResponseModel({
    required this.data,
    // required this.meta,
  });

  ChargingSessionModel? get pendingOrActiveSession => data.firstWhereOrNull((element) {
        log('Session status: ${element.status}');
        return element.status == 'ACTIVE' || element.status == 'STARTING' || element.status == 'PENDING';
      });

  ChargingSessionModel? sessionWithId(String id) {
    return data.firstWhereOrNull((element) => element.id == id);
  }

  factory ChargingSessionsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ChargingSessionsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChargingSessionsResponseModelToJson(this);
}

@JsonSerializable()
class ChargingSessionModel {
  final String id;
  final LocationModel? location;
  final String? locationId;
  final String? status; // COMPLETED, STARTING, STOPPING, ACTIVE, PENDING
  final DateTime createdAt;
  final DateTime? stopRequestedAt;
  final MspSessionModel? mspSession;
  final String? tokenId;
  final ActiveSession? activeSession;
  final ExternalPaymentModel? externalPayment;

  ChargingSessionModel(
    this.id,
    this.location,
    this.locationId,
    this.status,
    this.createdAt,
    this.stopRequestedAt,
    this.mspSession,
    this.tokenId,
    this.activeSession,
    this.externalPayment,
  );

  factory ChargingSessionModel.fromJson(Map<String, dynamic> json) => _$ChargingSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChargingSessionModelToJson(this);

  String get activeSessionkwhUsed =>
      '${activeSession?.kwh.toStringAsFixed(1) ?? mspSession?.kwh.toStringAsFixed(1) ?? '0'} kWh';

  /// Assuming missed slots are dropped
  int get idealTimerPollInterval {
    switch (status) {
      case 'STARTING':
      case 'STOPPING':
      case 'PENDING':
        return 2;
      default:
        return 30;
    }
  }
}

/// PayBridge-side payment details attached to a remote session.
@JsonSerializable()
class ExternalPaymentModel {
  final String? paymentMethod;
  final String? displayIdentifier;

  ExternalPaymentModel({
    this.paymentMethod,
    this.displayIdentifier,
  });

  factory ExternalPaymentModel.fromJson(Map<String, dynamic> json) => _$ExternalPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalPaymentModelToJson(this);
}

@JsonSerializable()
class ActiveSession {
  final String id;
  final double kwh;
  final DateTime startedAt;
  final String status;

  ActiveSession(this.id, this.kwh, this.startedAt, this.status);

  factory ActiveSession.fromJson(Map<String, dynamic> json) => _$ActiveSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveSessionToJson(this);
}

@JsonSerializable()
class LocationModel {
  final String id;
  final String address;

  LocationModel(this.id, this.address);

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

@JsonSerializable()
class MspSessionModel {
  final String currency;
  final double durationSeconds;
  final double kwh;
  final PriceWithFX? priceWithFX;

  MspSessionModel(this.currency, this.durationSeconds, this.kwh, this.priceWithFX);

  factory MspSessionModel.fromJson(Map<String, dynamic> json) => _$MspSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MspSessionModelToJson(this);
}

@JsonSerializable()
class PriceWithFX {
  final String originalCurrency;
  final double originalAmountWithVAT;

  PriceWithFX(this.originalCurrency, this.originalAmountWithVAT);

  factory PriceWithFX.fromJson(Map<String, dynamic> json) => _$PriceWithFXFromJson(json);

  Map<String, dynamic> toJson() => _$PriceWithFXToJson(this);

  String get totalWithVat {
    final currencyFormat = NumberFormat.simpleCurrency(name: originalCurrency);
    return currencyFormat.formatRoundingMidUp(originalAmountWithVAT);
  }
}
