import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/widgets/switch_item.dart';

import '_helpers/scenario.dart';
import '_helpers/toggle.dart';

// Toggle an individual per-type notification switch and assert it changes.
//
// Account prerequisite: the test account must be able to reach the
// Notifications screen (no special notification state required — the per-type
// switch is targeted regardless of its starting value).
//
// The test turns the master "All" ON first (which turns every type on), then
// turns the first per-type switch OFF. Two assertions follow: the per-type switch
// reflects its new (off) value, AND the master "All" flips OFF — because
// state.allNotifications is computed as "all topics on" (notifications_cubit
// lines 128/255), it cannot stay true once any one type is off. No teardown: the
// per-type pref is left off; a re-run re-normalises via the master-on step.
//
// Run with:
//   patrol test --flavor eflux \
//     --target integration_test/notifications_per_type_toggle_test.dart \
//     --dart-define=TEST_EMAIL=ray+uk3@road.io \
//     --dart-define=TEST_PASSWORD=secret

void main() {
  e2eTest(
    'per-type notification switch toggles and reflects new value',
    ($) async {
      requireCredentials();

      // Boot onto staging, open Account tab, log in.
      await bootLoginEnrolled($);

      // Open the Notifications screen. The screen renders an animated shimmer
      // during initial fetch, so we use noSettle and wait for the first
      // SwitchItem row to appear (unindexed wait — avoids IndexError before any
      // rows are mounted).
      await $('Notifications').tap(settlePolicy: SettlePolicy.noSettle);
      await $(SwitchItem).waitUntilVisible();

      // SwitchItem[0] is the master "All Notifications" toggle.
      // Ensure it is ON before exercising a per-type switch so the backend
      // treats the per-type update as meaningful.
      final masterSwitch = $(SwitchItem).at(0).$(Switch);
      await setSwitch($, masterSwitch, on: true, grantsPermissionWhenEnabled: true);
      expect(
        readSwitch(masterSwitch),
        isTrue,
        reason: 'master switch must be on before testing a per-type switch',
      );

      // SwitchItem[1] is the first per-type row: "Charging Session Started".
      // It is rendered by the `state.items.map(...)` list (index 0 in that
      // list → StateOfChargeNotificationItem.chargingSessionStarted) which
      // follows the master SwitchItem in the Column, making it SwitchItem[1]
      // overall. Waiting on the unindexed finder (already done above) ensures
      // the rows are mounted before we index in.
      final firstTypeSwitch = $(SwitchItem).at(1).$(Switch);

      // Master is on, so every type starts on. Turn the first type OFF and assert
      // it reflects the new value — this is the core of the test.
      await setSwitch($, firstTypeSwitch, on: false);
      expect(
        readSwitch(firstTypeSwitch),
        isFalse,
        reason: 'per-type switch (Charging Session Started) should be off after toggle',
      );

      // Turning an individual type OFF must de-select the master "All" — it is
      // computed as "all topics on", so it can't remain true once one is off.
      expect(
        readSwitch(masterSwitch),
        isFalse,
        reason: 'master "All" should turn off once an individual type is off',
      );
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should surface after toggling a per-type switch',
      );
    },
  );
}
