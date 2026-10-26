import 'package:patrol/patrol.dart';
import 'package:road_mobile/main.dart' as app;

import 'reset.dart';

/// Resets persisted state, launches the app on the staging backend, grants the
/// location permission if prompted, and settles. Leaves the app logged out on
/// its default (Home) tab — unless [preserveSession] found a reusable session,
/// in which case it boots logged in. Start every test with this.
///
/// [seedStaging] (default true) writes the debug-controls prefs before launch so
/// the app boots straight onto staging — no `switchToStaging` UI dance. Pass
/// false only for a test that deliberately exercises the debug-controls UI
/// switch from production.
///
/// [preserveSession] keeps a previous test's logged-in session across the
/// state reset when it's fresh and complete (see `resetAppState`); the caller
/// must then branch on whether the app actually booted logged in
/// (`bootLoginEnrolled` does this).
///
/// On Android/OnePlus a Google Play Services "Location Accuracy" overlay can
/// appear on top of the app right after the grant and persist. We deliberately
/// don't dismiss it here — Patrol's Flutter taps hit the widget tree directly
/// and ignore the overlay. It's cleared later by the first native back-press
/// (see [dismissLoginModal]).
Future<void> bootApp(
  PatrolIntegrationTester $, {
  bool seedStaging = true,
  bool preserveSession = false,
}) async {
  await resetAppState(preserveSession: preserveSession);
  if (seedStaging) {
    await seedStagingPrefs();
  }
  await app.main();
  // Render the first frame(s) WITHOUT pumpAndSettle: the home screen animates
  // continuously (the nearest-stations loader), so it never reaches idle and a
  // pumpAndSettle would hang to settleTimeout on every boot. A fixed pump
  // renders without waiting for idle; the permission probe below and the first
  // finder give the app the rest of the time it needs to be interactable.
  await $.tester.pump(const Duration(seconds: 1));
  await grantLocationIfPrompted($);
  await $.tester.pump();
}

/// Grants the OS location permission if its dialog is visible.
///
/// iOS persists the grant across runs (no `clearPackageData` equivalent), so
/// the dialog often doesn't appear on repeat runs — and
/// `grantPermissionWhenInUse` throws if called with no dialog present. Guard
/// with `isPermissionDialogVisible`.
///
/// We use `$.native2` (not `$.native`): the older API granted but left the test
/// binding in a state where the next finder tripped "test had completed" /
/// FocusManager-disposed assertions on this Patrol fork.
Future<void> grantLocationIfPrompted(PatrolIntegrationTester $) async {
  final visible = await $.native2.isPermissionDialogVisible(
    timeout: const Duration(seconds: 5),
  );
  if (visible) {
    await $.native2.grantPermissionWhenInUse();
  }
}
