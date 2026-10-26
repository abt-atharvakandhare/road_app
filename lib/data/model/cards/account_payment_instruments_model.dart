import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/cards/charging_authorizations_model.dart';

part 'account_payment_instruments_model.g.dart';

/// Response from `GET /1/accounts/self/account-payment-instruments`.
/// This is the PayBridge-backed listing endpoint. IDs returned here are valid
/// PayBridge payment-instrument IDs (usable for charging), unlike the legacy
/// `/1/users/me/payment-instruments` endpoint.
@JsonSerializable()
class AccountPaymentInstrumentsResponseModel {
  AccountPaymentInstrumentsResponseModel({required this.data});

  factory AccountPaymentInstrumentsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AccountPaymentInstrumentsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPaymentInstrumentsResponseModelToJson(this);

  List<AccountPaymentInstrumentModel> data;

  /// Adapts the PayBridge-shaped payload into the legacy model the UI already uses.
  /// The legacy model has more fields than PayBridge exposes; the extras are filled
  /// with sensible defaults (status = ACTIVE, pspReference/tokenId = '').
  PaymentInstrumentsResponseModel toPaymentInstrumentsResponse() {
    return PaymentInstrumentsResponseModel(
      data: data.map((pi) => pi.toPaymentInstrument()).toList(),
    );
  }
}

@JsonSerializable()
class AccountPaymentInstrumentModel {
  AccountPaymentInstrumentModel({
    required this.id,
    required this.paymentProvider,
    required this.paymentType,
    required this.paymentMethod,
    required this.displayIdentifier,
  });

  factory AccountPaymentInstrumentModel.fromJson(Map<String, dynamic> json) =>
      _$AccountPaymentInstrumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPaymentInstrumentModelToJson(this);

  String id;
  String paymentProvider;
  String paymentType;
  String paymentMethod;
  String displayIdentifier;

  PaymentInstrumentModel toPaymentInstrument() {
    // Digital wallets (google-pay / apple-pay) are stored payment instruments now.
    // We reuse CreditCardModel for their display so the existing UI path keeps working
    // — the `scheme` field ends up as `google-pay` / `apple-pay` which the icon layer
    // can branch on. Native card schemes (visa, mastercard, …) also flow through this.
    final hasCardLikeDisplay = paymentType == 'card' || paymentType == 'digital-wallet';
    return PaymentInstrumentModel(
      id: id,
      psp: paymentProvider,
      pspReference: '',
      status: 'ACTIVE',
      tokenId: null,
      type: paymentType,
      card: hasCardLikeDisplay
          ? CreditCardModel(
              last4Digits: displayIdentifier,
              scheme: paymentMethod,
            )
          : null,
    );
  }
}
