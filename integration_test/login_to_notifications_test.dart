import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/widgets/switch_item.dart';

import '_helpers/scenario.dart';
import '_helpers/toggle.dart';

// Credentials are injected via --dart-define so they never land in source.
// Run with:
//   patrol test --flavor eflux \
//     --target integration_test/login_to_notifications_test.dart \
//     --dart-define=TEST_EMAIL=you@example.com \
//     --dart-define=TEST_PASSWORD=secret

void main() {
  e2eTest(
    'login then toggle notifications',
    ($) async {
      requireCredentials();

      // Boots straight onto staging (seeded prefs), opens Account, logs in.
      await bootLoginEnrolled($);

      // Open Notifications with SettlePolicy.noSettle — the screen renders a
      // continuously-animating shimmer during the cubit's initial fetch, so a
      // default post-tap settle would hit the 30s settleTimeout. Wait for the
      // SwitchItem rows instead. Wait on the unindexed finder, not `.at(0)`:
      // while no rows are mounted `.at(0)` is empty and Patrol throws IndexError
      // instead of waiting; once any exist, `.at(0)` resolves cleanly.
      await $('Notifications').tap(settlePolicy: SettlePolicy.noSettle);
      await $(SwitchItem).waitUntilVisible();

      // First SwitchItem is the master "All Notifications" toggle.
      final masterSwitch = $(SwitchItem).at(0).$(Switch);

      // Normalise to OFF first — iOS can start ON (it persists the OS
      // notification permission and the account-level pref is server-side),
      // whereas Android's clearPackageData leaves it OFF. Then exercise the
      // turn-on path identically on both, granting the permission dialog.
      await setSwitch($, masterSwitch, on: false);
      expect(
        readSwitch(masterSwitch),
        isFalse,
        reason: 'master switch should be off before we exercise turning it on',
      );

      await setSwitch($, masterSwitch, on: true, grantsPermissionWhenEnabled: true);
      expect(
        readSwitch(masterSwitch),
        isTrue,
        reason: 'master switch should be on after tap + permission grant',
      );
      // NOTE: this checks Material AlertDialog, which does NOT match the app's
      // custom ModalInfoDialogs sheet — so the benign iOS-on-BrowserStack
      // "APNS token not set" error (BS resigns without the push entitlement)
      // doesn't fail the test. A test that needs real push can't run on BS.
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should surface when turning notifications on',
      );
    },
  );
}
