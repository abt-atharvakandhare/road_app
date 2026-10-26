import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/login_email_password_widget.dart';
import 'package:road_mobile/ui/onboarding/login/login_screen.dart';
import 'package:road_mobile/ui/onboarding/login/mfa_code_entry_widget.dart';
import 'package:road_mobile/ui/onboarding/login/mfa_method_picker_widget.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'biometric.dart';
import 'reset.dart';
import 'scenario.dart';
import 'totp.dart';

/// Logs in from the unauthenticated Account screen: opens the login modal via
/// the SignupNow button, enters credentials, submits.
///
/// Scrolls up to the button first because after a staging switch the Account
/// screen is left scrolled down (to where the debug Staging segment was), so
/// the button can be off-screen above the viewport. `scrollTo` defaults to
/// scrolling *down*; we want to reveal content above, hence `AxisDirection.up`.
/// On a fresh Account screen the button is already at the top, so the scroll is
/// a harmless no-op.
///
/// [enroll] handles the post-login biometric *enrollment* introduced by
/// device-trust session renewal: once credentials are accepted, the app stores
/// a renewal token behind biometric storage.
///
/// Platform difference that matters here: the store is a *write*, and
/// `biometric_storage` only prompts on **write on Android** (Keystore
/// re-auth) — **iOS writes to the Keychain silently** (it only prompts on
/// *read*, i.e. during an actual renewal). So:
///  - Android + [enroll] set → answer the injected Pass/Fail/Cancel popup.
///  - iOS (any [enroll]) → no prompt fires; enrollment happens silently, we just
///    settle through. (To end up NOT enrolled on iOS, clear the token instead —
///    see `clearBiometricRenewalToken`.)
///  - [enroll] null → don't expect/answer any prompt (base plan w/o `--biometric`,
///    or a device with no biometric).
Future<void> loginAsStagingUser(
  PatrolIntegrationTester $,
  String email,
  String password, {
  BioResponse? enroll,
}) async {
  await submitLoginCredentials($, email, password);

  // Since MFA (PI-939) the decision engine can interpose a step between the
  // credential submit and the session: see [_answerMfaStep].
  //
  // Ordering is load-bearing: that step MUST be answered before the Android
  // biometric prompt. The renewal-token write that raises that prompt only
  // runs once the session is issued, so waiting on the dialog first deadlocks.
  // On the no-MFA path the form stays mounted (spinner) while the native
  // dialog blocks — invisible to the Flutter tree — so the poll falls
  // through on its deadline and the prompt is answered next.
  await _answerMfaStep($);

  await finishLogin($, enroll: enroll);
}

/// Opens the login modal from the Account tab and submits [email]/[password].
/// Returns as soon as the submit is tapped; whatever the decision engine
/// shows next (nothing, the enrolment interstitial, an MFA challenge) is the
/// caller's to handle — [loginAsStagingUser] does it via [_answerMfaStep],
/// the MFA tests drive the challenge screens themselves.
Future<void> submitLoginCredentials(
  PatrolIntegrationTester $,
  String email,
  String password,
) async {
  final loginButton = $(SignupNowWidget).$(RMTextButton);
  await loginButton.scrollTo(scrollDirection: AxisDirection.up);
  await loginButton.tap();

  // Wait for the modal's fields to mount before indexing. Use the UNINDEXED
  // finder: while zero TextFields exist, `.at(0)` throws RangeError (Patrol's
  // indexed finders don't wait gracefully) instead of waiting for the modal to
  // open. The unindexed finder waits; once any field is present `.at(0)`/`.at(1)`
  // resolve. (This replaces the removed pumpAndSettle — no settle, just a wait.)
  await $(LoginEmailPasswordWidget).$(TextField).waitUntilVisible();

  // The modal has two TextFields (email, password) in order. Scope to
  // LoginEmailPasswordWidget so we don't catch TextFields on widgets behind it.
  //
  // noSettle on each: the fields carry AutofillHints (email/password), so on a
  // real iOS device the password-autofill / QuickType bar animates and the
  // screen never settles — a default enterText would pumpAndSettle and burn ~10s
  // per field. We don't need the screen quiet between entries.
  await $(LoginEmailPasswordWidget)
      .$(TextField)
      .at(0)
      .enterText(email, settlePolicy: SettlePolicy.noSettle);
  await $(LoginEmailPasswordWidget)
      .$(TextField)
      .at(1)
      .enterText(password, settlePolicy: SettlePolicy.noSettle);

  // Submit with noSettle: the login spinner animates, and on Android the
  // enrollment write prompt blocks — a default settle would stall.
  await $(LoginEmailPasswordWidget).$(RMTextButton).tap(settlePolicy: SettlePolicy.noSettle);
}

/// The tail of a login once credentials (and any MFA step) are accepted:
/// answers the Android biometric enrolment prompt, waits for the modal to
/// close and stamps the session for reuse. Fails with a diagnosis if the
/// modal is still up after 20s.
Future<void> finishLogin(PatrolIntegrationTester $, {BioResponse? enroll}) async {
  // A biometric popup only appears for the enrollment write on Android. On
  // the MFA path it surfaces after the skip/verify round-trip;
  // respondToBiometric's own poll absorbs that latency.
  if (enroll != null && Platform.isAndroid) {
    await respondToBiometric($, outcome: enroll);
  }

  // Login is done once the modal closes (token stored, AuthState → LoggedIn).
  // Poll for that rather than pumpAndSettle: a default settle would also wait
  // out the background account-details refresh (getMyProfile / getMyAccount /
  // getMobileFeatures) and its loaders — several seconds the test doesn't need,
  // since the next action waits for its own target.
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    if ($(LoginScreen).evaluate().isEmpty) {
      // Stamp the successful login so a later test's `resetAppState(
      // preserveSession: true)` can judge the session fresh enough to reuse.
      // Only stamp here, on the modal actually closing — a timed-out login
      // must not arm the reuse path.
      await stampSessionLogin();
      return;
    }
    await $.tester.pump(const Duration(milliseconds: 100));
  }
  fail('login modal still open 20s after submit — check credentials, the MFA '
      'step (enrolment skip / TOTP code; an enforce-mode account cannot be '
      'skipped), and the biometric response in the run log.');
}

/// Polls the login modal for up to 15s after the credential submit and
/// answers whichever MFA step the decision engine interposes:
///
///  - **Enrolment interstitial** ("Secure your account", mode=encourage): the
///    credential form has unmounted and the modal's only RichText with a tap
///    recognizer is the "Skip for now" link (a bare $(RichText) would match
///    dead text first, because Text widgets render RichText internally). Tap
///    it. Under `enforce` there is no skip link; the account needs a real
///    factor and the caller's modal-closed wait fails with that hint.
///  - **Method picker** (account has several usable factors): choose the
///    authenticator app, then keep polling for its code entry.
///  - **TOTP code entry**: compute the code from `TEST_TOTP_SECRET` and type
///    it; [MfaCodeEntryCard] auto-submits on the sixth digit. Fails fast with
///    the cause if the secret wasn't passed, instead of timing out generically.
///  - **Any other code entry** (SMS, email verification): nothing the suite can
///    answer unattended, so fail fast naming it.
///
/// Returns when a step was answered or the deadline passed — a plain
/// (no-MFA) login never shows any of these, so the deadline is the normal
/// exit there, not an error.
Future<void> _answerMfaStep(PatrolIntegrationTester $) async {
  final skipLink = $(LoginScreen).$(find.byWidgetPredicate(
    (widget) =>
        widget is RichText && widget.text is TextSpan && (widget.text as TextSpan).recognizer != null,
  ));
  var pickedTotp = false;
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(deadline)) {
    if ($(LoginScreen).evaluate().isEmpty) return;

    final codeEntry = $(MfaCodeEntryWidget).evaluate();
    if (codeEntry.isNotEmpty) {
      final step = (codeEntry.first.widget as MfaCodeEntryWidget).twoFactorAuth;
      if (step is! TwoFactorAuthPendingTotp) {
        fail('login hit an MFA step the suite cannot answer unattended: '
            '${step.runtimeType}. The account must use an authenticator app '
            '(TOTP) as its only non-passkey factor.');
      }
      requireTotpSecret();
      // Don't type a code that expires before the API sees it.
      while (totpSecondsRemaining() < 4) {
        await $.tester.pump(const Duration(milliseconds: 250));
      }
      await enterTotpCode($, totpCode(testTotpSecret));
      return;
    }

    final picker = $(MfaMethodPickerWidget).evaluate();
    if (picker.isNotEmpty && !pickedTotp) {
      requireTotpSecret();
      // Resolve the label through the live context so it matches what Phrase
      // served at runtime, not just the baked-in ARB.
      final label = AppLocalizations.of(picker.single)!.appAuthentication;
      final totpButton = $(MfaMethodPickerWidget)
          .$(find.byWidgetPredicate((widget) => widget is RMTextButton && widget.text == label));
      if (totpButton.evaluate().isEmpty) {
        fail('MFA method picker offers no authenticator-app option; the account '
            'has no TOTP factor the suite can answer.');
      }
      await totpButton.tap(settlePolicy: SettlePolicy.noSettle);
      pickedTotp = true;
      continue;
    }

    // Only once the picker is gone: its recovery-code link is also a RichText
    // with a recognizer, and would otherwise be mistaken for the skip link.
    if (picker.isEmpty && $(LoginEmailPasswordWidget).evaluate().isEmpty && skipLink.evaluate().isNotEmpty) {
      await skipLink.tap(settlePolicy: SettlePolicy.noSettle);
      return;
    }
    await $.tester.pump(const Duration(milliseconds: 100));
  }
}

/// Types [code] into the login TOTP entry. [MfaCodeEntryCard] auto-submits on
/// the sixth digit, so no tap follows.
Future<void> enterTotpCode(PatrolIntegrationTester $, String code) async {
  await $(MfaCodeEntryWidget).$(TextField).enterText(code, settlePolicy: SettlePolicy.noSettle);
}

/// The login TOTP code entry, i.e. [MfaCodeEntryWidget] in its pending-TOTP
/// state (not an SMS / email-verification step).
PatrolFinder totpCodeEntry(PatrolIntegrationTester $) => $(find.byWidgetPredicate(
      (widget) => widget is MfaCodeEntryWidget && widget.twoFactorAuth is TwoFactorAuthPendingTotp,
    ));

/// A six-digit code guaranteed to differ from the current TOTP (last digit
/// changed). Still a live-format code, so the API treats it as a real wrong
/// guess — use at most once per test: guesses count toward the per-user limit.
String wrongTotpCode() {
  final code = totpCode(testTotpSecret);
  final last = int.parse(code[5]);
  return code.substring(0, 5) + ((last + 1) % 10).toString();
}

/// Fails fast when the account has MFA but no `TEST_TOTP_SECRET` was passed.
void requireTotpSecret() {
  if (testTotpSecret.isEmpty) {
    fail('the account has MFA enabled but no --dart-define=TEST_TOTP_SECRET '
        'was passed (the base32 secret of its authenticator-app factor).');
  }
}

/// Dismisses the login modal, platform-aware.
///
/// Android: `pressBack` lands on the topmost window. On Pixel/Samsung that's the
/// modal — one press is enough. On OnePlus/OxygenOS the GMS "Location Accuracy"
/// overlay from the location grant is still on top, so the first press
/// dismisses that, leaving the modal. We can't reliably detect the GMS overlay
/// via UI Automator, but Flutter's tree tells us whether the modal is still
/// there — so press, check, repeat. Capped at 3 to bail safely.
///
/// iOS: no back gesture — tap the X close icon in the login screen's AppBar.
/// iOS doesn't surface the GMS overlay, so one tap suffices. Guard on the modal
/// actually being present (otherwise the tap throws if it was already
/// dismissed), and scope the icon search to [LoginScreen] — the close X lives
/// in its AppBar, NOT inside LoginEmailPasswordWidget (separate subtree), and
/// an unscoped find.byIcon would risk matching a stray close icon elsewhere.
Future<void> dismissLoginModal(PatrolIntegrationTester $) async {
  if (Platform.isAndroid) {
    for (var i = 0; i < 3; i++) {
      if ($(LoginEmailPasswordWidget).evaluate().isEmpty) break;
      await $.native2.pressBack();
      await $.pumpAndSettle();
    }
  } else if ($(LoginEmailPasswordWidget).evaluate().isNotEmpty) {
    await $.tester.tap(
      find.descendant(
        of: find.byType(LoginScreen),
        matching: find.byIcon(Icons.close),
      ),
    );
    await $.pumpAndSettle();
  }
}
