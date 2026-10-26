import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/home/home_root_screen.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/nearest_stations_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/wallet_root_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Navigation smoke test: boot onto staging, log in, tap each Home shortcut row
// and assert the destination screen is reached, then return to Home before the
// next shortcut.
//
// Shortcuts covered:
//   1. View Wallet     → switches to Wallet tab (WalletRootScreen).
//   2. Explore Stations→ switches to Map/Explore tab (ExploreRootScreen).
//   3. Highway Mode    → pushes NearestStationsScreen as a full-screen modal.
//
// Shortcut finders: RMInkwellButton rows are found by their label text via
// $(RMInkwellButton).containing(label). The rows are always visible on the Home
// screen without scrolling on standard devices — no scrollIntoView needed.
//
// noSettle: all three destinations contain continuously-animating content
// (wallet shimmer, google-maps tiles, nearest-stations loader). NEVER
// pumpAndSettle. Readiness is established via waitUntilExists on the screen
// type, which detects widget-tree presence without requiring hit-testability.
//
// Return strategy:
//   • View Wallet / Explore Stations switch tabs — return via tapTab(home).
//   • Highway Mode pushes a full-screen modal with a custom IconButton(
//     icon: Icon(Icons.arrow_back)) — tap that icon to pop the route, then
//     waitUntilExists on HomeRootScreen before proceeding.
//
// Prerequisite account: ray+uk3@road.io (default). No special data required —
// all three destinations render unconditionally (the wallet/explore/highway
// screens show shimmers or loading states while fetching).
// Credentials: --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…

void main() {
  e2eTest(
    'home shortcuts: View Wallet, Explore Stations, and Highway Mode each navigate to their destination',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // bootLoginEnrolled leaves the app on the Account tab.
      await tapTab($, AppTab.home);

      // Wait for the Home screen to be ready. 'Charge Now' is a concrete leaf
      // widget rendered immediately by ChargeNowBloc's idle state — no network
      // fetch required. Scoped to HomeRootScreen to avoid false matches.
      await $(HomeRootScreen).$('Charge Now').waitUntilVisible();

      // -----------------------------------------------------------------------
      // 1. View Wallet
      // -----------------------------------------------------------------------
      // The 'View Wallet' RMInkwellButton is the first shortcut row. It calls
      // MainAppRootNavigationCubit.switchToNavbarItem(NavbarItem.wallet), which
      // switches the bottom-nav to the Wallet tab in-place (no push route).
      final viewWalletRow = $(RMInkwellButton).containing('View Wallet');
      await viewWalletRow.waitUntilVisible();
      await viewWalletRow.tap();

      // WalletRootScreen mounts immediately on tab switch. It renders a shimmer
      // loader while the cubit fetches sessions data — waitUntilExists (not
      // waitUntilVisible) because the screen type is a layout ancestor and is
      // not itself hit-testable.
      await $(WalletRootScreen).waitUntilExists();
      expect(
        $(WalletRootScreen),
        findsOneWidget,
        reason: 'WalletRootScreen should be present after tapping View Wallet',
      );

      // Return to Home via the bottom nav before the next shortcut.
      await tapTab($, AppTab.home);
      await $(HomeRootScreen).waitUntilExists();

      // -----------------------------------------------------------------------
      // 2. Explore Stations
      // -----------------------------------------------------------------------
      // The 'Explore Stations' RMInkwellButton calls
      // MainAppRootNavigationCubit.switchToNavbarItem(NavbarItem.explore),
      // switching to the Map/Explore tab.
      final exploreStationsRow = $(RMInkwellButton).containing('Explore Stations');
      await exploreStationsRow.waitUntilVisible();
      await exploreStationsRow.tap();

      // ExploreRootScreen hosts the Google Maps widget, which never settles.
      // Assert its existence in the widget tree to confirm the tab switch landed.
      await $(ExploreRootScreen).waitUntilExists();
      expect(
        $(ExploreRootScreen),
        findsOneWidget,
        reason: 'ExploreRootScreen should be present after tapping Explore Stations',
      );

      // Return to Home via the bottom nav before the next shortcut.
      await tapTab($, AppTab.home);
      await $(HomeRootScreen).waitUntilExists();

      // -----------------------------------------------------------------------
      // 3. Highway Mode
      // -----------------------------------------------------------------------
      // The 'Highway Mode' RMInkwellButton calls
      // NearestStationsScreen.pushAsFullScreen(context), which pushes
      // NearestStationsScreen as a full-screen modal via the root navigator
      // (fullscreenDialog: true). This is a push route, not a tab switch.
      final highwayModeRow = $(RMInkwellButton).containing('Highway Mode');
      await highwayModeRow.waitUntilVisible();
      await highwayModeRow.tap();

      // NearestStationsScreen renders a Scaffold with an AppBar and a shimmer
      // loader while the NearestStationsCubit fetches. waitUntilExists on the
      // screen type confirms the route was pushed and the widget was created.
      await $(NearestStationsScreen).waitUntilExists();
      expect(
        $(NearestStationsScreen),
        findsOneWidget,
        reason: 'NearestStationsScreen should be present after tapping Highway Mode',
      );

      // Return: NearestStationsScreen's AppBar has a custom leading IconButton
      // with Icon(Icons.arrow_back) — not Flutter's BackButton widget. Tap the
      // icon to pop the modal route.
      await $(Icons.arrow_back).tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for HomeRootScreen to be back in the tree before the test ends.
      await $(HomeRootScreen).waitUntilExists();
    },
  );
}
