#!/usr/bin/env bash
# Produce the Google Play foreground-service declaration videos: run the
# charging-session FGS demo test (integration_test/charging_session_fgs_demo_test.dart)
# on BrowserStack once per flavor, and print where each session video lives.
#
# Sequential by design: every run starts a real charge on the SAME staging
# connector, so two flavors can't record at once. Leave the charging simulator
# attached to TEST_EVSE_ID (auto-accepting remote starts) in a browser tab for
# the whole batch — each flavor takes roughly a build + a device run.
#
# Usage:
#   ./scripts/record_fgs_videos.sh              # all flavors
#   ./scripts/record_fgs_videos.sh friwigo ezdriveplus   # just these
#
# Required env vars:
#   BROWSERSTACK_USER, BROWSERSTACK_KEY   App Automate credentials.
#   TEST_EMAIL, TEST_PASSWORD             The dedicated recordings account
#                                         (saved Checkout test card, MFA
#                                         enrolment skipped).
# Optional:
#   TEST_EVSE_ID        Staging connector with the charging SIM attached
#                       (default 4185044).
#   E2E_PROVIDER_SLUG   Default e-flux: staging doesn't host most WL provider
#                       slugs, so all flavors log in via the E-Flux provider.
#   FGS_DEVICE          BrowserStack device string (default Google Pixel 8-14.0).
#
# Full per-flavor output lands in build/fgs_videos/<flavor>.log (testcase video
# URLs included); the end-of-batch summary lists pass/fail + dashboard URL per
# flavor. Download each video from the dashboard/URL and crop for submission.

set -uo pipefail

cd "$(dirname "$0")/.."

: "${BROWSERSTACK_USER:?error: set BROWSERSTACK_USER}"
: "${BROWSERSTACK_KEY:?error: set BROWSERSTACK_KEY}"
: "${TEST_EMAIL:?error: set TEST_EMAIL (dedicated recordings account)}"
: "${TEST_PASSWORD:?error: set TEST_PASSWORD}"

export TEST_EVSE_ID="${TEST_EVSE_ID:-4185044}"
export E2E_PROVIDER_SLUG="${E2E_PROVIDER_SLUG:-e-flux}"
DEVICE="${FGS_DEVICE:-Google Pixel 8-14.0}"

ALL_FLAVORS=(eflux elexon opcharge friwigo ezdrive nxt50five ezdriveplus)
if [[ $# -gt 0 ]]; then
  FLAVORS=("$@")
else
  FLAVORS=("${ALL_FLAVORS[@]}")
fi

LOG_DIR="build/fgs_videos"
mkdir -p "$LOG_DIR"

RESULTS=()
for flavor in "${FLAVORS[@]}"; do
  log_file="${LOG_DIR}/${flavor}.log"
  echo
  echo "════ ${flavor}: build + run on ${DEVICE} (log: ${log_file}) ════"
  if ./scripts/run_browserstack_android.sh \
      --flavor "$flavor" \
      --target integration_test/charging_session_fgs_demo_test.dart \
      --device "$DEVICE" \
      --wait 2>&1 | tee "$log_file"; then
    status="PASS"
  else
    status="FAIL"
  fi
  dashboard="$(grep -o 'https://app-automate.browserstack.com/dashboard[^[:space:]]*' "$log_file" | head -1)"
  RESULTS+=("${status}  ${flavor}  ${dashboard:-<no build URL — see log>}")
done

echo
echo "════ FGS video batch summary ════"
printf '%s\n' "${RESULTS[@]}"
echo
echo "Testcase video URLs are printed in each log (and on the dashboards):"
echo "  grep -B1 'https://' ${LOG_DIR}/<flavor>.log"
