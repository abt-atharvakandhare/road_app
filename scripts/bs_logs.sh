#!/usr/bin/env bash
# Fetch and print the logs for a BrowserStack App Automate Espresso session.
#
# The dashboard sometimes won't render test results (e.g. when the instrumentation
# exits abnormally), but the logs are still retrievable via the REST API. This
# pulls the session detail, lists every log URL it finds, and downloads the ones
# that look like logs (instrumentation/device/etc.) — the instrumentation log is
# where Dart stack traces (and our biometric native-tree dump) land.
#
# Usage:
#   ./scripts/bs_logs.sh <build_id> [session_id]
#   ./scripts/bs_logs.sh d9ec2494c1aa0b8afa3bcad0b25c31ac73ee2d94
#
# Env: BROWSERSTACK_USER, BROWSERSTACK_KEY
set -uo pipefail

BUILD="${1:?usage: bs_logs.sh <build_id> [session_id]}"
SID="${2:-}"
: "${BROWSERSTACK_USER:?set BROWSERSTACK_USER}"
: "${BROWSERSTACK_KEY:?set BROWSERSTACK_KEY}"
AUTH="$BROWSERSTACK_USER:$BROWSERSTACK_KEY"
BASE="https://api-cloud.browserstack.com/app-automate/espresso/v2"

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: $cmd not found." >&2; exit 1; }
done

if [[ -z "$SID" ]]; then
  SID="$(curl -sS -u "$AUTH" "$BASE/builds/$BUILD" | jq -r '.devices[]?.sessions[]?.id // empty' | head -1)"
  [[ -n "$SID" ]] || { echo "error: could not find a session id under build $BUILD" >&2; exit 1; }
fi
echo "build=$BUILD session=$SID"

DETAIL="$(curl -sS -u "$AUTH" "$BASE/builds/$BUILD/sessions/$SID")"

echo
echo "── status / reason ──"
echo "$DETAIL" | jq '{status, reason: (.reason // .error // "n/a")}' 2>/dev/null || echo "$DETAIL"

echo
echo "── all URLs in session detail ──"
mapfile_compat() { while IFS= read -r l; do [[ -n "$l" ]] && printf '%s\n' "$l"; done; }
URLS="$(echo "$DETAIL" | jq -r '.. | strings | select(test("^https?://"))' 2>/dev/null | sort -u)"
echo "$URLS"

echo
echo "── downloading log URLs (those whose link contains 'log') ──"
while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  case "$url" in
    *log*|*Log*|*LOG*)
      echo
      echo "════════════════════ $url ════════════════════"
      curl -sS -u "$AUTH" "$url"
      echo
      ;;
  esac
done <<< "$URLS"
