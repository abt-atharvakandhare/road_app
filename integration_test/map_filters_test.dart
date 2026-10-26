import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/map_filter_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Map filter sub-flow test.
//
// Shape: boot onto staging → log in → tap Map tab → wait for overlay chrome →
// tap filter button → open MapFilterScreen → toggle "DC Chargers" switch →
// scroll to Connector Type → tap "Type 2 (Mennekes)" → close (apply) → assert
// the active-filter badge on the filter button shows count ≥ 1.
//
// ──────────────────────────────────────────────────────────────────────────────
// MARKER LIMITATION (read before modifying this test)
// ──────────────────────────────────────────────────────────────────────────────
// Charging-station markers are native Google Maps platform markers, NOT Flutter
// widgets. Patrol drives the Flutter widget tree; it cannot see, count, or
// interact with native platform markers. Additionally, a live Google Map never
// reaches a "settled" idle frame — it continuously redraws. For both reasons:
//   • NEVER assert on marker presence, count, or map "results".
//   • NEVER call pumpAndSettle after entering the map tab (it would hang to
//     settleTimeout every time).
// This test asserts ONLY on Flutter widgets: the filter screen controls and the
// filter-count Badge widget in the InitialWidget overlay. It does NOT verify
// that the map refreshed or that any markers appeared/disappeared.
// ──────────────────────────────────────────────────────────────────────────────
//
// Active-filter indicator: in InitialWidget the filter button has a Stack with
// an AnimatedContainer wrapping a Badge. When activeFilterCount > 0 the Badge
// gains a non-zero size (18×18) and renders its label Text. We wait for the
// Badge to appear, then assert it exists.
//
// Account prerequisite: any logged-in staging account works — no session data
// or special fixtures needed. Default account: ray+uk3@road.io.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'map filters: toggle DC Chargers + connector type, apply, badge appears',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // ── 1. Navigate to Map tab ──────────────────────────────────────────────
      //
      // noSettle: the live map never reaches idle. Wait for the search TextField
      // inside InitialWidget (a real interactive widget) as the readiness signal.
      await tapTab($, AppTab.map);
      await $(ExploreRootScreen).waitUntilVisible();
      await $(InitialWidget).$(TextField).waitUntilVisible();

      // Baseline: no filters active yet — Badge should not be visible (it is
      // shrunk to 0×0 by AnimatedContainer). Use waitUntilExists on Badge rather
      // than waitUntilVisible, because a 0×0 Badge exists in the tree but has no
      // hit-testable size. We don't assert findsNothing because the badge widget
      // IS always in the tree; we just skip asserting on it here to keep baseline
      // simple (user could have had filters persisted from a prior run).

      // ── 2. Open the filter screen ───────────────────────────────────────────
      //
      // The filter entry is the second IconButton in InitialWidget (after the
      // nearest-stations list button). InitialWidget has exactly two IconButtons
      // at rest. Use .at(1) to target the filter one. waitUntilVisible confirms
      // the button is hit-testable before we tap.
      await $(InitialWidget).$(IconButton).at(1).waitUntilVisible();
      await $(InitialWidget).$(IconButton).at(1).tap();
      await $(MapFilterScreen).waitUntilVisible();
      await pause($); // observe: filter screen open

      // ── 3. Toggle "DC Chargers" switch ─────────────────────────────────────
      //
      // The "DC Chargers" Switch.adaptive is visible at the top of the filter
      // screen body — no scroll needed. The filter screen has several switches;
      // rather than .at(n) (fragile against future reordering), locate the switch
      // by finding the Text sibling in the same Row. We find the Row that contains
      // 'DC Chargers' and then tap the Switch inside it. Since InkWell wraps the
      // Row only for connector items (not toggle rows), we target Switch.adaptive
      // directly via the scoped tree. The Switch is an adaptive widget; on iOS it
      // renders as CupertinoSwitch, on Android as Material Switch — the Patrol $()
      // finder accepts the Switch type (Material side). To stay platform-agnostic
      // we find it as a Switch widget, which Flutter resolves at the widget level.
      //
      // DC Chargers is the 2nd switch (index 1):
      //   index 0 → Available Chargers
      //   index 1 → DC Chargers
      //   index 2 → (branded / remote charge / without fee — flavour-dependent)
      //
      // waitUntilVisible on the first switch confirms the screen is fully
      // rendered before we index.
      await $(MapFilterScreen).$(Switch).waitUntilVisible();
      await $(MapFilterScreen).$(Switch).at(1).tap();
      await pause($); // observe: DC Chargers toggled

      // ── 4. Scroll to "Connector Type" section, tap "Type 2 (Mennekes)" ─────
      //
      // MapFilterScreen body is a SingleChildScrollView so all children are built
      // even off-screen. scrollIntoView uses Scrollable.ensureVisible (zero
      // momentum) to avoid iOS BouncingScrollPhysics overshoot.
      //
      // 'Type 2 (Mennekes)' is the human-readable name from
      // ChargingConnectorTypes._allConnectors (index 1, connector id IEC_62196_T2).
      // It is rendered as a Text widget inside an InkWell row.
      await scrollIntoView($, $('Type 2 (Mennekes)'));
      await $('Type 2 (Mennekes)').waitUntilVisible();
      await $('Type 2 (Mennekes)').tap();
      await pause($); // observe: Type 2 connector selected

      // ── 5. Close the filter screen (triggers apply) ─────────────────────────
      //
      // The dismiss button is the IconButton(Icons.close) in the AppBar actions.
      // Scoped through IconButton: the screen can contain a SECOND Icons.close —
      // the remove icon on each selected-network chip (an InkWell, not an
      // IconButton) — whenever the account has network filters active. Tapping
      // the AppBar one calls Navigator.pop, which triggers the
      // PopScope.onPopInvokedWithResult callback → _applyFilters() →
      // MapEvent.mapFiltersApplied dispatched to MapBloc.
      await $(MapFilterScreen).$(IconButton).$(Icons.close).waitUntilVisible();
      await $(MapFilterScreen).$(IconButton).$(Icons.close).tap();
      await pause($); // observe: filter applied, badge on map

      // Wait for the filter screen to dismiss and InitialWidget to be back.
      // InitialWidget is a layout container (not hit-testable on its own) — assert
      // existence; the Badge below is the real hit-testable readiness signal.
      await $(InitialWidget).waitUntilExists();

      // ── 6. Assert active-filter badge appeared ──────────────────────────────
      //
      // InitialWidget wraps the filter IconButton's Badge in an IgnorePointer, so
      // the Badge is NEVER hit-testable — assert EXISTENCE, not visibility. The
      // Badge's label is Text('$activeFilterCount'); MapBloc updates the count
      // asynchronously after apply, so poll until the "0" label is gone (count
      // became > 0). Scope to InitialWidget so we can't match a stray Badge.
      await $(InitialWidget).$(Badge).waitUntilExists();
      await waitUntilGone($, $(InitialWidget).$(Badge).$('0'));
      expect(
        $(InitialWidget).$(Badge),
        findsOneWidget,
        reason: 'active-filter Badge should be present after applying DC Chargers + Type 2 connector filters',
      );

      // The Badge label is the count as text. With DC Chargers (1) + Type 2
      // connector (1) active the count is at least 2 (it may be higher if the
      // flavour adds a branded-charger filter by default). Assert the text is
      // not '0' — we don't pin the exact number as it's flavour-dependent.
      expect(
        $(InitialWidget).$(Badge).$('0'),
        findsNothing,
        reason: 'Badge count must be > 0 after applying filters',
      );
    },
  );
}
