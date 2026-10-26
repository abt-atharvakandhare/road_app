import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_destructive_confirmation_sheet.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Template: a "destructive action + assert" test. Boot onto staging, log in,
// navigate to Account → Remove Account, confirm the bottom sheet, and assert
// the removal request was submitted (pending snackbar + logged-out state).
//
// *** DRAFT ONLY — DO NOT RUN WITH A REAL OR REUSED ACCOUNT ***
//
// Running this test DELETES the account. The backend endpoint is
// POST /1/accounts/request-removal, which queues a permanent deletion (soft
// delete — the account is marked for removal but recoverable by support within
// the grace period). The AuthCubit immediately calls logout() after the request
// succeeds, so the app transitions to LoggedOut state.
//
// REQUIREMENTS:
//   • A DISPOSABLE staging account created solely for this test run.
//   • Do NOT pass ray+uk3@road.io or any account you care about.
//   • Build with:
//       --dart-define=TEST_EMAIL=<disposable@example.com>
//       --dart-define=TEST_PASSWORD=<password>
//   • Run on the eflux flavor (the Remove Account row is visible for all
//     flavors, but staging credentials are eflux-scoped).

void main() {
  e2eTest(
    'account deletion: confirm removal sheet, assert pending snackbar and logout',
    ($) async {
      requireCredentials();

      // DESTRUCTIVE: this requests removal of TEST_EMAIL's account. It SKIPS
      // unless explicitly opted in, so the shared full-suite run can never delete
      // the default test account. To run it, pass
      // --dart-define=RUN_ACCOUNT_DELETION=true with a DISPOSABLE TEST_EMAIL.
      if (!const bool.fromEnvironment('RUN_ACCOUNT_DELETION')) {
        logSkip('account_deletion: set --dart-define=RUN_ACCOUNT_DELETION=true '
            'with a disposable TEST_EMAIL to run this destructive test.');
        return;
      }

      await bootLoginEnrolled($);

      // Scroll the "Remove Account" row into view and tap it. AccountLinkWidget
      // rows are in a SingleChildScrollView; the row is below the fold. Use
      // scrollIntoView (programmatic, momentum-free) — scrollTo flings/overshoots
      // under iOS BouncingScrollPhysics. Scope the finder to the row widget
      // containing the label rather than the bare string (which appears in the
      // sheet title too).
      final removeAccountLink = $(AccountLinkWidget).containing('Remove Account');
      await scrollIntoView($, removeAccountLink);
      await removeAccountLink.tap(settlePolicy: SettlePolicy.noSettle);

      // The confirmation sheet (RMDestructiveConfirmationSheet) is a modal
      // bottom sheet. Wait for it to mount, then tap the destructive confirm
      // button (RMTextButton with text "Yes, remove account") inside the sheet.
      await $(RMDestructiveConfirmationSheet).waitUntilVisible();
      final confirmButton =
          $(RMDestructiveConfirmationSheet).$(RMTextButton);
      await confirmButton.tap(settlePolicy: SettlePolicy.noSettle);

      // Primary success assertion: the "Account removal is pending" snackbar
      // appears. AuthCubit.deleteAccount() shows this snackbar on didDelete==true
      // before calling logout(). Wait for the SnackBar widget to mount.
      await $(SnackBar).waitUntilVisible();
      expect(
        $(SnackBar).containing('Account removal is pending'),
        findsOneWidget,
        reason: 'a successful removal request shows the pending snackbar',
      );

      // Secondary assertion: logout() is called immediately after the request
      // succeeds, so the AuthCubit transitions to LoggedOut and the Account tab
      // re-renders with SignupNowWidget. Wait for it to appear.
      await $(SignupNowWidget).waitUntilVisible();
      expect(
        $(SignupNowWidget),
        findsOneWidget,
        reason:
            'deleteAccount() calls logout() on success, so the screen should show the logged-out state',
      );
    },
  );
}
