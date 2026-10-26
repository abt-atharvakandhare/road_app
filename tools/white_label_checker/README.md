# White Label App Version Checker

Monitors the version numbers and publication status of the white label mobile apps built for road.io clients by the external agency (Andro Buddy Tech). Checks both the Apple App Store (iTunes Lookup API) and Google Play Store (page scraping), and can optionally download IPAs to inspect entitlements, provisioning profiles, and privacy manifests.

## Setup (first time only)

```bash
# Create a virtualenv and install dependencies
# (Homebrew Python is externally managed, so a venv is required)
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

For IPA inspection (optional):

```bash
brew install ipatool
ipatool auth login -e <apple-id-email>
```

## Usage

```bash
# Basic version check across all apps
.venv/bin/python check_app_versions.py

# Filter to specific apps (substring match, case-insensitive)
.venv/bin/python check_app_versions.py --apps "Kia" "NXT"

# Full IPA inspection: entitlements, provisioning, privacy manifest
.venv/bin/python check_app_versions.py --entitlements

# Export results as JSON
.venv/bin/python check_app_versions.py --json-out report.json
```

Alternatively, `source .venv/bin/activate` once and use plain `python3`.

### Flags

| Flag | Description |
|------|-------------|
| `-v`, `--verbose` | Show URLs and download progress |
| `--details` | Show the "App Store details" block (bundle ID, seller, min iOS, languages) |
| `--entitlements` | Download IPAs via ipatool and inspect binaries |
| `--ipa-cache-dir PATH` | IPA cache location (default: `~/.cache/white-label-bot/ipas`) |
| `--json-out PATH` | Write full results as JSON |
| `--apps NAME [NAME ...]` | Filter to apps whose name contains a substring |

## Files

| File | Purpose |
|------|---------|
| `check_app_versions.py` | Main script — version checking, console/JSON output |
| `ipa_inspector.py` | IPA download (ipatool), entitlements, provisioning, Info.plist inspection |
| `white-label-apps.json` | Configuration file with all app details, including optional `expected` blocks for PASS/FAIL checks |
| `requirements.txt` | Python dependencies |
| `CLAUDE.md` | Extended documentation: config schema, updating the app list, troubleshooting |

## Updating the app list

App details live in `white-label-apps.json`. New apps are announced in the `#ext-white-label-mobile-apps` Slack channel. See [CLAUDE.md](CLAUDE.md) for the config schema and the full process for finding and adding new apps.

## Troubleshooting

- **`ModuleNotFoundError: No module named 'requests'`** — dependencies aren't installed for the Python you're running. Use the venv as shown above. Note that Homebrew Python upgrades wipe previously installed packages; the venv avoids this.
- **"No version found" for published apps** — the Play Store page structure may have changed (Google Play data comes from HTML scraping, which is fragile).
- **Rate limiting** — stores may block automated requests; wait a few minutes and retry.

More detail in [CLAUDE.md](CLAUDE.md#troubleshooting).
