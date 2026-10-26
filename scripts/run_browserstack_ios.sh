#!/usr/bin/env bash
# Build the Patrol integration test and run it on BrowserStack App Automate
# (XCUITest endpoint) for iOS.
#
# Sibling of scripts/run_browserstack.sh (Android/Espresso). BrowserStack
# resigns the uploaded .ipa automatically with its own certificate, so no
# Apple provisioning profile or device registration is needed — build
# unsigned and let BS handle signing.
#
# Usage:
#   ./run_browserstack_ios.sh [--flavor <name>] [--target <path>]... [--no-build]
#                             [--no-biometric]
#                             [--device <browserstack-ios-device-string>]... [--wait]
#   ./run_browserstack_ios.sh --list-devices
#
# Examples:
#   # Default: build the WHOLE suite (every integration_test/*_test.dart),
#   # package, upload, run on the default device
#   ./run_browserstack_ios.sh
#
#   # Just specific tests (repeat --target) — bundled into one build/run
#   ./run_browserstack_ios.sh \
#     --target integration_test/map_filter_clear_test.dart \
#     --target integration_test/explore_search_opens_test.dart --wait
#
#   # Reuse artefacts from a previous build (build/ios_integ/...)
#   ./run_browserstack_ios.sh --no-build
#
#   # Block until the build finishes and print the result
#   ./run_browserstack_ios.sh --wait
#
#   # Print every iOS device string accepted by --device, then exit
#   ./run_browserstack_ios.sh --list-devices
#
# Required env vars:
#   BROWSERSTACK_USER, BROWSERSTACK_KEY   App Automate credentials.
#   TEST_EMAIL, TEST_PASSWORD             Staging account. Baked into the test
#                                         app via --dart-define — only required
#                                         when building (i.e. without --no-build).
#
# Optional env vars (forwarded as --dart-define when set, at build time):
#   TEST_TOTP_SECRET    Base32 secret of the account's authenticator-app (TOTP)
#                       factor. Required when the account has MFA enabled, so
#                       the login helper can answer the code challenge.
#   TEST_SESSION_YEAR, TEST_SESSION_MONTH
#                       A month (e.g. 2025 / 11) in which the account has
#                       charging sessions; the session-history tests filter
#                       to it. Defaults live in _helpers/session_period.dart.
#   TEST_STEP_UP_FRESHNESS_SECONDS
#                       The staging provider's mfaPolicy.freshnessWindow in
#                       seconds (default 60). The step-up tests idle until the
#                       session outlives it.
#   RUN_ACCOUNT_DELETION, RUN_PASSWORD_CHANGE, RUN_PAYMENT_MUTATIONS,
#   RUN_MFA_STEP_UP     Opt-in gates for the destructive/mutating tests. A
#                       gated test is only built into a no---target (whole
#                       suite) run when its gate is exported (and it is then
#                       passed on as a --dart-define); otherwise it is left out
#                       entirely, so it can't show up as a 16s "pass" that only
#                       logged a SKIP. TEST_EVSE_ID gates add_card +
#                       charging_session_fgs_demo the same way. An explicit
#                       --target always builds the test, gate or not.
#
# Packaging mirrors leancodepl/mobile-tools `bs_ios`, adapted for our classic
# (non-test-plan) xctestrun: the DiagnosticCollectionPolicy key BS rejects sits
# under the RunnerUITests target, not under TestConfigurations.
#
# See integration_test/README.md for the command cheat-sheet and
# integration_test/BACKGROUND.md for background on the patrol fork.

# NOT set -e: we want curl error response bodies to print instead of the
# script dying silently on a non-2xx.
set -uo pipefail

# Gate env var for a test file, empty for ungated tests. Keep in sync with the
# `bool.fromEnvironment('RUN_*')` / TEST_EVSE_ID checks inside the tests and
# with run_browserstack_android.sh.
gate_for_test() {
  case "$(basename "$1")" in
    account_deletion_test.dart)                                   echo RUN_ACCOUNT_DELETION ;;
    password_change_test.dart)                                    echo RUN_PASSWORD_CHANGE ;;
    delete_payment_method_test.dart|set_default_payment_method_test.dart) echo RUN_PAYMENT_MUTATIONS ;;
    add_card_from_charge_now_test.dart|charging_session_fgs_demo_test.dart) echo TEST_EVSE_ID ;;
    mfa_step_up_cancel_test.dart|mfa_step_up_profile_test.dart)     echo RUN_MFA_STEP_UP ;;
    *) echo "" ;;
  esac
}

FLAVOR="eflux"
# No --target = build the whole suite (every integration_test/*_test.dart). Pass
# --target one or more times to build just those tests into one test bundle.
TARGETS=()
BUILD=1
WAIT=0
LIST_DEVICES=0
DEVICES=()

# BrowserStack biometric injection (XCUITest). Requires Device Cloud Pro /
# Enterprise Pro. ON by default to match the Android script: the suite's
# biometric tests are built with BIOMETRIC_INJECTED_DIALOG=true (the app's
# default) and REQUIRE this injected dialog — without it they fail. Pass
# --no-biometric for a base-plan account or a single non-biometric --target run.
ENABLE_BIOMETRIC="true"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --flavor)        FLAVOR="$2"; shift 2 ;;
    --target)        TARGETS+=("$2"); shift 2 ;;
    --no-build)      BUILD=0; shift ;;
    --biometric)     ENABLE_BIOMETRIC="true"; shift ;;
    --no-biometric)  ENABLE_BIOMETRIC="false"; shift ;;
    --device)        DEVICES+=("$2"); shift 2 ;;
    --wait)          WAIT=1; shift ;;
    --list-devices)  LIST_DEVICES=1; shift ;;
    *) echo "error: unknown arg: $1" >&2; exit 1 ;;
  esac
done

# BrowserStack wants "<display name>-<os_version>" (e.g. "Google Pixel 8-14.0",
# "iPhone 15-17"); a bare name is rejected by the trigger only AFTER the build
# and upload, so validate up front. --list-devices prints accepted strings.
for d in ${DEVICES[@]+"${DEVICES[@]}"}; do
  if [[ ! "$d" =~ -[0-9]+(\.[0-9]+)?$ ]]; then
    echo "error: --device \"$d\" must end in -<os_version>, e.g. \"$d-17\" (see --list-devices)" >&2
    exit 1
  fi
done

if [[ "$LIST_DEVICES" -eq 1 ]]; then
  for cmd in curl jq; do
    command -v "$cmd" >/dev/null 2>&1 \
      || { echo "error: $cmd not found." >&2; exit 1; }
  done
  : "${BROWSERSTACK_USER:?error: set BROWSERSTACK_USER}"
  : "${BROWSERSTACK_KEY:?error: set BROWSERSTACK_KEY}"
  # Every iOS device BrowserStack offers, "Model-OSVersion" (the --device format),
  # sorted by version. NOTE: build the iOS test bundle with an Xcode whose SDK
  # major matches the device OS major you pick here — a runner built with a newer
  # Xcode strong-links XCTest symbols the older device lacks and aborts at launch
  # (e.g. an iOS 26.x build only runs on a "-26" device, not "-17"/"-18").
  curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
    'https://api-cloud.browserstack.com/app-automate/devices.json' \
    | jq -r '.[] | select(.os == "ios") | "\(.device)-\(.os_version)"' \
    | sort -V
  exit 0
fi


for cmd in patrol curl jq plutil zip; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: $cmd not found." >&2; exit 1; }
done

: "${BROWSERSTACK_USER:?error: set BROWSERSTACK_USER}"
: "${BROWSERSTACK_KEY:?error: set BROWSERSTACK_KEY}"
BS_AUTH="$BROWSERSTACK_USER:$BROWSERSTACK_KEY"

PRODUCTS="build/ios_integ/Build/Products"
RELEASE_DIR="$PRODUCTS/Release-${FLAVOR}-iphoneos"

if [[ "$BUILD" -eq 1 ]]; then
  : "${TEST_EMAIL:?error: set TEST_EMAIL (baked into the test app via --dart-define)}"
  : "${TEST_PASSWORD:?error: set TEST_PASSWORD (baked into the test app via --dart-define)}"

  # Build one --target flag per requested test; with none, patrol bundles every
  # integration_test/*_test.dart. Either way BrowserStack runs each bundled test
  # as a separate testcase.
  # No --target: enumerate the suite ourselves instead of letting patrol
  # bundle the directory, so gated tests whose gate isn't exported can be left
  # out (they would otherwise run, log a SKIP and read as a short pass on the
  # BrowserStack dashboard). Logged so the exclusion is never silent.
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    excluded=()
    for t in integration_test/*_test.dart; do
      gate="$(gate_for_test "$t")"
      if [[ -n "$gate" && -z "${!gate:-}" ]]; then
        excluded+=("$(basename "$t" .dart) (needs $gate)")
        continue
      fi
      TARGETS+=("$t")
    done
    if [[ ${#excluded[@]} -gt 0 ]]; then
      echo "→ Skipping gated tests (export the gate to include them):"
      printf '    %s\n' "${excluded[@]}"
    fi
  fi
  target_args=()
  for t in ${TARGETS[@]+"${TARGETS[@]}"}; do
    target_args+=(--target "$t")
  done
  echo "→ patrol build ios --release (flavor=${FLAVOR}, ${#TARGETS[@]} targets: ${TARGETS[*]})"
  # E2E_END_LINGER_SECONDS: per-test linger on the final screen (app default
  # 2s). We deliberately DON'T zero it here — the linger is what makes each
  # test's end state visible on the BrowserStack session video, at a cost of
  # ~2s × N tests. Export E2E_END_LINGER_SECONDS=0 for a fastest-possible run.
  linger_args=()
  if [[ -n "${E2E_END_LINGER_SECONDS:-}" ]]; then
    linger_args+=(--dart-define="E2E_END_LINGER_SECONDS=${E2E_END_LINGER_SECONDS}")
  fi
  extra_defines=()
  if [[ -n "${TEST_TOTP_SECRET:-}" ]]; then
    extra_defines+=(--dart-define="TEST_TOTP_SECRET=${TEST_TOTP_SECRET}")
  fi
  if [[ -n "${TEST_EVSE_ID:-}" ]]; then
    extra_defines+=(--dart-define="TEST_EVSE_ID=${TEST_EVSE_ID}")
  fi
  if [[ -n "${TEST_STEP_UP_FRESHNESS_SECONDS:-}" ]]; then
    extra_defines+=(--dart-define="TEST_STEP_UP_FRESHNESS_SECONDS=${TEST_STEP_UP_FRESHNESS_SECONDS}")
  fi
  for gate in RUN_ACCOUNT_DELETION RUN_PASSWORD_CHANGE RUN_PAYMENT_MUTATIONS RUN_MFA_STEP_UP; do
    if [[ -n "${!gate:-}" ]]; then
      extra_defines+=(--dart-define="${gate}=true")
    fi
  done
  if [[ -n "${TEST_SESSION_YEAR:-}" ]]; then
    extra_defines+=(--dart-define="TEST_SESSION_YEAR=${TEST_SESSION_YEAR}")
  fi
  if [[ -n "${TEST_SESSION_MONTH:-}" ]]; then
    extra_defines+=(--dart-define="TEST_SESSION_MONTH=${TEST_SESSION_MONTH}")
  fi
  patrol build ios --release \
    --flavor "$FLAVOR" \
    ${target_args[@]+"${target_args[@]}"} \
    ${linger_args[@]+"${linger_args[@]}"} \
    ${extra_defines[@]+"${extra_defines[@]}"} \
    --dart-define="TEST_EMAIL=${TEST_EMAIL}" \
    --dart-define="TEST_PASSWORD=${TEST_PASSWORD}"
fi

# Locate the test-plan xctestrun (scheme=<flavor>, plan=TestPlan). The TestPlan
# is what makes BS run Patrol's RunnerUITests class — without it BS statically
# shards bundled-framework classes (GMSx_*, GMPx_*) and never runs the real test.
XCTESTRUN="$(ls "${PRODUCTS}/${FLAVOR}_TestPlan_iphoneos"*.xctestrun 2>/dev/null | head -1)"
if [[ -z "$XCTESTRUN" || ! -f "$XCTESTRUN" ]]; then
  echo "error: no xctestrun at ${PRODUCTS}/${FLAVOR}_TestPlan_iphoneos*.xctestrun" >&2
  echo "       (run without --no-build; needs the TestPlan wired into the ${FLAVOR} scheme)" >&2
  exit 1
fi
for app in "${RELEASE_DIR}/Runner.app" "${RELEASE_DIR}/RunnerUITests-Runner.app"; do
  [[ -d "$app" ]] || { echo "error: missing $app" >&2; exit 1; }
done

# The iOS major the bundle was built against, from the xctestrun name
# (…_iphoneos26.5-arm64.xctestrun → 26). A runner strong-links XCTest symbols
# of its SDK, so it only launches on devices of that same iOS major; anything
# else aborts at launch with "Symbol not found: _OBJC_CLASS_$_XCT…" before a
# single test runs. Derive the device from the SDK rather than hard-coding one
# that goes stale with every Xcode upgrade.
SDK_MAJOR="$(basename "$XCTESTRUN" | sed -E 's/.*_iphoneos([0-9]+)\..*/\1/')"
if [[ ! "$SDK_MAJOR" =~ ^[0-9]+$ ]]; then
  echo "error: cannot read the iOS SDK major from $(basename "$XCTESTRUN")" >&2
  exit 1
fi
if [[ ${#DEVICES[@]} -eq 0 ]]; then
  # Newest numbered iPhone BrowserStack offers on that major (skips iPads and
  # the unnumbered "iPhone Air"/"…e" variants so sort -V picks sensibly).
  default_device="$(curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
      'https://api-cloud.browserstack.com/app-automate/devices.json' \
    | jq -r --arg major "$SDK_MAJOR" \
        '.[] | select(.os == "ios" and (.os_version | tostring) == $major and (.device | test("^iPhone [0-9]+( Pro)?$"))) | "\(.device)-\(.os_version)"' \
    | sort -V | tail -1)"
  if [[ -z "$default_device" ]]; then
    echo "error: BrowserStack offers no iPhone on iOS ${SDK_MAJOR} (the SDK this bundle was built with); see --list-devices" >&2
    exit 1
  fi
  DEVICES=("$default_device")
  echo "→ No --device given; bundle is iOS ${SDK_MAJOR} SDK, using \"${default_device}\""
else
  for d in "${DEVICES[@]}"; do
    if [[ "${d##*-}" != "$SDK_MAJOR" && "${d##*-}" != "$SDK_MAJOR".* ]]; then
      echo "error: --device \"$d\" runs iOS ${d##*-} but this bundle was built with the iOS ${SDK_MAJOR} SDK and will abort at launch on it." >&2
      echo "       Pick a \"-${SDK_MAJOR}\" device (see --list-devices) or build with a matching Xcode." >&2
      exit 1
    fi
  done
fi

# Package the app under test as a .ipa (zip with a Payload/ wrapper).
echo "→ Packaging Runner.ipa"
( cd "$PRODUCTS" \
  && rm -rf Payload Runner.ipa \
  && mkdir -p Payload \
  && cp -r "Release-${FLAVOR}-iphoneos/Runner.app" Payload/ \
  && zip -qr Runner.ipa Payload )

# Package the test suite: the test-plan xctestrun + the UITest runner app, both
# at the zip ROOT. Three adjustments:
#  - Remove DiagnosticCollectionPolicy (BS rejects an xctestrun carrying it). In
#    the test-plan format it lives at TestConfigurations.0.TestTargets.0.
#  - BS's test-suite endpoint wants the *-Runner.app at the zip root, so we zip
#    from inside the release dir.
#  - The xctestrun's paths are __TESTROOT__/Release-<flavor>-iphoneos/… but with
#    the runner at the zip root, TESTROOT is the zip root — flatten the paths to
#    __TESTROOT__/… so they resolve.
echo "→ Packaging ios_tests.zip"
XCTESTRUN_NAME="$(basename "$XCTESTRUN")"
cp "$XCTESTRUN" "${RELEASE_DIR}/${XCTESTRUN_NAME}"
plutil -remove 'TestConfigurations.0.TestTargets.0.DiagnosticCollectionPolicy' \
  "${RELEASE_DIR}/${XCTESTRUN_NAME}" 2>/dev/null || true
plutil -convert xml1 "${RELEASE_DIR}/${XCTESTRUN_NAME}"
# BSD sed wants -i '' where GNU sed wants bare -i; branch so a Linux runner
# doesn't choke here. (The plutil calls above still tie the build step to
# macOS today, but don't add a second portability landmine.)
if [[ "$OSTYPE" == darwin* ]]; then
  sed -i '' "s|__TESTROOT__/Release-${FLAVOR}-iphoneos/|__TESTROOT__/|g" "${RELEASE_DIR}/${XCTESTRUN_NAME}"
else
  sed -i "s|__TESTROOT__/Release-${FLAVOR}-iphoneos/|__TESTROOT__/|g" "${RELEASE_DIR}/${XCTESTRUN_NAME}"
fi
( cd "$RELEASE_DIR" \
  && rm -f ios_tests.zip \
  && zip -qr ios_tests.zip "$XCTESTRUN_NAME" RunnerUITests-Runner.app )

APP_IPA="${PRODUCTS}/Runner.ipa"
TEST_ZIP="${RELEASE_DIR}/ios_tests.zip"

# Upload helper — surfaces the raw response on failure instead of feeding a
# non-2xx body into jq.
upload() {
  local endpoint="$1" file="$2" key="$3" response
  response="$(curl -sS -u "$BS_AUTH" \
    -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/${endpoint}" \
    -F "file=@${file}")"
  if ! echo "$response" | jq -er ".${key}" 2>/dev/null; then
    echo "error: upload to /${endpoint} failed. response:" >&2
    echo "$response" >&2
    return 1
  fi
}

echo "→ Uploading app .ipa"
APP_URL="$(upload app "$APP_IPA" app_url)" || exit 1
echo "  ${APP_URL}"

echo "→ Uploading test suite"
TEST_URL="$(upload test-suite "$TEST_ZIP" test_suite_url)" || exit 1
echo "  ${TEST_URL}"

DEVICES_JSON="$(printf '%s\n' "${DEVICES[@]}" | jq -R . | jq -s .)"
# The xctestrun (from the TestPlan) scopes execution to Patrol's RunnerUITests
# class, so no onlyTesting filter is needed — and BS silently ignores onlyTesting
# on this endpoint anyway.
# enableBiometric is a JSON *string* on purpose: BS's docs use that form and
# parse it by value, hence --arg not --argjson (mirrors the Android script).
PAYLOAD="$(jq -n \
  --arg app "$APP_URL" \
  --arg testSuite "$TEST_URL" \
  --argjson devices "$DEVICES_JSON" \
  --arg enableBiometric "$ENABLE_BIOMETRIC" \
  '{app: $app, testSuite: $testSuite, devices: $devices, project: "road_mobile",
    enableBiometric: $enableBiometric,
    deviceLogs: true, enableResultBundle: true,
    networkLogs: true, idleTimeout: 120}')"

echo "→ Triggering build on: ${DEVICES[*]}"
RESPONSE="$(curl -sS -u "$BS_AUTH" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/xctestrun-build" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")"

if ! BUILD_ID="$(echo "$RESPONSE" | jq -er .build_id 2>/dev/null)"; then
  echo "error: build trigger failed. response:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo
echo "Build queued: ${BUILD_ID}"
echo "  Dashboard:  https://app-automate.browserstack.com/dashboard/v2/builds/${BUILD_ID}"

if [[ "$WAIT" -eq 1 ]]; then
  POLL_INTERVAL=15
  # Full suite (no --target) runs ~42 tests in one session — give it a much
  # larger budget than a targeted run.
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    TIMEOUT_SECS=$((60 * 60))
  else
    TIMEOUT_SECS=$((30 * 60))
  fi
  deadline=$(( $(date +%s) + TIMEOUT_SECS ))
  echo
  echo "→ Waiting for build to finish (poll every ${POLL_INTERVAL}s, ${TIMEOUT_SECS}s timeout)"
  while :; do
    BUILD_JSON="$(curl -sS -u "$BS_AUTH" \
      "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/builds/${BUILD_ID}")"
    STATUS="$(echo "$BUILD_JSON" | jq -r '.status // "unknown"')"
    case "$STATUS" in
      running|queued|unknown)
        if [[ $(date +%s) -ge $deadline ]]; then
          echo; echo "error: timed out waiting (still ${STATUS})" >&2; exit 1
        fi
        printf '.'
        sleep "$POLL_INTERVAL"
        ;;
      *)
        echo; echo "→ Build finished: ${STATUS}"
        echo "$BUILD_JSON" | jq -r '.devices[]? | "  \(.device) \(.os_version): \(.sessions[0].status // "?")"'

        # Per-test PASS/FAIL breakdown in execution order. iOS runs the whole
        # Patrol bundle as ONE XCUITest session (one dashboard testcase + one
        # video), so this parse of the runner's per-test log lines is the only
        # way to see individual results and where to scrub the video. Runs for
        # pass AND fail; best-effort, never fails the run.
        echo
        echo "→ Per-test results:"
        for sid in $(echo "$BUILD_JSON" | jq -r '.devices[]?.sessions[]?.id // empty'); do
          "$(dirname "$0")/bs_ios_results.sh" "$BUILD_ID" "$sid" || true
        done

        if [[ "$STATUS" != "passed" ]]; then
          # Pull per-session diagnostics so a launch/resigning failure isn't
          # just an opaque "error". Prints the session detail JSON (which
          # carries the failure reason + log URLs) for each session.
          echo
          echo "→ Session diagnostics:"
          for sid in $(echo "$BUILD_JSON" | jq -r '.devices[]?.sessions[]?.id // empty'); do
            echo "  session ${sid}:"
            curl -sS -u "$BS_AUTH" \
              "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/builds/${BUILD_ID}/sessions/${sid}" \
              | jq '{status, reason: (.reason // .error // "n/a"), device_logs, appium_logs, test_logs}' 2>/dev/null \
              | sed 's/^/    /'
          done
          exit 1
        fi
        break
        ;;
    esac
  done
fi
