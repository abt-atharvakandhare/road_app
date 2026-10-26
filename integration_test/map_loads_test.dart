import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/map_overlay_widget.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// P0 smoke test — map screen loads without crashing.
//
// Shape: boot onto staging → log in → tap Map tab → assert Flutter overlay
// chrome renders → assert no error dialog.
//
// ──────────────────────────────────────────────────────────────────────────────
// MARKER LIMITATION (read before modifying this test)
// ──────────────────────────────────────────────────────────────────────────────
// Charging-station markers are native Google Maps platform markers, NOT Flutter
// widgets. Patrol drives the Flutter widget tree; it cannot see, count, or
// interact with native platform markers. Additionally, a live Google Map never
// reaches a "settled" idle frame — it continuously redraws. For both reasons:
//   • NEVER assert on marker presence or count.
//   • NEVER call pumpAndSettle after entering the map tab (it would hang
//     to settleTimeout every time).
// Assert ONLY on Flutter widgets that belong to the overlay chrome:
//   ExploreRootScreen, MapOverlayWidget, InitialWidget, TextField (search bar),
//   Icons.search — all rendered immediately by the overlay bloc's Initial state.
// ──────────────────────────────────────────────────────────────────────────────
//
// Error dialog: ModalInfoDialogs.showErrorDialog renders a standard Material
// AlertDialog (see lib/ui/utils/widgets/rm_modal_info_dialog.dart). We assert
// AlertDialog findsNothing, which catches MapBloc / MapOverlayBloc auth errors
// that manifest as error dialogs on entry.
//
// Account prerequisite: any logged-in staging account works — no session data
// or special fixtures needed. Default account: ray+uk3@road.io.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'map loads: overlay chrome renders and no error dialog on entry',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Tap the Map tab. tapTab uses noSettle — the live map never reaches
      // idle, so we must NOT pumpAndSettle. Wait for a Flutter overlay widget
      // instead; Patrol's finder auto-waits up to existsTimeout (20 s).
      await tapTab($, AppTab.map);

      // Wait for the overlay root to mount. ExploreRootScreen is the outermost
      // Flutter widget for the map tab; its presence proves the tab transition
      // completed and the BLoC providers were set up without throwing.
      await $(ExploreRootScreen).waitUntilVisible();
      expect(
        $(ExploreRootScreen),
        findsOneWidget,
        reason: 'ExploreRootScreen should be visible after tapping the Map tab',
      );

      // MapOverlayWidget and InitialWidget are layout containers in the Stack —
      // they have no hit-testable RenderBox of their own, so waitUntilVisible
      // (which requires hit-testability) fails on them even though they're mounted.
      // The concrete readiness signal is the search TextField inside InitialWidget
      // (a real interactive widget on top of the map, built by
      // _buildBasicSearchBox); wait on THAT, and assert the containers' existence.
      await $(InitialWidget).$(TextField).waitUntilVisible();

      expect(
        $(MapOverlayWidget),
        findsOneWidget,
        reason: 'MapOverlayWidget should be mounted over the map',
      );

      // InitialWidget is the default overlay state (switches away only if the user
      // taps the search bar or a marker — neither happens here). Its presence
      // means the map reached a healthy idle state, not a loading or error state.
      expect(
        $(InitialWidget),
        findsOneWidget,
        reason: 'InitialWidget should be present (healthy idle overlay state)',
      );
      expect(
        $(InitialWidget).$(TextField),
        findsOneWidget,
        reason: 'search TextField should be visible in the map overlay',
      );

      // No error dialog: ModalInfoDialogs.showErrorDialog wraps its content in
      // a standard Material AlertDialog (both the real path and the debug
      // "kitten" path use AlertDialog). An error here indicates MapBloc or
      // MapOverlayBloc threw an auth/network error on entry.
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should be present after loading the map screen',
      );
    },
  );
}
