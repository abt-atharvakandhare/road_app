import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/data/model/cards/cards_response_model.dart';
import 'package:road_mobile/data/model/cards/charging_authorizations_model.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnderlyingCardType {
  creditCard,
  rfidCard;

  String get chargePaymentType {
    switch (this) {
      case UnderlyingCardType.creditCard:
        return 'PSP_PREAUTH';
      case UnderlyingCardType.rfidCard:
        return 'TOKEN';
    }
  }

  static UnderlyingCardType? fromString(String? value) {
    switch (value) {
      case 'PSP_PREAUTH':
        return UnderlyingCardType.creditCard;
      case 'TOKEN':
        return UnderlyingCardType.rfidCard;
      default:
        return null;
    }
  }
}

/// Abstract container for both RfidCards and PaymentCards.
class UnifiedPaymentCards {
  List<UnifiedPaymentCard> paymentCards;

  UnifiedPaymentCards(
      {required List<RfidCardModel>? rfidCards, required List<PaymentInstrumentModel>? creditCards})
      : paymentCards = [] {
    if (rfidCards != null) {
      paymentCards.addAll(rfidCards.map((e) => UnifiedPaymentCard(rfidCard: e)).toList());
    }

    if (creditCards != null) {
      paymentCards.addAll(creditCards.map((e) => UnifiedPaymentCard(paymentCard: e)).toList());
    }
  }

  /// Finds the card backing an active charging session.
  ///
  /// Legacy sessions are linked via [tokenId] (matches `paymentCard.tokenId` or
  /// `rfidCard.token.id`). New PayBridge-backed sessions instead carry a
  /// [paymentId] which is the PayBridge payment-instrument id — this matches
  /// `paymentCard.id` since PayBridge instruments don't expose a `tokenId`.
  UnifiedPaymentCard? getCardWithTokenId({String? tokenId, String? paymentId}) {
    return paymentCards.firstWhereOrNull((element) =>
        (paymentId != null && element.paymentCard?.id == paymentId) ||
        (tokenId != null && element.paymentCard?.tokenId == tokenId) ||
        (tokenId != null && element.rfidCard?.token?.id == tokenId));
  }

  UnifiedPaymentCard? get defaultCard {
    final storedCardId = getIt<SharedPreferences>().getString('defaultCardId');
    if (storedCardId == null) {
      return paymentCards.firstWhereOrNull((element) => element.paymentCard != null);
    }

    final cardParts = storedCardId.split(':');
    if (cardParts.length != 2) {
      return null;
    }

    final storedCardType = cardParts[0];
    final cardId = cardParts[1];

    if (storedCardType == 'rfid') {
      return paymentCards.firstWhereOrNull((element) => element.rfidCard?.id == cardId);
    }

    if (storedCardType == 'credit') {
      return paymentCards.firstWhereOrNull((element) => element.paymentCard?.id == cardId);
    }

    return null;
  }

  void setDefaultCard(UnifiedPaymentCard card) {
    if (card.rfidCard != null) {
      getIt<SharedPreferences>().setString('defaultCardId', 'rfid:${card.rfidCard!.id}');
      return;
    }

    if (card.paymentCard != null) {
      getIt<SharedPreferences>().setString('defaultCardId', 'credit:${card.paymentCard!.id}');
      return;
    }
  }

  UnifiedPaymentCards get filteredByActive {
    final filtered = UnifiedPaymentCards(rfidCards: null, creditCards: null);
    filtered.paymentCards.addAll(paymentCards.where((element) =>
        element.rfidCard?.token?.isActive == true || element.paymentCard != null));
    return filtered;
  }
}

class UnifiedPaymentCard {
  RfidCardModel? rfidCard;
  PaymentInstrumentModel? paymentCard;

  UnifiedPaymentCard({this.rfidCard, this.paymentCard}) {
    int supportedMethods = 0;
    if (rfidCard != null) supportedMethods++;
    if (paymentCard != null) supportedMethods++;

    assert((supportedMethods == 1));
  }

  UnderlyingCardType get underlyingCardType {
    if (rfidCard != null) return UnderlyingCardType.rfidCard;
    if (paymentCard != null) return UnderlyingCardType.creditCard;

    assert(false, 'No underlying card type found');
    throw Exception('No underlying card type found');
  }

  String? get startChargeTokenId {
    assert(rfidCard != null || paymentCard != null);
    return rfidCard?.token?.id;
  }

  String? get startChargePaymentInstrumentId {
    assert(rfidCard != null || paymentCard != null);
    return paymentCard?.id;
  }

  String? visibleCardType(BuildContext context) {
    assert(rfidCard != null || paymentCard != null);
    if (rfidCard != null) return AppLocalizations.of(context)!.chargeCard;
    if (paymentCard != null) {
      switch (paymentCard!.card?.scheme.toLowerCase()) {
        case 'apple-pay':
          return 'Apple Pay';
        case 'google-pay':
          return 'Google Pay';
      }
      return paymentCard!.card?.scheme.capitalized ?? '-';
    }

    return null;
  }

  String? get logoImageAssetPath {
    if (rfidCard != null) {
      return 'assets/icons/road_charge_card_logo.svg';
    }

    switch (paymentCard?.card?.scheme.toLowerCase()) {
      case 'mastercard':
        return 'assets/icons/credit_card_mastercard.svg';
      case 'visa':
        return 'assets/icons/credit_card_visa.svg';
      case 'apple-pay':
        return 'assets/icons/apple_pay_logo.svg';
      case 'google-pay':
        return 'assets/icons/google_pay_logo.svg';
    }

    return null;
  }

  String visibleCardDescription(BuildContext context) {
    assert(rfidCard != null || paymentCard != null);
    if (rfidCard != null) {
      return rfidCard!.nameOnCard ?? '-';
    }

    if (paymentCard != null) {
      return '•••• •••• •••• ${paymentCard!.card?.last4Digits ?? '••••'}';
    }

    return '-';
  }
}
