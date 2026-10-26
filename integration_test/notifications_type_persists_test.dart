import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/notifications_settings_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/widgets/switch_item.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';

import '_helpers/scenario.dart';
import '_helpers/toggle.dart';

// Asserts that toggling an individual per-type notification switch is
// persisted server-side and survives a full navigate-away + reopen cycle.
//
// Flow:
//   1. Normalise: master ON (so per-type switches are meaningful).
//   2. Read the current value of SwitchItem[1] (first per-type type,
//      "Charging Session Started").
//   3. Flip it to the opposite value via setSwitch.
//   4. Navigate BACK to the Account screen (AppBar back button).
//   5. Re-open Notifications (AccountLinkWidget row) — the cubit is freshly
//      created (NotificationsSettingsScreen.pushAsModal wraps a new BlocProvider),
//      so it always re-fetches from the server on open.
//   6. Poll SwitchItem[1] until it equals the flipped value, giving the
//      server round-trip time to propagate. Assert it persisted.
//   7. REVERT: flip the switch back to its original value so the account is
//      left exactly as found.
//
// Why this proves server-side persistence:
//   NotificationsSettingsScreen.pushAsModal creates a fresh NotificationsCubit
//   (via getIt<NotificationsCubit>()) wrapped in a new BlocProvider each time
//   the screen is pushed. The cubit's constructor calls
//   _getDeviceNotificationPermissions() → _getNotificationTopicStates(), which
//   GETs the current topic states from the backend. Any value we see on reopen
//   was therefore fetched fresh — not read from in-memory state.
//
// Account: ray+uk3@road.io.
// Run with:
//   patrol test --flavor eflux \
//     --target integration_test/notifications_type_persists_test.dart \
//     --dart-define=TEST_EMAIL=ray+uk3@road.io \
//     --dart-define=TEST_PASSWORD=secret

void main() {
  e2eTest(
    'per-type notification switch persists after navigate away and reopen',
    ($) async {
      requireCredentials();

      // Boot onto staging, open Account tab, log in.
      await bootLoginEnrolled($);

      // ── 1. Open Notifications ─────────────────────────────────────────────
      // The screen renders an animated shimmer during the initial fetch, so we
      // use noSettle and wait for the first SwitchItem row to appear (unindexed
      // wait — avoids IndexError before any rows are mounted).
      await $('Notifications').tap(settlePolicy: SettlePolicy.noSettle);
      await $(SwitchItem).waitUntilVisible();

      // ── 2. Normalise: master ON ───────────────────────────────────────────
      // SwitchItem[0] is the master "All Notifications" toggle.
      // Turning it ON writes all per-type topics to the server, giving us a
      // deterministic starting state regardless of what a previous run left.
      final masterSwitch = $(SwitchItem).at(0).$(Switch);
      await setSwitch($, masterSwitch, on: true, grantsPermissionWhenEnabled: true);
      expect(
        readSwitch(masterSwitch),
        isTrue,
        reason: 'master switch must be on before testing per-type persistence',
      );

      // ── 3. Read the starting value of SwitchItem[1] ───────────────────────
      // SwitchItem[1] is the first per-type row: "Charging Session Started"
      // (index 0 in state.items → StateOfChargeNotificationItem.chargingSessionStarted,
      // which follows the master SwitchItem in the Column). With the master ON,
      // every type is on — but we read rather than assume, so the revert is
      // always the exact inverse.
      final firstTypeSwitch = $(SwitchItem).at(1).$(Switch);
      final originalValue = readSwitch(firstTypeSwitch);
      expect(
        originalValue,
        isNotNull,
        reason: 'first per-type switch must be readable before flipping',
      );
      final flippedValue = !originalValue!;

      // ── 4. Flip the switch ────────────────────────────────────────────────
      // setSwitch taps if needed and polls until the widget reflects the target
      // value. The cubit emits an optimistic state immediately, then fires
      // _syncNotificationSetting → _sendNotificationSettingToBackend (PUT) +
      // _getNotificationTopicStates (GET re-fetch). The in-memory state settles
      // quickly; the server-side write is what we'll verify after reopen.
      await setSwitch($, firstTypeSwitch, on: flippedValue);
      expect(
        readSwitch(firstTypeSwitch),
        flippedValue,
        reason: 'first per-type switch should reflect flipped value immediately after tap',
      );

      // ── 5. Navigate BACK to Account ───────────────────────────────────────
      // NotificationsSettingsScreen is pushed via pushAsModal (MaterialPageRoute)
      // so its AppBar auto-generates a back button (Icons.arrow_back). Tapping
      // it pops the route and disposes the NotificationsCubit.
      await $(Icons.arrow_back).tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for the Notifications screen to leave the tree before we try to
      // interact with the Account screen. The route lingers briefly during the
      // pop transition.
      await waitUntilGone($, $(NotificationsSettingsScreen));

      // ── 6. Re-open Notifications ─────────────────────────────────────────
      // Tap the AccountLinkWidget row whose label contains 'Notifications'.
      // We scope to AccountLinkWidget (not bare text) to avoid false-matching
      // the heading text on the Account screen.
      final notificationsRow = $(AccountLinkWidget).containing('Notifications');
      await notificationsRow.waitUntilVisible();
      await notificationsRow.tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for the new NotificationsSettingsScreen to mount. The fresh cubit
      // begins a server fetch immediately; we wait for any SwitchItem to appear
      // (unindexed, same reason as above).
      await $(SwitchItem).waitUntilVisible();

      // ── 7. Assert persistence ─────────────────────────────────────────────
      // Re-bind the finders to the new screen instance. The fresh cubit re-fetches
      // from the server, so the value may not be readable immediately — poll until
      // it stabilises or the deadline is reached. A 15-second window is generous:
      // the PUT usually completes within 1-2s, and the GET re-fetch on the second
      // open adds another 1-2s on a slow connection.
      final reopenedFirstTypeSwitch = $(SwitchItem).at(1).$(Switch);
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (DateTime.now().isBefore(deadline)) {
        if (readSwitch(reopenedFirstTypeSwitch) == flippedValue) break;
        await $.tester.pump(const Duration(milliseconds: 200));
      }

      expect(
        readSwitch(reopenedFirstTypeSwitch),
        flippedValue,
        reason:
            'first per-type switch (Charging Session Started) should equal the '
            'flipped value ($flippedValue) after navigate-away + reopen, '
            'confirming the toggle was persisted server-side',
      );
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should surface during the persistence check',
      );

      // ── 8. Revert ─────────────────────────────────────────────────────────
      // Flip the switch back to its original value so the account ends in the
      // same state it started, making the test idempotent across runs.
      // We also restore the master switch: if originalValue was true, flipping
      // one type back on after it was off will not automatically restore master
      // to ON unless we explicitly set it — so we set master ON first (which
      // turns all types on), then the state matches what we found at the start.
      final reopenedMasterSwitch = $(SwitchItem).at(0).$(Switch);
      await setSwitch($, reopenedMasterSwitch, on: true, grantsPermissionWhenEnabled: true);
      await setSwitch($, reopenedFirstTypeSwitch, on: originalValue);
      expect(
        readSwitch(reopenedFirstTypeSwitch),
        originalValue,
        reason: 'first per-type switch should be reverted to original value ($originalValue)',
      );
    },
  );
}
