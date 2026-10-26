#!/usr/bin/env bash
# Send a test FCM push to a device token via the FCM HTTP v1 API.
#
# Usage:
#   ./send_test_push.sh <fcm_token> [url] [title] [body]
#
# Examples:
#   ./send_test_push.sh "fxYz...token..." "https://www.e-flux.io/"
#   ./send_test_push.sh "fxYz...token..." "https://help.road.io/" "New article" "Tap to read"
#
# Auth:
#   Uses `gcloud auth application-default print-access-token`. Run
#   `gcloud auth application-default login` once with an account that has
#   FCM-send rights on the target Firebase project. Or set
#   GOOGLE_APPLICATION_CREDENTIALS to a service account key.
#
# Project:
#   Defaults to FIREBASE_PROJECT_ID if set, otherwise `eflux-mobile` (eflux flavor).
#   Override per-call: FIREBASE_PROJECT_ID=elexon-... ./send_test_push.sh ...
#
# Other flavors: see android/app/src/<flavor>/google-services.json for the
# matching project_id.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <fcm_token> [url] [title] [body]" >&2
  exit 1
fi

FCM_TOKEN="$1"
URL="${2:-https://www.e-flux.io/}"
TITLE="${3:-Test push}"
BODY="${4:-Tap to open the link}"
PROJECT_ID="${FIREBASE_PROJECT_ID:-eflux-mobile}"

for cmd in gcloud jq curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: $cmd not found." >&2
    exit 1
  fi
done

ACCESS_TOKEN="$(gcloud auth application-default print-access-token 2>/dev/null || true)"
if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "error: no access token. Run: gcloud auth application-default login" >&2
  exit 1
fi

# Build the JSON payload via jq so quotes/backslashes in the args can't break
# the body or be injected into adjacent fields.
PAYLOAD="$(jq -n \
  --arg token "$FCM_TOKEN" \
  --arg title "$TITLE" \
  --arg body "$BODY" \
  --arg url "$URL" \
  '{message: {token: $token, notification: {title: $title, body: $body}, data: {action: "open_url", url: $url}}}')"

echo "→ Project:  ${PROJECT_ID}"
echo "→ URL:      ${URL}"
echo "→ Token:    ${FCM_TOKEN:0:12}…${FCM_TOKEN: -6}"
echo

curl -sS -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  "https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send" \
  -d "${PAYLOAD}"
echo
