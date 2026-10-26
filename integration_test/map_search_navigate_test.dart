import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/autocomplete_widget.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/search_results/search_results_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Map SEARCH + NAVIGATE integration test.
//
// Shape: boot onto staging → log in → Map tab → tap the search box → type
// "Delft" → wait for Places autocomplete results → tap the first result → wait
// for the animated camera to settle on Delft.
//
// ──────────────────────────────────────────────────────────────────────────────
// WHAT THIS COVERS (the whole search path, not just opening the box)
// ──────────────────────────────────────────────────────────────────────────────
// MapOverlayWidget's bloc state machine (map_overlay_widget.dart):
//
//   Initial ─(focus)─► TypeAheadSearchResults ─(tap result)─► WaitingForMapToSettle
//                                                                      │
//                                            (MapBloc stops loading)   ▼
//                                                        ShowChargingStationResults
//
// - Focusing the search field fires MapOverlayEvent.searchQuery(text) → the bloc
//   renders AutocompleteWidget.
// - onChanged (typing) fires searchQuery('Delft') → the bloc calls the Google
//   Places autocomplete API → results render as ListTiles.
// - Tapping a result fires MapEvent.geoCodingResultSelected (animates the camera)
//   and queues loadSearchResults for when the map settles. The overlay sits in
//   WaitingForMapToSettle (an invisible SizedBox) until MapBloc.flow stops
//   loading, then swaps to SearchResultsWidget — so SearchResultsWidget appearing
//   IS the "camera has settled" signal.
//
// It also drives the camera to a deterministic, recognizable place (Delft, NL),
// so the recording shows a real map move. (iOS records the Google Maps surface;
// Android's screen recorder blanks the map SurfaceView — but the assertions are
// on Flutter widgets, so the test is valid on both.)
//
// ──────────────────────────────────────────────────────────────────────────────
// NETWORK: unlike explore_search_opens (which never types), this DOES hit the
// Google Places autocomplete API (non-empty query) plus the map-search backend.
// Needs the Places API key configured and network on the device.
// ──────────────────────────────────────────────────────────────────────────────
//
// Account: any logged-in staging account — no special data needed. Default
// ray+uk3@road.io. Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

const _query = 'Delft';

void main() {
  e2eTest(
    'map search: type Delft, pick first result, camera settles on the location',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // ── 1. Map tab ─────────────────────────────────────────────────────────
      // noSettle everywhere: the live map never idles. Wait for the search field
      // inside InitialWidget as the hit-testable readiness signal.
      await tapTab($, AppTab.map);
      await $(ExploreRootScreen).waitUntilVisible();
      await $(InitialWidget).$(TextField).waitUntilVisible();

      // ── 2. Focus the search box → overlay swaps to AutocompleteWidget ───────
      await $(InitialWidget).$(TextField).tap(settlePolicy: SettlePolicy.noSettle);
      await $(AutocompleteWidget).waitUntilExists();

      // ── 3. Type the query into the (now AutocompleteWidget-hosted) field ────
      // onChanged → MapOverlayEvent.searchQuery('Delft') → Places autocomplete.
      final searchField = $(AutocompleteWidget).$(TextField);
      await searchField.waitUntilVisible();
      await searchField.enterText(_query, settlePolicy: SettlePolicy.noSettle);

      // ── 4. Wait for Places results ──────────────────────────────────────────
      // Each result is a ListTile whose title is the place name — that's DATA
      // (from Google), not a localized label, so matching 'Delft' is safe. Wait
      // for a Delft-bearing tile before tapping: this both confirms the network
      // results arrived and skips the empty-state "use my current position" tile
      // (avoids a RangeError on an unindexed .first before any result exists).
      await $(AutocompleteWidget).$(ListTile).containing(_query).waitUntilExists();

      // ── 5. Tap the first result ─────────────────────────────────────────────
      // With results present, every ListTile is a Places result (the current-
      // position tile only shows when results are empty), so .first is the top
      // suggestion for "Delft". Its onTap moves the camera + queues the search.
      await $(AutocompleteWidget).$(ListTile).first.tap(settlePolicy: SettlePolicy.noSettle);

      // ── 6. Wait for the animated camera to settle ───────────────────────────
      // AutocompleteWidget leaves the tree, and once MapBloc stops loading the
      // overlay transitions to SearchResultsWidget. waitUntilExists (not Visible):
      // the overlay child roots are containers, not hit-testable.
      await waitUntilGone($, $(AutocompleteWidget));
      await $(SearchResultsWidget).waitUntilExists();

      // Let the settled map linger a few seconds so the camera move to Delft is
      // visible on the recording.
      await pause($, 3000);

      expect(
        $(SearchResultsWidget),
        findsOneWidget,
        reason:
            'overlay should reach SearchResultsWidget after the camera settles on '
            'the searched location (Delft)',
      );
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should surface during search + navigate',
      );
    },
  );
}
