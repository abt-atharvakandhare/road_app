#!/usr/bin/env bash
# Build the Patrol integration test and run it on BrowserStack App Automate
# (Espresso endpoint).
#
# Usage:
#   ./run_browserstack_android.sh [--flavor <name>] [--target <path>]... [--no-build]
#                         [--device <browserstack-device-string>]... [--all-devices] [--wait]
#   ./run_browserstack_android.sh --list-devices
#
# Examples:
#   # Default: build the WHOLE suite (every integration_test/*_test.dart),
#   # upload, run on the default device list
#   ./run_browserstack_android.sh
#
#   # Just specific tests (repeat --target) — bundled into one build/run
#   ./run_browserstack_android.sh \
#     --target integration_test/map_filter_clear_test.dart \
#     --target integration_test/explore_search_opens_test.dart \
#     --device "Google Pixel 8-14.0" --wait
#
#   # Reuse APKs from a previous local build
#   ./run_browserstack_android.sh --no-build
#
#   # Different flavor + specific devices
#   ./run_browserstack_android.sh --flavor elexon \
#     --device "Google Pixel 8-14.0" \
#     --device "Samsung Galaxy S24-14.0"
#
#   # Full compatibility sweep: every Android device BrowserStack offers.
#   # Runs in sequential batches sized to the plan's parallel+queue capacity;
#   # minutes are unlimited but a full sweep takes hours of wall-clock.
#   ./run_browserstack_android.sh --all-devices
#
#   # Resume a sweep that died partway (batch numbers are printed as it runs)
#   ./run_browserstack_android.sh --all-devices --start-batch 6
#
#   # Block until the build finishes, then print video URLs per testcase
#   ./run_browserstack_android.sh --no-build --wait
#
#   # Enable BrowserStack biometric injection (Device Cloud Pro+) for a test
#   # that drives an OS biometric prompt
#   ./run_browserstack_android.sh --biometric --device "Google Pixel 8-14.0" --wait
#
#   # Print every Android device string accepted by --device, then exit
#   ./run_browserstack_android.sh --list-devices
#
# Required env vars:
#   BROWSERSTACK_USER, BROWSERSTACK_KEY   App Automate credentials.
#   TEST_EMAIL, TEST_PASSWORD             Staging account. Baked into the test
#                                         APK via --dart-define — only required
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
#   TEST_EVSE_ID        7-digit staging connector for tests that start/inspect a
#                       charge (charging_session_fgs_demo, add_card, …).
#   E2E_PROVIDER_SLUG   Provider slug override seeded with the staging prefs.
#                       Staging doesn't host most WL provider slugs, so pass
#                       e-flux when running a non-eflux flavor.
#
# See integration_test/README.md for the command cheat-sheet and
# integration_test/BACKGROUND.md for the BrowserStack flow and patrol fork.

set -euo pipefail

# Gate env var for a test file, empty for ungated tests. Keep in sync with the
# `bool.fromEnvironment('RUN_*')` / TEST_EVSE_ID checks inside the tests.
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
# --target one or more times to build just those tests into one APK (BrowserStack
# runs each as a separate testcase).
TARGETS=()
BUILD=1
WAIT=0
LIST_DEVICES=0
ALL_DEVICES=0
START_BATCH=1
DEVICES=()

# BrowserStack biometric injection. Requires Device Cloud Pro / Enterprise Pro.
# ON by default: the suite's biometric tests are built with
# BIOMETRIC_INJECTED_DIALOG=true (the app's default), so they poll for and
# REQUIRE this injected dialog — without it they fail. Harmless when no prompt
# fires. Pass --no-biometric for a base-plan account or a single non-biometric
# --target run.
ENABLE_BIOMETRIC="true"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --flavor)        FLAVOR="$2"; shift 2 ;;
    --target)        TARGETS+=("$2"); shift 2 ;;
    --no-build)      BUILD=0; shift ;;
    --device)        DEVICES+=("$2"); shift 2 ;;
    --wait)          WAIT=1; shift ;;
    --biometric)     ENABLE_BIOMETRIC="true"; shift ;;
    --no-biometric)  ENABLE_BIOMETRIC="false"; shift ;;
    --list-devices)  LIST_DEVICES=1; shift ;;
    --all-devices)   ALL_DEVICES=1; shift ;;
    --start-batch)   START_BATCH="$2"; shift 2 ;;
    *) echo "error: unknown arg: $1" >&2; exit 1 ;;
  esac
done

# BrowserStack wants "<display name>-<os_version>" (e.g. "Google Pixel 8-14.0",
# "iPhone 15-17"); a bare name is rejected by the trigger only AFTER the build
# and upload, so validate up front. --list-devices prints accepted strings.
for d in ${DEVICES[@]+"${DEVICES[@]}"}; do
  if [[ ! "$d" =~ -[0-9]+(\.[0-9]+)?$ ]]; then
    echo "error: --device \"$d\" must end in -<os_version>, e.g. \"$d-14.0\" (see --list-devices)" >&2
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
  curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
    'https://api-cloud.browserstack.com/app-automate/devices.json' \
    | jq -r '.[] | select(.os == "android" and ((.os_version | tonumber?) // 0) >= 8) | "\(.device)-\(.os_version)"' \
    | sort
  exit 0
fi

if [[ "$ALL_DEVICES" -eq 0 && ${#DEVICES[@]} -eq 0 ]]; then
  # Default fleet. BrowserStack shards these across the plan's parallel slots
  # under a single build_id. Coverage rationale:
  #   - Pixel 8-14.0     : stock Android 14 baseline
  #   - Galaxy S24-14.0  : Samsung One UI on the same OS
  #   - Pixel 6-12.0     : pre-Android-13 notification permission path
  #   - OnePlus 12R-14.0 : OxygenOS, same OS as the flagships
  DEVICES=(
    "Google Pixel 8-14.0"
    "Samsung Galaxy S24-14.0"
    "Google Pixel 6-12.0"
    "OnePlus 12R-14.0"
  )
fi

for cmd in patrol curl jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: $cmd not found." >&2
    exit 1
  fi
done

: "${BROWSERSTACK_USER:?error: set BROWSERSTACK_USER}"
: "${BROWSERSTACK_KEY:?error: set BROWSERSTACK_KEY}"

# --all-devices: replace the device list with every Android 8.0+ device
# BrowserStack offers (same query as --list-devices). The 8.0 floor matches the
# app's minSdkVersion 26 — older devices can't install the APK, so including
# them would just produce install-failure noise. App Automate minutes are
# unlimited, so the only cost is wall-clock: BS shards across the plan's
# parallel slots and queues the rest, so a full sweep can take a while.
# Intended for compatibility sweeps, not routine per-PR CI. Overrides any
# --device passed. `while read` (not mapfile) for macOS bash 3.2 compatibility.
if [[ "$ALL_DEVICES" -eq 1 ]]; then
  echo "→ Fetching all available Android devices from BrowserStack…"
  DEVICES=()
  while IFS= read -r _dev; do
    [[ -n "$_dev" ]] && DEVICES+=("$_dev")
  done < <(curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
    'https://api-cloud.browserstack.com/app-automate/devices.json' \
    | jq -r '.[] | select(.os == "android" and ((.os_version | tonumber?) // 0) >= 8) | "\(.device)-\(.os_version)"' | sort -u)
  if [[ ${#DEVICES[@]} -eq 0 ]]; then
    echo "error: no Android devices returned from BrowserStack" >&2
    exit 1
  fi
  echo "→ ${#DEVICES[@]} devices selected."
fi

# Debug APKs (signed with the debug keystore). BrowserStack Espresso accepts
# these and patrol build android defaults to debug. Release would need a
# signing config and adds no value here.
APP_APK="build/app/outputs/apk/${FLAVOR}/debug/app-${FLAVOR}-debug.apk"
TEST_APK="build/app/outputs/apk/androidTest/${FLAVOR}/debug/app-${FLAVOR}-debug-androidTest.apk"

if [[ "$BUILD" -eq 1 ]]; then
  : "${TEST_EMAIL:?error: set TEST_EMAIL (baked into the test APK via --dart-define)}"
  : "${TEST_PASSWORD:?error: set TEST_PASSWORD (baked into the test APK via --dart-define)}"

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
  echo "→ patrol build android (flavor=${FLAVOR}, ${#TARGETS[@]} targets: ${TARGETS[*]})"
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
  if [[ -n "${TEST_EVSE_ID:-}" ]]; then
    extra_defines+=(--dart-define="TEST_EVSE_ID=${TEST_EVSE_ID}")
  fi
  if [[ -n "${E2E_PROVIDER_SLUG:-}" ]]; then
    extra_defines+=(--dart-define="E2E_PROVIDER_SLUG=${E2E_PROVIDER_SLUG}")
  fi
  patrol build android \
    --flavor "$FLAVOR" \
    ${target_args[@]+"${target_args[@]}"} \
    ${linger_args[@]+"${linger_args[@]}"} \
    ${extra_defines[@]+"${extra_defines[@]}"} \
    --dart-define="TEST_EMAIL=${TEST_EMAIL}" \
    --dart-define="TEST_PASSWORD=${TEST_PASSWORD}"
fi

for apk in "$APP_APK" "$TEST_APK"; do
  if [[ ! -f "$apk" ]]; then
    echo "error: missing APK at $apk" >&2
    echo "       (run without --no-build, or check the flavor)" >&2
    exit 1
  fi
done

# Upload to BrowserStack. On non-2xx, surface the raw response so failures
# (auth, quota, malformed APK) are visible instead of disappearing into jq.
upload() {
  local endpoint="$1" file="$2" key="$3" response
  response="$(curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
    -X POST "https://api-cloud.browserstack.com/app-automate/espresso/v2/${endpoint}" \
    -F "file=@${file}")"
  if ! echo "$response" | jq -er ".${key}" 2>/dev/null; then
    echo "error: upload to /${endpoint} failed. response:" >&2
    echo "$response" >&2
    return 1
  fi
}

echo "→ Uploading app APK"
APP_URL="$(upload app "$APP_APK" app_url)"
echo "  ${APP_URL}"

echo "→ Uploading test APK"
TEST_URL="$(upload test-suite "$TEST_APK" test_suite_url)"
echo "  ${TEST_URL}"

# Per-build device capacity = parallel slots + queue slots. BrowserStack rejects
# a build that requests more devices than this (BROWSERSTACK_ALL_PARALLELS_IN_USE).
# Query the plan so the batch size self-adjusts to the account; fall back to 6
# (1 running + 5 queued — the Device Cloud Pro single-session default) if the
# query fails.
CAPACITY="$(curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
  'https://api-cloud.browserstack.com/app-automate/plan.json' 2>/dev/null \
  | jq -r '((.parallel_sessions_max_allowed // 1) + (.queued_sessions_max_allowed // 5))' 2>/dev/null)"
[[ "$CAPACITY" =~ ^[0-9]+$ && "$CAPACITY" -gt 0 ]] || CAPACITY=6

# Batch one device BELOW capacity so there's always a free slot of headroom:
# when a batch finishes, BS can take a few seconds to release the session, and a
# next batch sized at full capacity would be rejected (ALL_PARALLELS_IN_USE).
# The spare slot absorbs that lag.
BATCH_SIZE=$(( CAPACITY > 1 ? CAPACITY - 1 : 1 ))

# Per-device wait budget. A batch runs its devices one at a time (1 parallel),
# so the batch timeout must scale with batch size — a flat 30m timed out on
# full batches and left a session running, which then blocked the next trigger
# and cascaded. 10m/device is generous enough for slow tablets / old OS running
# a handful of tests. The full suite (default, no --target) runs ~42 tests
# sequentially on one device with a state reset between each, so it needs a
# much larger budget.
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  PER_DEVICE_TIMEOUT=$(( 60 * 60 ))
else
  PER_DEVICE_TIMEOUT=$(( 10 * 60 ))
fi

SWEEP_PASSED=0
SWEEP_FAILED=0

# trigger_build <devices-json> — echoes the build_id, or fails with the raw
# response. Retries on ALL_PARALLELS_IN_USE, since a just-finished batch's
# session can take a moment to release the slot. enableBiometric is a JSON
# *string* on purpose: BS's docs use that form and parse it by value, hence
# --arg not --argjson.
#
# NOTE ON SIGNING: BrowserStack ALWAYS resigns the app for Espresso (the app +
# test APKs must share a cert for instrumentation), so `resignApp:false` is a
# no-op here — you can't keep our own cert. BS's resign cert
# (SHA-1 D3:77:42:9F:C7:0F:41:70:0E:F7:49:15:67:16:A6:86:5F:15:30:5A) is
# whitelisted for com.eflux.ev on the "Road App - Android" Maps/Places key
# (eflux-production, key 5e532260), which is what makes the map + Places search
# work on BS. If BS rotates that cert, re-whitelist the new one.
trigger_build() {
  local devices_json="$1" payload response build_id attempt
  payload="$(jq -n \
    --arg app "$APP_URL" \
    --arg testSuite "$TEST_URL" \
    --argjson devices "$devices_json" \
    --arg enableBiometric "$ENABLE_BIOMETRIC" \
    '{app: $app, testSuite: $testSuite, devices: $devices, project: "road_mobile",
      enableBiometric: $enableBiometric}')"
  for attempt in $(seq 1 10); do
    response="$(curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
      -X POST "https://api-cloud.browserstack.com/app-automate/espresso/v2/build" \
      -H "Content-Type: application/json" \
      -d "$payload")"
    if build_id="$(echo "$response" | jq -er .build_id 2>/dev/null)"; then
      echo "$build_id"
      return 0
    fi
    if echo "$response" | grep -q ALL_PARALLELS_IN_USE; then
      echo "  parallels busy; retrying in 30s (attempt ${attempt}/10)…" >&2
      sleep 30
      continue
    fi
    echo "error: build trigger failed. response:" >&2
    echo "$response" >&2
    return 1
  done
  echo "error: parallels still busy after 10 retries (~5m)" >&2
  return 1
}

# wait_for_build <build_id> <device_count> — polls to completion (timeout scaled
# by device count), prints per-device status + testcase video URLs, and adds
# per-device pass/fail to SWEEP_PASSED/FAILED. Returns nonzero unless passed.
wait_for_build() {
  local build_id="$1" device_count="$2" deadline status build_json
  deadline=$(( $(date +%s) + device_count * PER_DEVICE_TIMEOUT ))
  while :; do
    build_json="$(curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
      "https://api-cloud.browserstack.com/app-automate/espresso/v2/builds/${build_id}")"
    status="$(echo "$build_json" | jq -r '.status // "unknown"')"
    case "$status" in
      running|queued|unknown)
        if [[ $(date +%s) -ge $deadline ]]; then
          echo; echo "  error: timed out waiting (still ${status})" >&2; return 1
        fi
        printf '.'; sleep 15 ;;
      *) echo; echo "  → build ${status}"; break ;;
    esac
  done

  # Per-device status + testcase video URLs (videos live on the session
  # endpoint). `?` guards skip a device that never started a session.
  echo "$build_json" \
    | jq -r '.devices[] | . as $d | $d.sessions[]?
             | "\($d.device) \($d.os_version)\t\(.id)\t\(.status)"' \
    | while IFS=$'\t' read -r DEVICE_LABEL SESSION_ID SESSION_STATUS; do
        [[ -n "$SESSION_ID" && "$SESSION_ID" != "null" ]] || continue
        echo "  ${DEVICE_LABEL}: ${SESSION_STATUS}"
        curl -sS -u "$BROWSERSTACK_USER:$BROWSERSTACK_KEY" \
          "https://api-cloud.browserstack.com/app-automate/espresso/v2/builds/${build_id}/sessions/${SESSION_ID}" \
          | jq -r '.testcases.data[]?.testcases[]? | select(.video != null)
                   | "    [\(.status)] \(.class // "?").\(.name)\n      \(.video)"'
      done

  SWEEP_PASSED=$(( SWEEP_PASSED + $(echo "$build_json" | jq '[.devices[].sessions[]? | select(.status == "passed")] | length') ))
  SWEEP_FAILED=$(( SWEEP_FAILED + $(echo "$build_json" | jq '[.devices[].sessions[]? | select(.status != "passed")] | length') ))
  [[ "$status" == "passed" ]]
}

TOTAL=${#DEVICES[@]}

if [[ "$TOTAL" -le "$BATCH_SIZE" ]]; then
  # Fits in a single build.
  echo "→ Triggering build on: ${DEVICES[*]}"
  DEVICES_JSON="$(printf '%s\n' "${DEVICES[@]}" | jq -R . | jq -s .)"
  BUILD_ID="$(trigger_build "$DEVICES_JSON")" || exit 1
  echo
  echo "Build queued: ${BUILD_ID}"
  echo "  Dashboard:  https://app-automate.browserstack.com/dashboard/v2/builds/${BUILD_ID}"
  if [[ "$WAIT" -eq 1 ]]; then
    echo "→ Waiting for build to finish…"
    wait_for_build "$BUILD_ID" "$TOTAL" || exit 1
  fi
else
  # More devices than one batch can hold. Run BATCH_SIZE-device batches
  # sequentially — each waits before the next, so we never exceed the queue.
  # With 1 parallel the wall-clock equals a single big queue anyway, and App
  # Automate minutes are unlimited. (--wait is implied; batching must wait.)
  # --start-batch resumes a previous run; batch numbers are 1-indexed and
  # relative to the current BATCH_SIZE (and to the live device ordering).
  TOTAL_BATCHES=$(( (TOTAL + BATCH_SIZE - 1) / BATCH_SIZE ))
  echo "→ ${TOTAL} devices in batches of ${BATCH_SIZE} (${TOTAL_BATCHES} batches);" \
       "starting at batch ${START_BATCH}."
  idx=0
  batch_no=0
  while [[ $idx -lt $TOTAL ]]; do
    batch_no=$(( batch_no + 1 ))
    if [[ $batch_no -lt $START_BATCH ]]; then
      idx=$(( idx + BATCH_SIZE ))
      continue
    fi
    batch=("${DEVICES[@]:idx:BATCH_SIZE}")
    echo
    echo "── Batch ${batch_no}/${TOTAL_BATCHES} (devices $(( idx + 1 ))-$(( idx + ${#batch[@]} )) of ${TOTAL}): ${batch[*]}"
    BATCH_JSON="$(printf '%s\n' "${batch[@]}" | jq -R . | jq -s .)"
    if BUILD_ID="$(trigger_build "$BATCH_JSON")"; then
      echo "  Build ${BUILD_ID}  https://app-automate.browserstack.com/dashboard/v2/builds/${BUILD_ID}"
      wait_for_build "$BUILD_ID" "${#batch[@]}" || true
    else
      echo "  → batch ${batch_no} could not start; resume later with" \
           "--start-batch ${batch_no}" >&2
      SWEEP_FAILED=$(( SWEEP_FAILED + ${#batch[@]} ))
    fi
    idx=$(( idx + BATCH_SIZE ))
  done
  echo
  echo "── Sweep done: ${SWEEP_PASSED} passed, ${SWEEP_FAILED} failed" \
       "($(( SWEEP_PASSED + SWEEP_FAILED )) devices run)."
  [[ "$SWEEP_FAILED" -eq 0 ]] || exit 1
fi
