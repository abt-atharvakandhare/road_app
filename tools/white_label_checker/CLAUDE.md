# White Label App Version Checker

## Purpose
This project monitors the version numbers and publication status of white label mobile apps created for road.io clients by an external agency (Andro Buddy Tech). The script checks both Apple App Store and Google Play Store for the latest app information.

## Project Structure

```
white_label_checker/
├── check_app_versions.py      # Main script — version checking, console/JSON output
├── ipa_inspector.py            # IPA download (ipatool), entitlements, provisioning, Info.plist inspection
├── white-label-apps.json       # Configuration file with all app details
├── requirements.txt            # Python dependencies
├── README.md                   # Human-facing setup and usage guide
└── CLAUDE.md                   # This documentation file
```

## Files

### `white-label-apps.json`
Contains the list of all white label apps with their store URLs and metadata. Structure:
```json
{
  "white_label_apps": [
    {
      "name": "App Name",
      "client": "Client Name",
      "maintainer": "Road|Andro Buddy",
      "status": "active|approved_for_publication|deprecated|unpublished|postponed|pending",
      "slack_thread": "timestamp or null",
      "apple_store_url": "URL or NOT_YET_PUBLISHED or null",
      "google_play_url": "URL or NOT_YET_PUBLISHED or null",
      "apple_bundle_id": "bundle ID or null",
      "android_package_name": "package name or null",
      "notes": "Additional information",
      "expected": {
        "team_id": "ABCDE12345",
        "seller_name": "Company B.V.",
        "bundle_id": "com.example.app",
        "min_ios_version": "15.0",
        "push_environment": "production",
        "apple_pay_merchants": ["merchant.com.example"],
        "associated_domains": ["applinks:example.com"],
        "app_groups": ["group.com.example.liveactivities"],
        "languages": ["EN", "NL"]
      }
    }
  ]
}
```
The `expected` block is optional. When present and `--entitlements` is used, the script compares observed values against expected and reports PASS/FAIL per field.

### `check_app_versions.py`
Main script that:
- Reads app configuration from `white-label-apps.json`
- Queries the iTunes Lookup API for Apple App Store metadata (version, seller, min iOS, languages)
- Scrapes Google Play Store pages for version and release date
- Optionally downloads IPAs and inspects entitlements, provisioning profiles, Info.plist, and privacy manifest
- Outputs results in a formatted table to console and/or JSON

### `ipa_inspector.py`
Handles IPA binary inspection:
- Downloads IPAs via `ipatool` with version-keyed caching
- Extracts and parses entitlements via `codesign` (Apple Pay, associated domains, app groups, push, Sign in with Apple, keychain groups, team ID)
- Decodes embedded provisioning profiles via `openssl` (team name, expiry, push environment)
- Reads Info.plist fields (bundle ID, version, min iOS, SDK, Live Activities, background modes, localizations)
- Checks for `PrivacyInfo.xcprivacy` presence (mandatory since May 2024)
- Reads signing certificate details (authority, team, signed time)

## How to Run

### Setup (first time only)
```bash
# Create a virtualenv and install Python dependencies
# (Homebrew Python is externally managed, so a venv is required;
# it also survives Homebrew Python version bumps)
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# For IPA inspection (optional)
brew install ipatool
ipatool auth login -e <apple-id-email>
```

All commands below use `.venv/bin/python` directly; alternatively run `source .venv/bin/activate` once and use plain `python3`.

### Basic version check
```bash
.venv/bin/python check_app_versions.py
```

### Filter to specific apps
```bash
.venv/bin/python check_app_versions.py --apps "Kia" "NXT"
```

### Full IPA inspection (entitlements, provisioning, privacy manifest)
```bash
.venv/bin/python check_app_versions.py --entitlements
```

### Export results as JSON
```bash
.venv/bin/python check_app_versions.py --json-out report.json
```

### All flags
| Flag | Description |
|------|-------------|
| `-v`, `--verbose` | Show URLs and download progress |
| `--details` | Show the "App Store details" block (bundle ID, seller, min iOS, languages) |
| `--entitlements` | Download IPAs via ipatool and inspect binaries |
| `--ipa-cache-dir PATH` | IPA cache location (default: `~/.cache/white-label-bot/ipas`) |
| `--json-out PATH` | Write full results as JSON |
| `--apps NAME [NAME ...]` | Filter to apps whose name contains a substring (case-insensitive) |

### Output
The script outputs a formatted table showing:
- App name
- Store (Apple/Google)
- Version number
- Release/update date
- Publication status (Published/Not Published/Error)
- Maintainer (Road for apps we build/release ourselves, Andro Buddy for agency-maintained apps)
- When `--details`: App Store details (bundle ID, seller, min iOS, languages)
- When `--entitlements`: entitlements, provisioning profile, privacy manifest, signing certificate, PASS/FAIL checks

## How to Update the App List

When new white label apps are created or existing ones are updated, you need to update `white-label-apps.json`.

### Finding New Apps

1. **Access Slack Channel**
   - Channel: `#ext-white-label-mobile-apps` (ID: `C0891RHM7EZ`)
   - This channel contains all conversations with the external development partner
   - Look for threads titled: "Client: [Name] WL App thread 🧵"

2. **Identify New Apps**
   - Check recent messages for new app announcements
   - Look for intake form mentions
   - Check for threads about apps in deployment

3. **Extract App Information**
   - Thread timestamp (for reference)
   - Client name
   - App status (pending/in_deployment/active/postponed)
   - Store URLs (if published)
   - Bundle IDs and package names (if available)

4. **Find Store URLs**
   - Search within Slack threads for App Store/Play Store links
   - If not in Slack, search the web using the app name + "EV charging" + "app store"
   - The apps are typically EV charging applications
   - Some apps may be branded under the EZdrive family

5. **Update the JSON File**
   - Add new app entries to `white_label_apps` array
   - Update existing entries if URLs or status changed
   - Update the `summary` section counts and `last_updated` date

### Example Search Queries for Finding Apps
```
"[Client Name] app" site:apps.apple.com
"[Client Name] charging" site:play.google.com
[Client Name] EV charging app store
```

## Known Apps (as of 2025-10-31)

### Published (3)
1. **V-City Reunion** - EV charging in Réunion (French territory)
2. **Kia Charge** - Kia's EV charging network app
3. **EZdrive - Service de recharge** - Mobile solar charging for EVs

### In Deployment (2)
4. **NXT Mobility** - Not yet published
5. **Comoly** - Not yet published

### Postponed (2)
6. **reGard** (Bouygues) - Project postponed
7. **Energu** - Postponed to Q1 2026

### Pending (1)
8. **MAES Energy & Mobility** - Waiting for contract signature

## Future Enhancements

### Planned Features
- [ ] Output to Confluence instead of console
- [ ] Format output as a Confluence table
- [ ] Add change detection (compare against previous runs)
- [ ] Automatic detection of newly published apps
- [ ] Email/Slack notifications when versions change
- [ ] Historical tracking of version changes

### Confluence Integration Notes
When implementing Confluence output:
- Use Confluence REST API
- Format as Confluence table markup
- Consider using Confluence Storage Format
- May need to store Confluence page ID in config
- Will need Confluence credentials/API token

## Troubleshooting

### Common Issues

**Script fails with "Configuration file not found"**
- Ensure `white-label-apps.json` exists in the same directory
- Check file permissions

**"No version found" for published apps**
- App store page structure may have changed
- Check if the URL is still valid
- May need to update the scraping logic in the script

**Rate limiting or blocked requests**
- App stores may block automated requests
- The script includes User-Agent headers to appear as a browser
- If blocked, wait a few minutes before retrying

**Import errors**
- Run `.venv/bin/pip install -r requirements.txt` to install dependencies (create the venv first with `python3 -m venv .venv` if it doesn't exist)
- Ensure you're using Python 3.7+

## Development Notes

- Apple App Store data comes from the iTunes Lookup API (free, unauthenticated, reliable)
- Google Play Store data comes from HTML scraping (fragile, may break if layout changes)
- IPA inspection requires `ipatool` (brew install) with an authenticated Apple ID session
- IPAs are cached by `{app_id}-{version}.ipa` to avoid re-downloading unchanged versions
- Error handling: script exits with error message on fatal errors, per-app errors are non-fatal

## Contact & Support

- Slack channel: `#ext-white-label-mobile-apps`
- For questions about specific apps, check their dedicated Slack threads
- CSM team members can provide app status updates
