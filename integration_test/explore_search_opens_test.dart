import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/map_overlay_widget.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/autocomplete_widget.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Explore-search open/dismiss integration test.
//
// Shape: boot onto staging → log in → tap Map tab → wait for overlay chrome →
// tap the search TextField → assert AutocompleteWidget mounts → tap the close
// button inside AutocompleteWidget → assert AutocompleteWidget is gone and
// InitialWidget is back.
//
// ──────────────────────────────────────────────────────────────────────────────
// WHAT THIS TEST COVERS
// ──────────────────────────────────────────────────────────────────────────────
// MapOverlayWidget drives the overlay with a BLoC state machine:
//
//   Initial ──(focus TextField)──► TypeAheadSearchResults ──(tap close)──► Initial
//
// When the TextField gains focus, _MapOverlayWidgetState._handleFocusChange
// dispatches MapOverlayEvent.searchQuery("") — an empty query — which
// transitions the bloc to TypeAheadSearchResults(results: null). The bloc does
// NOT call the Places API until the query is non-empty; this test stops before
// that. AutocompleteWidget renders immediately (its build is synchronous once the
// state changes).
//
// Dismissal: AutocompleteWidget has a trailing IconButton(Icons.close) that
// dispatches MapOverlayEvent.resetToInitial(), returning the overlay to Initial
// and re-mounting InitialWidget.
//
// ──────────────────────────────────────────────────────────────────────────────
// WIDGET-TREE NOTES
// ──────────────────────────────────────────────────────────────────────────────
// AutocompleteWidget is a StatelessWidget whose outermost node is a Container
// (not RenderBox-hit-testable). Use waitUntilExists (not waitUntilVisible) for
// the autocomplete widget itself. The Icon inside the close IconButton IS
// hit-testable, so waitUntilVisible applies there.
//
// noSettle / never pumpAndSettle: the live map keeps the frame pipeline busy.
// All readiness checks use explicit finder waits.
//
// ──────────────────────────────────────────────────────────────────────────────
// PLACES API: NOT CALLED
// ──────────────────────────────────────────────────────────────────────────────
// Tapping the TextField with no text dispatches searchQuery(""). The Places
// autocomplete service is only invoked for non-empty queries (see MapOverlayBloc
// handler). This test does not type any text, so the Places API is never hit and
// no network credentials are required beyond the staging login.
//
// Account prerequisite: any logged-in staging account — no special session data
// needed. Default account: ray+uk3@road.io.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'explore search: tapping the search box opens AutocompleteWidget, close button dismisses it',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // ── 1. Navigate to Map tab ──────────────────────────────────────────────
      //
      // noSettle: the live map never reaches idle. Wait for ExploreRootScreen,
      // then for the search TextField inside InitialWidget (the concrete,
      // hit-testable readiness signal for the overlay chrome).
      await tapTab($, AppTab.map);
      await $(ExploreRootScreen).waitUntilVisible();
      await $(InitialWidget).$(TextField).waitUntilVisible();

      expect(
        $(MapOverlayWidget),
        findsOneWidget,
        reason: 'MapOverlayWidget should be mounted over the map',
      );
      expect(
        $(InitialWidget),
        findsOneWidget,
        reason: 'overlay should start in the InitialWidget state',
      );

      // ── 2. Tap the search TextField to open the autocomplete UI ────────────
      //
      // Tapping the TextField focuses it. _MapOverlayWidgetState._handleFocusChange
      // fires and dispatches MapOverlayEvent.searchQuery("") to MapOverlayBloc.
      // The bloc transitions to TypeAheadSearchResults(results: null), and the
      // AnimatedSwitcher replaces InitialWidget with AutocompleteWidget.
      //
      // We use noSettle on the tap so we don't wait for the 300 ms
      // AnimatedSwitcher animation to "settle" (it never would on a live map).
      await $(InitialWidget).$(TextField).tap(settlePolicy: SettlePolicy.noSettle);

      // ── 3. Assert AutocompleteWidget is mounted ─────────────────────────────
      //
      // AutocompleteWidget's root is a Container, which has no hit-testable
      // RenderBox. Use waitUntilExists (tree presence) rather than
      // waitUntilVisible (hit-testability). The close IconButton inside it IS
      // hit-testable, so we confirm it's visible before we use it in step 4.
      await $(AutocompleteWidget).waitUntilExists();

      expect(
        $(AutocompleteWidget),
        findsOneWidget,
        reason: 'AutocompleteWidget should be mounted after focusing the search TextField',
      );
      expect(
        $(InitialWidget),
        findsNothing,
        reason: 'InitialWidget should be replaced by AutocompleteWidget while search is open',
      );

      // ── 4. Dismiss by tapping the close button inside AutocompleteWidget ───
      //
      // AutocompleteWidget's close button (Icons.close, top-right) dispatches
      // MapOverlayEvent.resetToInitial(), which returns the bloc to Initial state
      // and re-mounts InitialWidget.
      await $(AutocompleteWidget).$(IconButton).$(Icons.close).waitUntilVisible();
      await $(AutocompleteWidget).$(IconButton).$(Icons.close).tap(settlePolicy: SettlePolicy.noSettle);

      // ── 5. Assert AutocompleteWidget is gone and InitialWidget is back ──────
      //
      // Wait until AutocompleteWidget leaves the tree before asserting findsNothing
      // — the AnimatedSwitcher keeps the outgoing child in the tree for the 300 ms
      // transition duration, so an immediate findsNothing would be a race.
      await waitUntilGone($, $(AutocompleteWidget));

      expect(
        $(AutocompleteWidget),
        findsNothing,
        reason: 'AutocompleteWidget should be gone after tapping the close button',
      );
      expect(
        $(InitialWidget),
        findsOneWidget,
        reason: 'InitialWidget should be restored after dismissing the search UI',
      );
    },
  );
}
