import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/initial_charge_flow_widget.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/qr_scanner_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Entry-point + construction test: Charge Now → "Scan station QR code" →
// assert QrScannerWidget mounts → close without scanning.
//
// Shape: boot → log in → AppTab.explore (opens ChargeNowRootScreen modal) →
// tap "Scan station QR code" → grant camera permission if prompted →
// assert QrScannerWidget is mounted → close via Icons.close → assert modal
// dismissed.
//
// Camera permission handling:
//   Opening MobileScanner triggers the OS camera-permission dialog on first
//   run. We probe it with $.native2.isPermissionDialogVisible (the same guard
//   used for location in app_launch.dart's grantLocationIfPrompted) and grant
//   it if shown. On subsequent runs iOS has already persisted the grant, so no
//   dialog appears — the guard is a no-op.
//
//   If permission is denied (e.g. BrowserStack device with pre-denied camera),
//   QrScannerWidget's errorBuilder fires and _handlePermissionDenied shows an
//   AlertDialog with "Cancel" and "Open Settings". We detect that AlertDialog
//   and tap "Cancel", which dispatches ChargeNowEvent.backButtonTapped and
//   returns to InitialChargeFlowWidget. In that case we logSkip and return —
//   the QR scanner widget _did_ construct (it was mounted before the error
//   callback fired), so the test still validated construction.
//
// NEVER pumpAndSettle — e2eConfig sets SettlePolicy.noSettle globally. The
// MobileScanner camera preview drives frames continuously and never reaches
// idle. Readiness is asserted via waitUntilExists on the QrScannerWidget type
// (it is a StatefulWidget container and may not be hit-testable, so we use
// waitUntilExists rather than waitUntilVisible).
//
// Prerequisite: a logged-in staging account.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…
// Default account: ray+uk3@road.io. No special data needed.

void main() {
  e2eTest(
    'charge now QR: tapping Scan station QR code opens QrScannerWidget and close dismisses the modal',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Open Charge Now. AppTab.explore maps to the centre lightning-bolt tab
      // which calls ChargeNowRootScreen.pushAsModal — a fullscreenDialog route.
      // The modal always opens on InitialChargeFlowWidget (ConnectYourCar state).
      await tapTab($, AppTab.explore);

      // Wait on the 'Charge Now' title Text inside the modal — it is a concrete
      // hit-testable leaf rendered immediately from the idle bloc state.
      await $(ChargeNowRootScreen).$('Charge Now').waitUntilVisible();
      expect(
        $(ChargeNowRootScreen),
        findsOneWidget,
        reason: 'ChargeNowRootScreen must be mounted after tapping the explore tab',
      );

      // Tap "Scan station QR code". This dispatches
      // ChargeNowEvent.scanQrCodeTapped and transitions the bloc to the
      // ScanningQrCode state, swapping in QrScannerWidget as the body.
      await $('Scan station QR code').waitUntilVisible();
      await $('Scan station QR code').tap(settlePolicy: SettlePolicy.noSettle);

      // Grant camera permission if the OS dialog appears.
      //
      // MobileScanner requests camera access when it first starts. On a fresh
      // device/first run this triggers the native permission dialog. We use the
      // same guard as grantLocationIfPrompted in app_launch.dart: probe with
      // isPermissionDialogVisible and call grantPermissionWhenInUse only when
      // the dialog is actually present — because the grant method throws if
      // called without a dialog.
      final cameraDialogVisible = await $.native2.isPermissionDialogVisible(
        timeout: const Duration(seconds: 5),
      );
      if (cameraDialogVisible) {
        await $.native2.grantPermissionWhenInUse();
      }

      // Wait for QrScannerWidget to be present in the widget tree.
      //
      // QrScannerWidget is a StatefulWidget whose build output contains a
      // MobileScanner camera preview — a continuously-rendering widget. We use
      // waitUntilExists (not waitUntilVisible) because layout containers are
      // not guaranteed to pass Flutter's hit-testability check and
      // waitUntilVisible would no-op on them.
      await $(ChargeNowRootScreen).$(QrScannerWidget).waitUntilExists();

      // ── Camera permission denied? ─────────────────────────────────────────
      // If the camera permission was already denied on this device,
      // QrScannerWidget's MobileScanner errorBuilder fires synchronously and
      // _handlePermissionDenied shows an AlertDialog. Detect it and dismiss via
      // "Cancel" (which dispatches backButtonTapped and restores
      // InitialChargeFlowWidget). We then logSkip — QrScannerWidget did mount
      // (proving entry-point and construction), but the scanner preview is
      // unavailable without the permission.
      if ($(AlertDialog).exists) {
        logSkip(
          'Camera permission was denied on this device. QrScannerWidget mounted '
          'successfully (construction verified) but MobileScanner showed a '
          'permission-denied AlertDialog. Tapping Cancel and skipping the '
          'scanner-open assertion.',
        );
        await $('Cancel').tap(settlePolicy: SettlePolicy.noSettle);
        // Wait for the permission-denied dialog to dismiss and the widget to
        // return to InitialChargeFlowWidget before closing the modal.
        await $(ChargeNowRootScreen).$(InitialChargeFlowWidget).waitUntilExists();
        await $(ChargeNowRootScreen).$(IconButton).$(Icons.close).tap(settlePolicy: SettlePolicy.noSettle);
        await waitUntilGone($, $(ChargeNowRootScreen));
        expect(
          $(ChargeNowRootScreen),
          findsNothing,
          reason: 'ChargeNowRootScreen should be gone after tapping the close button',
        );
        return;
      }

      // ── Assert QrScannerWidget is mounted ────────────────────────────────
      // QrScannerWidget is a StatefulWidget container — not necessarily
      // hit-testable (it wraps a full-screen camera preview). Use findsOneWidget
      // after waitUntilExists has confirmed it is in the tree.
      expect(
        $(ChargeNowRootScreen).$(QrScannerWidget),
        findsOneWidget,
        reason:
            'QrScannerWidget must be mounted as the modal body after tapping '
            '"Scan station QR code" (bloc transitions to ScanningQrCode state)',
      );

      // InitialChargeFlowWidget must no longer be present — it was replaced by
      // QrScannerWidget when the bloc emitted the ScanningQrCode state.
      expect(
        $(ChargeNowRootScreen).$(InitialChargeFlowWidget),
        findsNothing,
        reason:
            'InitialChargeFlowWidget must not be in the tree while '
            'QrScannerWidget is the active body (ScanningQrCode state)',
      );

      // No error dialog should be present at this point. If an AlertDialog
      // appeared here it would indicate an unexpected error (not permission
      // denied, which was handled above).
      expect(
        $(AlertDialog),
        findsNothing,
        reason:
            'no AlertDialog should be present after opening the QR scanner '
            '(permission was granted above)',
      );

      // ── Close the modal ───────────────────────────────────────────────────
      // The AppBar always shows Icons.close in its actions. Tapping it calls
      // Navigator.of(context).pop() and (via PopScope's onPopInvokedWithResult)
      // dispatches ChargeNowEvent.modalFlowDismissed. We close WITHOUT scanning.
      await $(ChargeNowRootScreen).$(IconButton).$(Icons.close).tap(settlePolicy: SettlePolicy.noSettle);

      // The modal pops with a fullscreen-dialog transition — the route lingers
      // mid-animation. Poll until it is fully gone before asserting findsNothing
      // to avoid racing the dispose.
      await waitUntilGone($, $(ChargeNowRootScreen));
      expect(
        $(ChargeNowRootScreen),
        findsNothing,
        reason: 'ChargeNowRootScreen should be gone after tapping the close button',
      );
    },
  );
}
