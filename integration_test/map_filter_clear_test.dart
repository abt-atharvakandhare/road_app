import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/map_filter_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Map filter CLEAR sub-flow test.
//
// Shape: boot onto staging → log in → tap Map tab → open filter screen →
// apply DC Chargers + Type 2 connector (same as map_filters_test) → assert
// badge count > 0 → re-open filter screen → tap "Clear filters" TextButton →
// assert DC Chargers Switch is back OFF → close screen → assert badge shows '0'.
//
// ──────────────────────────────────────────────────────────────────────────────
// CLEAR CONTROL
// ──────────────────────────────────────────────────────────────────────────────
// MapFilterScreen has a TextButton at the bottom of the scroll that calls
// _updateFilters with a fresh ChargingLocationFilters() (all defaults). We
// locate it by its widget type (TextButton) scoped to MapFilterScreen. The
// label string comes from Phrase at runtime so we do NOT match on it.
//
// ──────────────────────────────────────────────────────────────────────────────
// CLEARED-STATE ASSERTION
// ──────────────────────────────────────────────────────────────────────────────
// Two complementary checks, both avoiding runtime strings:
//
//   1. Re-open the filter screen and assert the DC Chargers Switch (at(1)) has
//      value `false` — the Switch widget's `value` getter reflects the live
//      ChargingLocationFilters state. A cleared DC Chargers filter means the
//      switch is OFF (its default).
//
//   2. After closing the re-opened filter screen (apply the cleared state),
//      assert the Badge label in InitialWidget reads '0', meaning no active
//      filters. We wait for the non-zero label to disappear first (badge update
//      is async), then assert '0' exists.
//
// ──────────────────────────────────────────────────────────────────────────────
// MARKER LIMITATION (read before modifying this test)
// ──────────────────────────────────────────────────────────────────────────────
// Charging-station markers are native Google Maps platform markers, NOT Flutter
// widgets. This test asserts ONLY on Flutter widgets. It does NOT verify that
// the map refreshed or that markers appeared/disappeared.
// ──────────────────────────────────────────────────────────────────────────────
//
// Account prerequisite: any logged-in staging account — no session data or
// special fixtures needed. Default account: ray+uk3@road.io.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'map filters: apply DC Chargers + connector, then clear, badge resets to 0',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // ── 1. Navigate to Map tab ──────────────────────────────────────────────
      //
      // noSettle: the live map never reaches idle. Wait for the search TextField
      // inside InitialWidget as the readiness signal.
      await tapTab($, AppTab.map);
      await $(ExploreRootScreen).waitUntilVisible();
      await $(InitialWidget).$(TextField).waitUntilVisible();

      // ── 2. Open the filter screen ───────────────────────────────────────────
      //
      // The filter entry is the second IconButton in InitialWidget (index 1).
      await $(InitialWidget).$(IconButton).at(1).waitUntilVisible();
      await $(InitialWidget).$(IconButton).at(1).tap();
      await $(MapFilterScreen).waitUntilVisible();
      await pause($); // observe: filter screen open

      // ── 3. Toggle "DC Chargers" switch ON ─────────────────────────────────
      //
      // DC Chargers is the 2nd switch (index 1):
      //   index 0 → Available Chargers
      //   index 1 → DC Chargers
      // Wait for the first switch to confirm the screen is fully rendered.
      await $(MapFilterScreen).$(Switch).waitUntilVisible();
      await $(MapFilterScreen).$(Switch).at(1).tap();

      // ── 4. Tap "Type 2 (Mennekes)" connector ──────────────────────────────
      //
      // MapFilterScreen body is a SingleChildScrollView; use scrollIntoView
      // (zero-momentum) to avoid iOS BouncingScrollPhysics overshoot.
      await scrollIntoView($, $('Type 2 (Mennekes)'));
      await $('Type 2 (Mennekes)').waitUntilVisible();
      await $('Type 2 (Mennekes)').tap();

      // ── 5. Close the filter screen (apply filters) ─────────────────────────
      //
      // PopScope.onPopInvokedWithResult → _applyFilters() → MapEvent.mapFiltersApplied.
      await $(MapFilterScreen).$(IconButton).$(Icons.close).waitUntilVisible();
      await $(MapFilterScreen).$(IconButton).$(Icons.close).tap();
      await waitUntilGone($, $(MapFilterScreen));
      await $(InitialWidget).waitUntilExists();
      await pause($); // observe: filters applied/cleared, badge on map

      // ── 6. Assert filters are active (badge count > 0) ─────────────────────
      //
      // The Badge is inside IgnorePointer — assert existence, not visibility.
      // Poll until the '0' label is gone (MapBloc updated the count asynchronously).
      await $(InitialWidget).$(Badge).waitUntilExists();
      await waitUntilGone($, $(InitialWidget).$(Badge).$('0'));
      expect(
        $(InitialWidget).$(Badge).$('0'),
        findsNothing,
        reason: 'Badge count must be > 0 after applying DC Chargers + Type 2 connector filters',
      );

      // ── 7. Re-open the filter screen ───────────────────────────────────────
      await $(InitialWidget).$(IconButton).at(1).waitUntilVisible();
      await $(InitialWidget).$(IconButton).at(1).tap();
      await $(MapFilterScreen).waitUntilVisible();
      await pause($); // observe: filter screen open

      // ── 8. Tap the "Clear filters" TextButton ─────────────────────────────
      //
      // MapFilterScreen renders a single TextButton at the bottom of the scroll
      // (after the connector and payment-method sections). It calls
      // _updateFilters(ChargingLocationFilters(...defaults...)), resetting all
      // toggles, connector selections, and the power slider. We locate it by
      // widget type — the label comes from Phrase at runtime so we avoid the
      // string. scrollIntoView ensures the TextButton is on screen (it sits
      // below the connector list which may require scrolling).
      await $(MapFilterScreen).$(Switch).waitUntilVisible();
      await scrollIntoView($, $(MapFilterScreen).$(TextButton));
      await $(MapFilterScreen).$(TextButton).waitUntilVisible();
      await $(MapFilterScreen).$(TextButton).tap();
      await pause($); // observe: filters cleared (toggles reset)

      // ── 9. Assert DC Chargers switch is now OFF ────────────────────────────
      //
      // After clear, ChargingLocationFilters defaults to isDcCharger=false.
      // The Switch at(1) renders with value=false. Patrol's Switch finder exposes
      // the widget's value; we read it from the widget tree directly.
      // We wait for the switch to be visible (clear rebuilds synchronously), then
      // check its value via the widget state.
      await $(MapFilterScreen).$(Switch).waitUntilVisible();
      final switchWidget = $.tester.widget<Switch>(
        $(MapFilterScreen).$(Switch).at(1).finder,
      );
      expect(
        switchWidget.value,
        isFalse,
        reason: 'DC Chargers Switch (index 1) must be OFF after clearing filters',
      );

      // ── 10. Close the filter screen (apply the cleared state) ──────────────
      await $(MapFilterScreen).$(IconButton).$(Icons.close).waitUntilVisible();
      await $(MapFilterScreen).$(IconButton).$(Icons.close).tap();
      await waitUntilGone($, $(MapFilterScreen));
      await $(InitialWidget).waitUntilExists();
      await pause($); // observe: filters applied/cleared, badge on map

      // ── 11. Assert badge resets to '0' (no active filters) ─────────────────
      //
      // MapBloc updates the active-filter count asynchronously after apply.
      // Wait until the '0' label actually appears, then assert it exists.
      // The Badge stays in the widget tree at all times (AnimatedContainer
      // collapses it to 0×0 when count=0 but it remains in the tree).
      //
      // NOTE: do NOT wait for an intermediate value to disappear here. The count
      // goes 2 → 0 (DC Chargers + connector both clear at once), so the badge
      // never renders '1'; a waitUntilGone('1') would pass instantly and race
      // the async apply. Polling for '0' to exist is the only correct gate.
      // waitUntilExists (not waitUntilVisible): the Badge sits inside an
      // IgnorePointer and is collapsed to 0×0 at count 0, so it is not
      // hit-testable.
      await $(InitialWidget).$(Badge).waitUntilExists();
      await $(InitialWidget).$(Badge).$('0').waitUntilExists();
      expect(
        $(InitialWidget).$(Badge).$('0'),
        findsOneWidget,
        reason: 'Badge label must read "0" after filters are cleared and applied',
      );
    },
  );
}
