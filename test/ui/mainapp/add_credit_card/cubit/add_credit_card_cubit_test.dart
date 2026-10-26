import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/cards/authorize_tokenization_model.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_cubit.dart';

/// Regression tests for DRI-792 (Google Pay "unknown payment status: Authorized").
///
/// The two Checkout SDKs accept different success statuses: iOS's Flow SDK wants
/// "Authorized", Android's Components SDK only accepts the BE's "Approved" and
/// throws on "Authorized". [AddCreditCardCubit.normaliseTokenizationResult] must
/// emit the right dialect per platform. The bug only surfaces on a frictionless
/// (SCA-exempt) authorize — the `authorized` case, or `paymentSessionAction` with
/// status "Approved" — which can't be reproduced against a 3DS-enforcing sandbox,
/// so it's pinned down here instead.
void main() {
  AuthorizeTokenizationAction authorized(String reference) => AuthorizeTokenizationAction(
        actionCase: ActionCase.authorized,
        value: AuthorizeTokenizationActionValue(paymentProviderReference: reference),
      );

  AuthorizeTokenizationAction paymentSessionAction(Map<String, dynamic> actionData) =>
      AuthorizeTokenizationAction(
        actionCase: ActionCase.paymentSessionAction,
        value: AuthorizeTokenizationActionValue(actionData: actionData),
      );

  group('normaliseTokenizationResult — frictionless `authorized` case', () {
    test('Android gets "Approved" (Components SDK rejects "Authorized")', () {
      final result = AddCreditCardCubit.normaliseTokenizationResult(
        authorized('pay_123'),
        'googlepay',
        isIOS: false,
      );

      expect(result['status'], 'Approved');
      expect(result['id'], 'pay_123');
      expect(result['type'], 'googlepay');
    });

    test('iOS gets "Authorized" (Flow SDK vocabulary)', () {
      final result = AddCreditCardCubit.normaliseTokenizationResult(
        authorized('pay_123'),
        'googlepay',
        isIOS: true,
      );

      expect(result['status'], 'Authorized');
    });

    test('type falls back to "card" when null', () {
      final result = AddCreditCardCubit.normaliseTokenizationResult(
        authorized('pay_123'),
        null,
        isIOS: false,
      );

      expect(result['type'], 'card');
    });
  });

  group('normaliseTokenizationResult — `paymentSessionAction` case', () {
    test('Android keeps the BE\'s "Approved" untouched', () {
      final result = AddCreditCardCubit.normaliseTokenizationResult(
        paymentSessionAction({'id': 'pay_1', 'status': 'Approved', 'type': 'googlepay'}),
        'googlepay',
        isIOS: false,
      );

      expect(result['status'], 'Approved');
    });

    test('iOS remaps "Approved" to "Authorized"', () {
      final result = AddCreditCardCubit.normaliseTokenizationResult(
        paymentSessionAction({'id': 'pay_1', 'status': 'Approved', 'type': 'googlepay'}),
        'googlepay',
        isIOS: true,
      );

      expect(result['status'], 'Authorized');
    });

    test('"Action Required" (3DS) is preserved on both platforms', () {
      final actionData = {
        'id': 'pay_1',
        'status': 'Action Required',
        'type': 'card',
        'action': {'type': '3ds', 'url': 'https://example/3ds'},
      };

      for (final isIOS in [true, false]) {
        final result = AddCreditCardCubit.normaliseTokenizationResult(
          paymentSessionAction(Map<String, dynamic>.from(actionData)),
          'card',
          isIOS: isIOS,
        );

        expect(result['status'], 'Action Required', reason: 'isIOS=$isIOS');
        expect(result['action'], isNotNull, reason: 'isIOS=$isIOS');
      }
    });

    test('a JSON-string actionData is decoded and passed through', () {
      final result = AddCreditCardCubit.normaliseTokenizationResult(
        paymentSessionAction({'status': 'Action Required'}),
        'card',
        isIOS: false,
      );

      expect(result['status'], 'Action Required');
    });
  });

  group('normaliseTokenizationResult — passthrough cases', () {
    test('null action yields an empty map', () {
      expect(
        AddCreditCardCubit.normaliseTokenizationResult(null, 'card', isIOS: false),
        isEmpty,
      );
    });

    test('redirect/undefined case is passed through untouched', () {
      final action = AuthorizeTokenizationAction(
        actionCase: ActionCase.redirect,
        value: AuthorizeTokenizationActionValue(actionData: {'url': 'https://example/redirect'}),
      );

      final result = AddCreditCardCubit.normaliseTokenizationResult(action, 'card', isIOS: false);

      expect(result['url'], 'https://example/redirect');
    });
  });
}
