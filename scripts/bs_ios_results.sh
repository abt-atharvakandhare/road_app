#!/usr/bin/env bash
# Per-test PASS/FAIL summary for a BrowserStack iOS (XCUITest) build.
#
# WHY: Patrol on iOS runs the whole bundle as ONE XCUITest session, so the
# BrowserStack dashboard shows a single testcase and a single (long) video — not
# 42 separate results like Android/Espresso. But the iOS runner logs one line per
# Dart test, in execution order, with a timestamp:
#
#   runDartTest("<file> <description>"): call finished, test result: PASSED|FAILED
#
# (PatrolIntegrationTestIosRunner.h, the PATROL_INTEGRATION_TEST_IOS_RUNNER macro).
# This script pulls the session logs, greps those lines, and prints a numbered
# ✓/✗ list IN EXECUTION ORDER with an approximate video offset (the line's
# timestamp minus the "Running tests…" anchor ≈ when recording starts), so you
# know where in the video to scrub for any given test.
#
# Usage:
#   ./scripts/bs_ios_results.sh <build_id> [session_id]
#
# Env: BROWSERSTACK_USER, BROWSERSTACK_KEY
set -uo pipefail

BUILD="${1:?usage: bs_ios_results.sh <build_id> [session_id]}"
SID="${2:-}"
: "${BROWSERSTACK_USER:?error: set BROWSERSTACK_USER}"
: "${BROWSERSTACK_KEY:?error: set BROWSERSTACK_KEY}"
AUTH="$BROWSERSTACK_USER:$BROWSERSTACK_KEY"
BASE="https://api-cloud.browserstack.com/app-automate/xcuitest/v2"

for cmd in curl jq awk; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: $cmd not found." >&2; exit 1; }
done

if [[ -z "$SID" ]]; then
  SID="$(curl -sS -u "$AUTH" "$BASE/builds/$BUILD" \
    | jq -r '.devices[]?.sessions[]?.id // empty' | head -1)"
  [[ -n "$SID" ]] || { echo "error: no session under build $BUILD" >&2; exit 1; }
fi
echo "build=$BUILD session=$SID"

# Collect candidate log sources: every log-ish URL the session detail exposes
# (the runner's NSLog lands in the device log), plus a few known endpoints in
# case the detail omits them. awk dedupes by test name, so overlap is harmless.
DETAIL="$(curl -sS -u "$AUTH" "$BASE/builds/$BUILD/sessions/$SID")"
URLS="$(echo "$DETAIL" | jq -r '.. | strings | select(test("^https?://"))' 2>/dev/null \
  | grep -iE 'log' | sort -u)"

fetch_all() {
  local u
  for u in $URLS; do curl -sS -u "$AUTH" "$u"; echo; done
  local ep
  for ep in devicelogs deviceLogs logs sessionlogs instrumentationlogs testlogs; do
    curl -sS -u "$AUTH" "$BASE/builds/$BUILD/sessions/$SID/$ep" 2>/dev/null; echo
  done
}

# LC_ALL=C: some log endpoints return binary (result bundles); let awk treat
# bytes as bytes instead of aborting on an invalid multibyte sequence.
fetch_all | LC_ALL=C awk '
  BEGIN { anchor = -1 }
  function tosecs(line,   t) {
    if (match(line, /[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/)) {
      t = substr(line, RSTART, 8)
      return substr(t,1,2)*3600 + substr(t,4,2)*60 + substr(t,7,2)
    }
    return -1
  }
  { gsub(/\r/, "") }
  # Anchor offsets to when the device starts running tests (≈ video t=0).
  /Running tests\.\.\./ { if (anchor < 0) anchor = tosecs($0) }
  /runDartTest\(".*"\): call finished, test result: (PASSED|FAILED)/ {
    s = index($0, "runDartTest(\"") + 13          # len of: runDartTest("
    rest = substr($0, s)
    e = index(rest, "\"): call finished")
    if (e <= 1) next
    name = substr(rest, 1, e - 1)
    if (seen[name]++) next                          # first occurrence wins (preserves order)
    n++
    order[n] = name
    st[name] = ($0 ~ /result: PASSED/) ? "PASS" : "FAIL"
    sc[name] = tosecs($0)
  }
  END {
    if (n == 0) {
      print ""
      print "  no per-test result lines found in the session logs."
      print "  (the run may not have reached test execution, or the log endpoint"
      print "   changed — re-run with the raw logs via scripts/bs_logs-style fetch.)"
      exit 3
    }
    if (anchor < 0) anchor = sc[order[1]]           # fallback: first test
    pass = 0; fail = 0
    print ""
    printf "  %-3s %-7s %-3s %s\n", "#", "~video", "ok", "test"
    for (i = 1; i <= n; i++) {
      name = order[i]
      off = sc[name] - anchor
      if (off < 0) ts = "  ?  "
      else ts = sprintf("%02d:%02d", int(off/60), off%60)
      mark = (st[name] == "PASS") ? "OK " : "XX "
      printf "  %02d  %-7s %-3s %s\n", i, ts, mark, name
      if (st[name] == "PASS") pass++; else fail++
    }
    print ""
    printf "%d tests in execution order — %d passed, %d failed.\n", n, pass, fail
    if (fail > 0) {
      print "Failed (scrub to ~video offset, the test ENDS there):"
      for (i = 1; i <= n; i++) {
        name = order[i]
        if (st[name] == "FAIL") {
          off = sc[name] - anchor
          ts = (off < 0) ? "?" : sprintf("%02d:%02d", int(off/60), off%60)
          printf "  #%02d  ~%s  %s\n", i, ts, name
        }
      }
    }
  }
'
