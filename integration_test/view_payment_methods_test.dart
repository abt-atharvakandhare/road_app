import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Template: a "logged-in view + assert" test. Boot straight onto staging,
// log in, navigate to the Wallet → Payments tab, assert the saved payment
// methods list loads.
//
// Prerequisite: a staging account with at least one saved payment method
// (a credit card / RFID card shown as an RMCardDisplayWidget row).
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'view payment methods: list loads and shows at least one saved method',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Wallet → Payments. The wallet TabBar opens on Sessions (index 0) by
      // default, so we must select the Payments tab. Its label is the unique
      // string 'Payments' (the screen header text is 'Payment methods' and the
      // page header is 'Wallet', so this finder is unambiguous).
      await tapTab($, AppTab.wallet);
      // Use noSettle: selecting Payments mounts the RMShimmerLoader, which never
      // settles during the fetch; a default pumpAndSettle would hang until the
      // settleTimeout. We wait on the destination row below instead.
      await $('Payments').tap(settlePolicy: SettlePolicy.noSettle);

      // The methods list renders behind a continuously-animating shimmer
      // (RMShimmerLoader) during PaymentMethodsCubit's initial fetch, so a
      // default pumpAndSettle would hit the settleTimeout. Wait for a saved-card
      // row to mount instead. (If the account has no saved methods the screen
      // shows an empty-state Text and this wait times out — that's the signal to
      // use an account with at least one payment method.)
      await $(RMCardDisplayWidget).waitUntilVisible();
      expect(
        $(RMCardDisplayWidget),
        findsWidgets,
        reason: 'account should have at least one saved payment method',
      );
    },
  );
}
