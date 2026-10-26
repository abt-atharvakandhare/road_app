import 'dart:io' show Platform;

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/services/network/session_renewal_token_storage.dart';

/// How to answer a BrowserStack-injected biometric popup.
enum BioResponse { pass, fail, cancel }

/// Whether a BrowserStack-injected biometric dialog is expected.
///
/// On BrowserStack (the `enableBiometric` capability) the OS prompt is replaced
/// by a tappable AlertDialog we drive via [respondToBiometric]. On a real device
/// there is no such dialog — the real Face ID / fingerprint prompt is satisfied
/// physically (look at the camera) or cancelled by hand. Default true (BS, so CI
/// scripts need no change); pass `--dart-define=BIOMETRIC_INJECTED_DIALOG=false`
/// for a local on-device run.
const expectInjectedBiometricDialog =
    bool.fromEnvironment('BIOMETRIC_INJECTED_DIALOG', defaultValue: true);

// The BrowserStack injected biometric popup (Device Cloud Pro) is a standard
// Android AlertDialog in the app's own package, with the conventional button
// resource ids — PASS=button1 (positive), FAIL=button2 (negative),
// CANCEL=button3 (neutral). We match by resourceName, NOT text: the button
// label is "PASS\n\n" (trailing newlines), and UiAutomator's By.text/
// By.textContains compile to a full-match regex using `.`, which can't match a
// newline — so every text-based selector misses. Resource ids sidestep that
// and are stable. (Captured via the native-tree dump below on 2026-06-02.)
const _androidResId = {
  BioResponse.pass: 'android:id/button1',
  BioResponse.fail: 'android:id/button2',
  BioResponse.cancel: 'android:id/button3',
};
// iOS button labels — UNVERIFIED best-effort, pending an iOS run (suite is
// Android-first). If they're wrong, iOS biometric tests will throw at the
// `required` gate below; the _nativeTreeDump in that error surfaces the real
// labels — update this map from the dump on the first failing iOS run.
const _iosLabel = {BioResponse.pass: 'PASS', BioResponse.fail: 'FAIL', BioResponse.cancel: 'CANCEL'};

List<AndroidSelector> _androidCandidates(BioResponse o) => [
      AndroidSelector(resourceName: _androidResId[o]),
    ];

List<IOSSelector> _iosCandidates(BioResponse o) => [
      IOSSelector(label: _iosLabel[o]),
    ];

/// Responds to ONE biometric popup if it appears within [timeout].
///
/// Tries each candidate selector each poll tick; taps the first that matches.
/// Returns true if tapped. If none match by the deadline:
///  - [required] true  → throws with a dump of the on-screen native tree, so
///    the real button attributes surface in the (instrumentation) logs.
///  - [required] false → logs the dump and returns false (for optional prompts,
///    e.g. an iOS write that doesn't prompt).
Future<bool> respondToBiometric(
  PatrolIntegrationTester $, {
  required BioResponse outcome,
  bool required = true,
  Duration timeout = const Duration(seconds: 20),
}) async {
  // Local on-device run: there is no injected dialog to tap. The real OS prompt
  // is handled physically (look at the camera) or cancelled by hand, so don't
  // poll/throw — give the prompt a moment to surface and let the caller's
  // targeted waits (expectLoggedIn/Out) cover the rest.
  if (!expectInjectedBiometricDialog) {
    await Future<void>.delayed(const Duration(seconds: 2));
    return false;
  }

  // Per-platform only: a NativeSelector with the current platform's field null
  // makes getNativeViews return the whole tree (non-empty) and then tap() 500s
  // with "neither selector nor androidSelector are set".
  final candidates = Platform.isAndroid
      ? [for (final a in _androidCandidates(outcome)) NativeSelector(android: a)]
      : [for (final i in _iosCandidates(outcome)) NativeSelector(ios: i)];

  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    for (final selector in candidates) {
      final views = await $.native2.getNativeViews(selector);
      if (views.androidViews.isNotEmpty || views.iosViews.isNotEmpty) {
        await $.native2.tap(selector);
        return true;
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  final dump = await _nativeTreeDump($);
  if (required) {
    throw StateError(
      'Biometric "${outcome.name}" button not found within $timeout. '
      'On-screen native views:\n$dump',
    );
  }
  debugPrint('respondToBiometric: no "${outcome.name}" popup found.\n$dump');
  return false;
}

/// Responds to the full prompt sequence a session renewal triggers.
///
/// A renewal does `read()` (prompt #1) then, after a successful `/auth/renew`,
/// `store()` the rotated token (prompt #2 — Android Keystore re-prompts on the
/// write; iOS does not). So: Android read-pass = TWO popups; Android
/// read-cancel/fail = ONE; iOS = ONE.
Future<void> respondToRenewal(
  PatrolIntegrationTester $, {
  required BioResponse readOutcome,
  BioResponse writeOutcome = BioResponse.pass,
}) async {
  await respondToBiometric($, outcome: readOutcome);

  if (Platform.isAndroid && readOutcome == BioResponse.pass) {
    // The write prompt only appears after the /auth/renew round-trip. Let the
    // read dialog dismiss first so we don't re-tap it as the write dialog.
    await Future<void>.delayed(const Duration(seconds: 1));
    await respondToBiometric($, outcome: writeOutcome);
  }
}

/// Dumps the clickable, button, and text nodes currently on screen, across all
/// windows. Used to discover the biometric popup's real selectors.
Future<String> _nativeTreeDump(PatrolIntegrationTester $) async {
  final buffer = StringBuffer();

  Future<void> dump(String label, AndroidSelector android, IOSSelector ios) async {
    try {
      final views = await $.native2.getNativeViews(NativeSelector(android: android, ios: ios));
      buffer.writeln('[$label] ${views.androidViews.length} android / ${views.iosViews.length} ios');
      for (final v in views.androidViews) {
        buffer.writeln('  android text="${v.text}" desc="${v.contentDescription}" '
            'class="${v.className}" res="${v.resourceName}" pkg="${v.applicationPackage}"');
      }
      for (final v in views.iosViews) {
        buffer.writeln('  ios label="${v.label}" title="${v.title}" value="${v.value}" '
            'type="${v.elementType}" id="${v.identifier}"');
      }
    } catch (e) {
      buffer.writeln('[$label] dump error: $e');
    }
  }

  // Catch-all: empty textContains/labelContains matches any node that has a
  // text/label, so this lists every text-bearing node on screen regardless of
  // class — the surest way to see the popup buttons' real attributes.
  await dump('alltext', AndroidSelector(textContains: ''), IOSSelector(labelContains: ''));
  await dump('clickable', AndroidSelector(isClickable: true), IOSSelector(elementType: IOSElementType.button));
  await dump('button', AndroidSelector(className: 'android.widget.Button'), IOSSelector(elementType: IOSElementType.button));
  await dump('textview', AndroidSelector(className: 'android.widget.TextView'), IOSSelector(elementType: IOSElementType.staticText));
  return buffer.toString();
}

/// Deletes the biometric-gated renewal token from the OS keystore/keychain.
///
/// `resetAppState()` clears FlutterSecureStorage + SharedPreferences but NOT the
/// `biometric_storage` entry, so a from-scratch enrollment test must call this
/// to guarantee no prior token lingers. Best-effort.
Future<void> clearBiometricRenewalToken() async {
  try {
    final file = await BiometricStorage().getStorage(
      SessionRenewalTokenStorage.renewalFileName,
      options: StorageFileInitOptions(authenticationRequired: true),
    );
    await file.delete();
  } catch (_) {
    // Nothing stored, or the platform can't open the file — nothing to clear.
  }
}
