import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/widgets/switch_item.dart';

import '_helpers/scenario.dart';
import '_helpers/toggle.dart';

// Turn the master "All" switch OFF and assert every per-type switch cascades OFF.
// Then revert (master back ON) so the account is left fully enabled.
//
// This is the inverse of notifications_per_type_toggle_test: that test turns
// one type off and watches the master follow; this test turns the master off and
// watches the types follow. The cascade is immediate because
// `_emitOptimisticState(AllItems(), false)` sets every item to false in a single
// emit (notifications_cubit.dart line ~251), followed by an async backend sync
// that re-fetches state and confirms. We therefore poll the first per-type switch
// until it reads false, giving the server round-trip time to settle.
//
// Run with:
//   patrol test --flavor eflux \
//     --target integration_test/notifications_master_off_test.dart \
//     --dart-define=TEST_EMAIL=ray+uk3@road.io \
//     --dart-define=TEST_PASSWORD=secret

void main() {
  e2eTest(
    'master All switch OFF cascades every per-type switch to OFF, then reverts',
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
      // SwitchItem[1] is the first per-type row ("Charging Session Started").
      // Indexing is safe here because waitUntilVisible above confirmed at least
      // one SwitchItem is in the tree; the screen always renders master + all
      // types together under the same shimmer, so both indices are valid once
      // any SwitchItem is visible.
      final masterSwitch = $(SwitchItem).at(0).$(Switch);
      final firstTypeSwitch = $(SwitchItem).at(1).$(Switch);

      // --- Normalise: ensure master is ON (types are all on) ---
      // This makes the starting state deterministic regardless of what a
      // previous test run left behind. grantsPermissionWhenEnabled handles the
      // Android POST_NOTIFICATIONS dialog if it appears.
      await setSwitch($, masterSwitch, on: true, grantsPermissionWhenEnabled: true);
      expect(
        readSwitch(masterSwitch),
        isTrue,
        reason: 'master switch must be on before the cascade test',
      );

      // With master ON every type is on; the first per-type switch reflects that.
      expect(
        readSwitch(firstTypeSwitch),
        isTrue,
        reason: 'first per-type switch should be on after master is turned on',
      );

      // --- Core assertion: master OFF → all per-type switches OFF ---
      // `turnNotificationsOff(allItems)` emits an optimistic state that sets
      // every item to false in one go (notifications_cubit.dart ~L251), then
      // fires a backend sync. The optimistic emit is synchronous from the
      // cubit's perspective but crosses a pump boundary from the tester's
      // perspective, so we rely on setSwitch's internal poll to wait for the
      // master widget to reflect its new value. The first per-type switch is
      // polled separately below for the same reason.
      await setSwitch($, masterSwitch, on: false);
      expect(
        readSwitch(masterSwitch),
        isFalse,
        reason: 'master switch should be off after being turned off',
      );

      // Poll the first per-type switch until it reads false, giving the
      // optimistic emit and any in-flight backend re-fetch time to propagate.
      // A 10-second deadline is generous — the optimistic emit is near-instant,
      // but the subsequent _getNotificationTopicStates() server call can add a
      // few seconds on a slow connection.
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (DateTime.now().isBefore(deadline)) {
        if (readSwitch(firstTypeSwitch) == false) break;
        await $.tester.pump(const Duration(milliseconds: 200));
      }

      expect(
        readSwitch(firstTypeSwitch),
        isFalse,
        reason:
            'first per-type switch should be off after master is turned off '
            '(cascade via _emitOptimisticState(allItems, false))',
      );
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should surface after turning master off',
      );

      // --- Revert: master back ON so the account is left fully enabled ---
      // This makes the test idempotent: re-runs start with the same state and
      // the notifications_per_type_toggle_test.dart (which also normalises via
      // master-on first) continues to work correctly.
      await setSwitch($, masterSwitch, on: true, grantsPermissionWhenEnabled: true);
      expect(
        readSwitch(masterSwitch),
        isTrue,
        reason: 'master switch should be on after revert',
      );
    },
  );
}
