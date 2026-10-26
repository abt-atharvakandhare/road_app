import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Current value of a [Switch] finder, or null while it's mid-transition (the
/// finder is briefly empty as the row rebuilds).
bool? readSwitch(PatrolFinder switchFinder) {
  final matches = switchFinder.evaluate();
  return matches.isEmpty ? null : (matches.first.widget as Switch).value;
}

/// Ensures [switchFinder] ends in the [on] state, tapping if needed and polling
/// until it gets there. Idempotent — does nothing if already at [on].
///
/// We poll rather than `pumpAndSettle` because the screen never settles while
/// toggling: turning a switch on fires an API call that shows a
/// continuously-animating loader, so a default settle burns the settleTimeout.
///
/// Set [grantsPermissionWhenEnabled] for toggles that trigger an OS permission
/// dialog when enabled (e.g. notifications → POST_NOTIFICATIONS on Android 13+).
/// On iOS the permission usually already persists, so the dialog often doesn't
/// appear — hence the `isPermissionDialogVisible` guard
/// (`grantPermissionWhenInUse` throws if called with no dialog present).
Future<void> setSwitch(
  PatrolIntegrationTester $,
  PatrolFinder switchFinder, {
  required bool on,
  bool grantsPermissionWhenEnabled = false,
}) async {
  if (readSwitch(switchFinder) == on) return;

  await switchFinder.tap(settlePolicy: SettlePolicy.noSettle);

  if (on && grantsPermissionWhenEnabled) {
    final dialogVisible = await $.native2.isPermissionDialogVisible(
      timeout: const Duration(seconds: 10),
    );
    if (dialogVisible) {
      await $.native2.grantPermissionWhenInUse();
    }
  }

  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    await $.tester.pump(const Duration(milliseconds: 200));
    if (readSwitch(switchFinder) == on) return;
  }

  // Fail loudly on timeout. Without this the function returns normally and the
  // caller's expect() reports a confusing "Expected: <$on>, Actual: <null/...>"
  // with no hint the poll timed out.
  fail(
    'switch did not reach $on within 10s '
    '(current: ${readSwitch(switchFinder)})',
  );
}
