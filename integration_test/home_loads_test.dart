import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/home/home_root_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_action_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// P0 smoke test — home screen loads without crashing.
//
// Shape: boot onto staging → log in → tap Home tab → assert Flutter chrome
// renders → assert no error dialog.
//
// Prerequisite: logged-in staging account. Credentials via
// --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
// Default account: ray+uk3@road.io. No special data needed — the home screen
// renders unconditionally (it does not depend on sessions, payment methods,
// or nearest-station data).
//
// ──────────────────────────────────────────────────────────────────────────────
// NEAREST-STATIONS LOADER NOTE (read before modifying this test)
// ──────────────────────────────────────────────────────────────────────────────
// The home screen contains a NearestStationsScreen loader and a
// HomeScreenMapWidget that both animate continuously. For this reason:
//   • NEVER call pumpAndSettle anywhere in this test — it hangs to
//     settleTimeout every time.
//   • noSettle is active globally via e2eConfig (SettlePolicy.noSettle).
// Readiness is established by waiting on the 'Charge Now' Text widget, which
// is a concrete leaf widget rendered immediately by ChargeNowBloc's idle state.
// ──────────────────────────────────────────────────────────────────────────────
//
// Error dialog: ModalInfoDialogs.showErrorDialog renders a standard Material
// AlertDialog (see lib/ui/utils/widgets/rm_modal_info_dialog.dart). We assert
// AlertDialog findsNothing, which catches HomeCubit / ChargeNowBloc errors that
// manifest as error dialogs on entry.
//
// Does NOT verify:
//   • Live nearest-station data (NearestStationsScreen content).
//   • HomeScreenMapWidget map tiles (native platform content).
//   • The charging-in-progress state of the Charge Now button.

void main() {
  e2eTest(
    'home loads: chrome renders and no error dialog on entry',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // bootLoginEnrolled lands on the Account tab. Tap Home to switch.
      // tapTab uses noSettle — do NOT pumpAndSettle after this; the nearest-
      // stations loader keeps the frame pipeline busy indefinitely.
      await tapTab($, AppTab.home);

      // Wait for readiness on a concrete, hit-testable leaf widget.
      //
      // 'Charge Now' is a Text rendered by ChargeNowBloc's idle (no session)
      // state inside RMDecoratedActionButton → RMActionButton → ElevatedButton.
      // It renders immediately — no network fetch is needed for the idle state.
      // Scoping to HomeRootScreen avoids any other 'Charge Now' text that might
      // exist elsewhere (e.g. inside the ChargeNow modal if it were open).
      await $(HomeRootScreen).$('Charge Now').waitUntilVisible();

      // HomeRootScreen is the outermost Flutter widget for the Home tab.
      // Its presence proves the tab transition completed and BLoC providers
      // were set up without throwing.
      expect(
        $(HomeRootScreen),
        findsOneWidget,
        reason: 'HomeRootScreen should be visible after tapping the Home tab',
      );

      // RMDecoratedActionButton is the Charge Now action button — the primary
      // CTA on the home screen. It is always rendered (not gated on any fetch).
      expect(
        $(HomeRootScreen).$(RMDecoratedActionButton),
        findsOneWidget,
        reason: 'RMDecoratedActionButton (Charge Now) should be present on the home screen',
      );

      // The three RMInkwellButton shortcut rows (View Wallet, Explore Stations,
      // Highway Mode) are rendered unconditionally — no cubit fetch needed.
      // Three matching widgets confirms the full shortcut section mounted.
      expect(
        $(HomeRootScreen).$(RMInkwellButton),
        findsNWidgets(3),
        reason: 'three RMInkwellButton shortcut rows should be present (View Wallet, Explore Stations, Highway Mode)',
      );

      // No error dialog: ModalInfoDialogs.showErrorDialog wraps its content in
      // a standard Material AlertDialog. An error here indicates ChargeNowBloc
      // or another home-scoped cubit threw an auth/network error on entry.
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should be present after loading the home screen',
      );
    },
  );
}
