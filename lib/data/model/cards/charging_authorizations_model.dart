import 'package:json_annotation/json_annotation.dart';

part 'charging_authorizations_model.g.dart';

@JsonSerializable()
class PaymentInstrumentsResponseModel {
  List<PaymentInstrumentModel> data;

  PaymentInstrumentsResponseModel({required this.data});

  factory PaymentInstrumentsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentInstrumentsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInstrumentsResponseModelToJson(this);

  PaymentInstrumentsResponseModel get removingAdhocTokens {
    return PaymentInstrumentsResponseModel(
        data: data.where((element) => element.type != 'adhoc-token' && element.card != null).toList());
  }
}

@JsonSerializable()
class PaymentInstrumentModel {
  String id;
  String psp;
  String pspReference;
  String status;
  String? tokenId;
  String type;
  CreditCardModel? card; // We do not get this for ad-hoc (Apple/Google Pay) cards. BE needs this to be here though.

  PaymentInstrumentModel(
      {required this.id,
      required this.psp,
      required this.pspReference,
      required this.status,
      required this.tokenId,
      required this.type,
      this.card});

  factory PaymentInstrumentModel.fromJson(Map<String, dynamic> json) => _$PaymentInstrumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInstrumentModelToJson(this);
}

@JsonSerializable()
class CreditCardModel {
  String last4Digits;
  String scheme;

  CreditCardModel({required this.last4Digits, required this.scheme});

  factory CreditCardModel.fromJson(Map<String, dynamic> json) => _$CreditCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreditCardModelToJson(this);
}
