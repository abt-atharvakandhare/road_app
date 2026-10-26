# Integration tests (Patrol) — quick reference

End-to-end suite (~42 tests) driving the real app against staging, locally or
on BrowserStack. This file is just the commands; setup, fork rationale, and
caveats live in [BACKGROUND.md](BACKGROUND.md). Run everything from the repo
root.

Common to all paths:

- **No `--target` = whole suite.** Repeat `--target integration_test/<file>_test.dart`
  for specific tests.
- **Credentials are baked in at build time** from a staging account
  (`TEST_EMAIL` / `TEST_PASSWORD`). If that account has MFA enabled, also pass
  `TEST_TOTP_SECRET` (the base32 secret of its authenticator-app factor); the
  login helper computes the 6-digit code itself. Only TOTP can be answered
  unattended (no SMS / email factors).
- Destructive tests (account deletion, password change, payment mutations)
  are opt-in via their own `--dart-define=RUN_*` gates and skip by default.
  The BrowserStack scripts go one step further: with no `--target`, a gated
  test is only built when its gate env var is exported (and the gate is then
  forwarded as the define), otherwise it is listed as skipped at build time
  instead of showing up as a short green "pass" on the dashboard. Gates:
  `RUN_ACCOUNT_DELETION`, `RUN_PASSWORD_CHANGE`, `RUN_PAYMENT_MUTATIONS`,
  `RUN_MFA_STEP_UP`, and `TEST_EVSE_ID` for the two charge-start tests.
- MFA coverage (`mfa_login_totp_challenge`, `mfa_step_up_cancel`,
  `mfa_step_up_profile`, `security_screen_smoke`) needs `TEST_TOTP_SECRET`
  and an account whose profile has a phone number (the step-up tests flip its
  last digit and revert). Step-up only fires once a session has outlived the
  provider's `mfaPolicy.freshnessWindow` (a TOTP login counts as proof).
  Staging's e-flux provider runs the 15-minute default, so the two step-up
  tests are gated behind `RUN_MFA_STEP_UP` and skip by default; enable them
  only against a provider with a 1-minute window (pass
  `TEST_STEP_UP_FRESHNESS_SECONDS` if it differs).

## Local

Android (debug; pick the device/emulator when prompted):

```sh
patrol test --flavor eflux \
  --dart-define=TEST_EMAIL=you@staging.example \
  --dart-define=TEST_PASSWORD=secret \
  --dart-define=TEST_TOTP_SECRET=BASE32SECRET \
  --dart-define=BIOMETRIC_INJECTED_DIALOG=false
```

iOS (release, real device):

```sh
patrol test --flavor eflux --release --device "Ray iPhone" \
  --dart-define=TEST_EMAIL=you@staging.example \
  --dart-define=TEST_PASSWORD=secret \
  --dart-define=TEST_TOTP_SECRET=BASE32SECRET \
  --dart-define=BIOMETRIC_INJECTED_DIALOG=false
```

- **Be present**: with `BIOMETRIC_INJECTED_DIALOG=false` the 3 biometric tests
  fire the real Face ID / fingerprint prompt — look at the camera.
- To iterate on one test with hot restart (`r`): `patrol develop --flavor eflux
  --target … --dart-define=…` (Android).

## BrowserStack

```sh
export BROWSERSTACK_USER=… BROWSERSTACK_KEY=…
export TEST_EMAIL=… TEST_PASSWORD=…   # only needed when building
export TEST_TOTP_SECRET=…             # if the account has MFA (authenticator app)
export TEST_SESSION_YEAR=… TEST_SESSION_MONTH=…   # a month with sessions (default 2026/7)
```

Both scripts share the same shape: `--wait` blocks and prints per-test
results, `--no-build` reuses the previous build's artefacts, `--list-devices`
prints valid `--device` strings, `--flavor` defaults to `eflux`, and
BrowserStack biometric injection is ON by default (`--no-biometric` to
disable). Optional: `export E2E_END_LINGER_SECONDS=0` for the fastest run, at
the cost of end-of-test screens no longer lingering on the session videos.

### Android — [`scripts/run_browserstack_android.sh`](../scripts/run_browserstack_android.sh)

```sh
# Whole suite on the default 4-device fleet
# (Pixel 8, Galaxy S24, Pixel 6, OnePlus 12R)
./scripts/run_browserstack_android.sh --wait

# Whole suite, single device
./scripts/run_browserstack_android.sh --device "Google Pixel 8-14.0" --wait

# Single test on the default fleet (repeat --target for a handful)
./scripts/run_browserstack_android.sh \
  --target integration_test/home_loads_test.dart --wait

# Single test on ALL devices BrowserStack offers (batched sweep)
./scripts/run_browserstack_android.sh --all-devices \
  --target integration_test/home_loads_test.dart

# Whole suite on ALL devices — compatibility sweep, takes hours
./scripts/run_browserstack_android.sh --all-devices
# …and resume a sweep that died partway (batch numbers are printed):
./scripts/run_browserstack_android.sh --all-devices --start-batch 6
```

### iOS — [`scripts/run_browserstack_ios.sh`](../scripts/run_browserstack_ios.sh)

```sh
# Whole suite; with no --device the script picks the newest iPhone on the
# iOS major the bundle was built with (Xcode SDK), e.g. "iPhone 17-26"
./scripts/run_browserstack_ios.sh --wait

# Whole suite, specific device / handful of devices
./scripts/run_browserstack_ios.sh \
  --device "iPhone 15-17" --device "iPhone 15 Pro-17" --wait

# Single test (repeat --target for a handful)
./scripts/run_browserstack_ios.sh \
  --target integration_test/home_loads_test.dart --wait
```

There is no `--all-devices` for iOS: a test bundle only runs on devices whose
iOS major matches the Xcode SDK it was built with (the script derives the
default device from that and refuses a mismatched `--device` up front), so
a full sweep is one build + one run per OS major, with `--device` lists drawn
from `--list-devices`.

iOS runs the whole bundle as ONE BrowserStack testcase (one video). `--wait`
prints the per-test breakdown via
[`scripts/bs_ios_results.sh`](../scripts/bs_ios_results.sh); run it manually
with `bs_ios_results.sh <build_id> <session_id>` for a finished build.
