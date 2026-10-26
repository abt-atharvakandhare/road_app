#!/usr/bin/env python3
"""
White Label App Version Checker
Checks the latest version and publication date of all white label apps from app stores.
"""

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional
import requests

from ipa_inspector import (
    IpaInspector,
    country_from_store_url,
    extract_numeric_app_id,
    itunes_lookup,
    run_expected_checks,
)


class AppStoreChecker:
    """Handles checking app information from Apple App Store and Google Play Store."""

    def __init__(self, verbose=False):
        self.verbose = verbose
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        })

    def check_apple_app(self, url: str, bundle_id_field: Optional[str], app_name: str) -> Dict:
        """Fetch app information from Apple via the iTunes Lookup API.

        Returns a unified dict shaped like the Google Play result, plus a `lookup`
        field carrying the full lookup payload for downstream use.
        """
        if url in [None, "NEEDS_MANUAL_REVIEW", "NOT_YET_PUBLISHED"]:
            return {"status": "not_published", "store": "Apple App Store"}

        numeric_id = extract_numeric_app_id(bundle_id_field, url)
        if not numeric_id:
            return {
                "status": "error",
                "store": "Apple App Store",
                "error": "Could not derive numeric App Store id from config",
                "url": url,
            }

        country = country_from_store_url(url)
        if self.verbose:
            print(f"  → iTunes Lookup: id={numeric_id} country={country}")

        lookup = itunes_lookup(numeric_id, country, self.session)
        if lookup.get("status") != "ok":
            return {
                "status": "error",
                "store": "Apple App Store",
                "error": lookup.get("error") or lookup.get("status"),
                "url": url,
                "lookup": lookup,
            }

        d = lookup["data"]
        release_date = d.get("currentVersionReleaseDate")
        if release_date and "T" in release_date:
            release_date = release_date.split("T")[0]

        return {
            "status": "published",
            "store": "Apple App Store",
            "version": d.get("version"),
            "release_date": release_date,
            "developer": d.get("sellerName"),
            "url": url,
            "lookup": lookup,
        }

    def check_google_play_app(self, url: str, app_name: str) -> Dict:
        """
        Fetch app information from Google Play Store.

        Args:
            url: Google Play Store URL
            app_name: Name of the app

        Returns:
            Dictionary containing version, release date, rating, etc.
        """
        if url in [None, "NEEDS_MANUAL_REVIEW", "NOT_YET_PUBLISHED"]:
            return {"status": "not_published", "store": "Google Play Store"}

        try:
            if self.verbose:
                print(f"  → Fetching Google Play Store: {url}")
            response = self.session.get(url, timeout=10)
            response.raise_for_status()

            html_content = response.text

            # Extract version number from JSON array pattern like ["1.0.1"]
            version = None
            version_match = re.search(r'\["(\d+\.\d+\.?\d*)"\]', html_content)
            if version_match:
                version = version_match.group(1)

            # Extract last updated date - Google Play uses format like "Jun 13, 2025"
            release_date = None
            date_match = re.search(r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},\s+20\d{2}', html_content)
            if date_match:
                # Convert to YYYY-MM-DD format for consistency
                date_str = date_match.group(0)
                try:
                    parsed_date = datetime.strptime(date_str, '%b %d, %Y')
                    release_date = parsed_date.strftime('%Y-%m-%d')
                except ValueError:
                    release_date = date_str

            return {
                "status": "published",
                "store": "Google Play Store",
                "version": version,
                "release_date": release_date,
                "url": url
            }

        except Exception as e:
            return {
                "status": "error",
                "store": "Google Play Store",
                "error": str(e),
                "url": url
            }


def load_apps_config(config_path: str = 'white-label-apps.json') -> Dict:
    """Load the white label apps configuration from JSON file."""
    try:
        with open(config_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: Configuration file '{config_path}' not found.")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in configuration file: {e}")
        sys.exit(1)


def format_inspection_block(app: Dict, show_details: bool = False) -> Optional[str]:
    """Render the iTunes Lookup + IPA inspection details for an app as a string block.
    Returns None if no inspection was performed."""
    apple = app.get("apple_data", {})
    lookup = apple.get("lookup")
    inspection = apple.get("inspection")
    checks = apple.get("checks")

    if not lookup and not inspection and not checks:
        return None

    lines = []

    if show_details and lookup and lookup.get("status") == "ok":
        d = lookup["data"]
        lines.append("  App Store details:")
        lines.append(f"    Bundle ID:        {d.get('bundleId')}")
        lines.append(f"    Seller:           {d.get('sellerName')}")
        lines.append(f"    Min iOS:          {d.get('minimumOsVersion')}")
        lines.append(f"    Languages:        {', '.join(d.get('languageCodesISO2A') or [])}")
        if d.get("sellerUrl"):
            lines.append(f"    Seller URL:       {d.get('sellerUrl')}")

    if inspection:
        if inspection.get("status") != "ok":
            lines.append(f"  IPA Inspection:    [{inspection.get('status')}] {inspection.get('error', '')}")
        else:
            info = inspection.get("info_plist", {}) or {}
            ents = (inspection.get("entitlements") or {}).get("normalized", {})
            prov = inspection.get("provisioning_profile") or {}
            privacy = inspection.get("privacy_manifest") or {}
            cert = inspection.get("signing_certificate") or {}

            lines.append("  Binary (Info.plist):")
            lines.append(f"    Bundle ID:        {info.get('CFBundleIdentifier')}")
            lines.append(f"    Version:          {info.get('CFBundleShortVersionString')} ({info.get('CFBundleVersion')})")
            lines.append(f"    Min iOS:          {info.get('MinimumOSVersion')}")
            lines.append(f"    Built w/ SDK:     {info.get('DTSDKName')} (Xcode {info.get('DTXcode')})")
            if "NSSupportsLiveActivities" in info:
                lines.append(f"    Live Activities:  {info.get('NSSupportsLiveActivities')}"
                             f" (frequent updates: {info.get('NSSupportsLiveActivitiesFrequentUpdates')})")
            if "UIBackgroundModes" in info:
                lines.append(f"    Background modes: {', '.join(info.get('UIBackgroundModes') or [])}")
            if "CFBundleLocalizations" in info:
                lines.append(f"    Localizations:    {', '.join(info.get('CFBundleLocalizations') or [])}")

            lines.append("  Entitlements:")
            lines.append(f"    Team ID:          {ents.get('team_id') or prov.get('team_identifier')}")
            lines.append(f"    Push Env:         {ents.get('push_environment') or prov.get('push_environment')}")
            lines.append(f"    Apple Pay:        {', '.join(ents.get('apple_pay_merchants') or []) or '—'}")
            lines.append(f"    Associated Dom.:  {', '.join(ents.get('associated_domains') or []) or '—'}")
            lines.append(f"    App Groups:       {', '.join(ents.get('app_groups') or []) or '—'}")
            lines.append(f"    Sign in w/ Apple: {ents.get('sign_in_with_apple') or '—'}")
            lines.append(f"    Keychain Groups:  {', '.join(ents.get('keychain_access_groups') or []) or '—'}")

            lines.append("  Provisioning Profile:")
            lines.append(f"    Team:             {prov.get('team_name')} ({prov.get('team_identifier')})")
            lines.append(f"    App ID:           {prov.get('application_identifier')}")
            expiry_str = prov.get("expiration_date") or "?"
            days = prov.get("days_until_expiry")
            expiry_warning = ""
            if isinstance(days, int):
                if days < 30:
                    expiry_warning = f"  ⚠ expires in {days} days"
                elif days < 90:
                    expiry_warning = f"  ({days} days)"
            lines.append(f"    Expires:          {expiry_str}{expiry_warning}")

            lines.append(f"  Privacy Manifest:   {'present' if privacy.get('present') else '⚠ MISSING'}")

            if cert.get("status") == "ok":
                lines.append(f"  Signing Authority:  {cert.get('authority')}")

    if checks:
        lines.append("  Expected vs. Observed:")
        for chk in checks:
            status = chk["status"]
            marker = "✓" if status == "PASS" else "✗"
            actual = chk["actual"]
            if isinstance(actual, list):
                actual = ", ".join(str(x) for x in actual) or "—"
            lines.append(f"    [{marker}] {chk['field']:<22} expected={chk['expected']}  actual={actual}")
            if status == "FAIL" and chk.get("missing"):
                lines.append(f"        missing: {', '.join(str(x) for x in chk['missing'])}")

    return "\n".join(lines) if lines else None


def format_console_output(apps_data: list, show_details: bool = False):
    """Format the output as a table for console display."""

    print("\n" + "="*120)
    print("WHITE LABEL APPS - VERSION CHECK REPORT")
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*120 + "\n")

    # Header
    print(f"{'App Name':<30} {'Store':<20} {'Version':<15} {'Release Date':<20} {'Status':<15} {'Maintainer':<15}")
    print("-"*120)

    for app in apps_data:
        app_name = app['name'][:28]
        maintainer = app.get('maintainer') or 'Unknown'

        # Apple App Store row
        apple = app['apple_data']
        if apple['status'] == 'not_published':
            print(f"{app_name:<30} {'Apple App Store':<20} {'N/A':<15} {'N/A':<20} {'Not Published':<15} {maintainer:<15}")
        elif apple['status'] == 'error':
            print(f"{app_name:<30} {'Apple App Store':<20} {'ERROR':<15} {'N/A':<20} {'Error':<15} {maintainer:<15}")
            print(f"  └─ Error: {apple.get('error', 'Unknown error')}")
        else:
            version = apple.get('version') or 'N/A'
            release_date = apple.get('release_date') or 'N/A'
            print(f"{app_name:<30} {'Apple App Store':<20} {version:<15} {release_date:<20} {'Published':<15} {maintainer:<15}")

        # Google Play Store row
        google = app['google_data']
        if google['status'] == 'not_published':
            print(f"{'':<30} {'Google Play Store':<20} {'N/A':<15} {'N/A':<20} {'Not Published':<15}")
        elif google['status'] == 'error':
            print(f"{'':<30} {'Google Play Store':<20} {'ERROR':<15} {'N/A':<20} {'Error':<15}")
            print(f"  └─ Error: {google.get('error', 'Unknown error')}")
        else:
            version = google.get('version') or 'N/A'
            release_date = google.get('release_date') or 'N/A'
            print(f"{'':<30} {'Google Play Store':<20} {version:<15} {release_date:<20} {'Published':<15}")

        inspection_block = format_inspection_block(app, show_details)
        if inspection_block:
            print(inspection_block)

        print()  # Empty line between apps

    print("="*120)
    print()


def main():
    """Main function to check all white label apps."""

    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='Check version and publication info for white label apps'
    )
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Show URLs being accessed')
    parser.add_argument('--details', action='store_true',
                        help='Show the "App Store details" block (bundle ID, seller, '
                             'min iOS, languages) under each app')
    parser.add_argument('--entitlements', action='store_true',
                        help='Download IPAs via ipatool and inspect entitlements, '
                             'provisioning profiles, Info.plist, and privacy manifest. '
                             'Requires ipatool to be installed and authenticated.')
    parser.add_argument('--ipa-cache-dir', default='~/.cache/white-label-bot/ipas',
                        help='Where to cache downloaded IPAs (default: ~/.cache/white-label-bot/ipas)')
    parser.add_argument('--json-out', metavar='PATH',
                        help='Write full results as JSON to PATH')
    parser.add_argument('--apps', metavar='NAME', nargs='+',
                        help='Only check apps whose name contains one of these substrings (case-insensitive)')
    args = parser.parse_args()

    # Load configuration
    config = load_apps_config()
    apps = config.get('white_label_apps', [])

    if args.apps:
        needles = [n.lower() for n in args.apps]
        apps = [a for a in apps if any(n in a['name'].lower() for n in needles)]

    if not apps:
        print("No apps found in configuration file.")
        sys.exit(0)

    print(f"Checking {len(apps)} white label apps...")

    checker = AppStoreChecker(verbose=args.verbose)
    inspector = IpaInspector(Path(args.ipa_cache_dir), verbose=args.verbose) if args.entitlements else None
    results = []

    for app in apps:
        app_name = app['name']
        print(f"Checking: {app_name}...")

        apple_url = app.get('apple_store_url')
        apple_data = checker.check_apple_app(apple_url, app.get('apple_bundle_id'), app_name)

        google_url = app.get('google_play_url')
        google_data = checker.check_google_play_app(google_url, app_name)

        if inspector and apple_data.get('status') == 'published':
            numeric_id = extract_numeric_app_id(app.get('apple_bundle_id'), apple_url)
            if numeric_id:
                apple_data['inspection'] = inspector.inspect(numeric_id, apple_data.get('version'))

                expected = app.get('expected')
                if expected and apple_data['inspection'].get('status') == 'ok':
                    apple_data['checks'] = run_expected_checks(
                        expected,
                        apple_data['inspection'].get('info_plist', {}),
                        apple_data['inspection'].get('entitlements', {}),
                        apple_data['inspection'].get('provisioning_profile', {}),
                        apple_data.get('lookup'),
                    )

        results.append({
            'name': app_name,
            'client': app.get('client'),
            'maintainer': app.get('maintainer'),
            'status': app.get('status'),
            'apple_data': apple_data,
            'google_data': google_data
        })

    format_console_output(results, show_details=args.details)

    if args.json_out:
        out_path = Path(args.json_out).expanduser()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with out_path.open('w') as f:
            json.dump({
                'generated_at': datetime.now().isoformat(),
                'apps': results,
            }, f, indent=2, default=str)
        print(f"\n✓ JSON written to {out_path}")

    print("\n✓ Check complete!")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nScript interrupted by user.")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nFATAL ERROR: {str(e)}")
        sys.exit(1)
