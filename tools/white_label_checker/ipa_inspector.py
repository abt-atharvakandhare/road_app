"""IPA download + inspection for white-label app deployment verification.

Downloads an app's IPA via ipatool, extracts key deployment-correctness signals:
entitlements, provisioning profile, Info.plist fields, and privacy manifest presence.
"""

import json
import plistlib
import re
import shutil
import subprocess
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional


ENTITLEMENT_KEYS = {
    "com.apple.developer.in-app-payments": "apple_pay_merchants",
    "com.apple.developer.associated-domains": "associated_domains",
    "com.apple.security.application-groups": "app_groups",
    "aps-environment": "push_environment",
    "com.apple.developer.applesignin": "sign_in_with_apple",
    "com.apple.developer.team-identifier": "team_id",
    "keychain-access-groups": "keychain_access_groups",
    "com.apple.developer.usernotifications.communication": "communication_notifications",
}

INFO_PLIST_KEYS_OF_INTEREST = [
    "CFBundleIdentifier",
    "CFBundleShortVersionString",
    "CFBundleVersion",
    "CFBundleDisplayName",
    "CFBundleName",
    "MinimumOSVersion",
    "ITSAppUsesNonExemptEncryption",
    "NSSupportsLiveActivities",
    "NSSupportsLiveActivitiesFrequentUpdates",
    "UIBackgroundModes",
    "CFBundleLocalizations",
    "DTPlatformVersion",
    "DTSDKName",
    "DTXcode",
    "UIDeviceFamily",
    "LSApplicationQueriesSchemes",
    "CFBundleURLTypes",
]


class IpaInspectionError(Exception):
    pass


class IpaInspector:
    def __init__(self, cache_dir: Path, verbose: bool = False):
        self.cache_dir = Path(cache_dir).expanduser()
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.verbose = verbose

    def inspect(self, numeric_app_id: str, expected_version: Optional[str] = None) -> Dict:
        """Download (or reuse cached) IPA and extract deployment signals.

        Returns a dict with keys: ipa_path, info_plist, entitlements, provisioning_profile,
        privacy_manifest, signing_certificate. On failure, returns {'status': 'error', 'error': ...}.
        """
        try:
            ipa_path = self._get_ipa(numeric_app_id, expected_version)
        except IpaInspectionError as e:
            return {"status": "error", "error": str(e)}

        with tempfile.TemporaryDirectory(prefix="ipa-inspect-") as tmp:
            try:
                app_path = self._extract_app(ipa_path, Path(tmp))
            except IpaInspectionError as e:
                return {"status": "error", "error": str(e), "ipa_path": str(ipa_path)}

            return {
                "status": "ok",
                "ipa_path": str(ipa_path),
                "info_plist": self._read_info_plist(app_path),
                "entitlements": self._read_entitlements(app_path),
                "provisioning_profile": self._read_provisioning_profile(app_path),
                "privacy_manifest": self._check_privacy_manifest(app_path),
                "signing_certificate": self._read_signing_cert(app_path),
            }

    def _get_ipa(self, numeric_app_id: str, expected_version: Optional[str]) -> Path:
        version_tag = expected_version or "latest"
        safe_tag = re.sub(r"[^\w.\-]", "_", version_tag)
        cached = self.cache_dir / f"{numeric_app_id}-{safe_tag}.ipa"

        if cached.exists() and cached.stat().st_size > 0:
            if self.verbose:
                print(f"    ↺ Using cached IPA: {cached.name}")
            return cached

        if self.verbose:
            print(f"    ↓ Downloading IPA for app id {numeric_app_id} (this can take a minute)…")

        cmd = [
            "ipatool", "download",
            "-i", numeric_app_id,
            "-o", str(cached),
            "--purchase",
            "--format", "json",
            "--non-interactive",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            cached.unlink(missing_ok=True)
            err = (result.stderr or result.stdout or "").strip()
            raise IpaInspectionError(f"ipatool download failed: {err[:500]}")

        if not cached.exists() or cached.stat().st_size == 0:
            raise IpaInspectionError(f"ipatool reported success but no IPA at {cached}")

        return cached

    def _extract_app(self, ipa_path: Path, work_dir: Path) -> Path:
        with zipfile.ZipFile(ipa_path) as z:
            z.extractall(work_dir)
        payload = work_dir / "Payload"
        if not payload.is_dir():
            raise IpaInspectionError("IPA missing Payload/ directory")
        apps = list(payload.glob("*.app"))
        if not apps:
            raise IpaInspectionError("No .app bundle inside Payload/")
        return apps[0]

    def _read_info_plist(self, app_path: Path) -> Dict:
        plist_path = app_path / "Info.plist"
        if not plist_path.exists():
            return {"status": "missing"}
        with plist_path.open("rb") as f:
            data = plistlib.load(f)
        return {k: self._plist_json_safe(data.get(k)) for k in INFO_PLIST_KEYS_OF_INTEREST if k in data}

    def _read_entitlements(self, app_path: Path) -> Dict:
        result = subprocess.run(
            ["codesign", "-d", "--entitlements", ":-", str(app_path)],
            capture_output=True,
        )
        if result.returncode != 0:
            return {"status": "error", "error": (result.stderr or b"").decode(errors="replace")[:500]}
        if not result.stdout:
            return {"status": "none"}
        try:
            parsed = plistlib.loads(result.stdout)
        except Exception as e:
            return {"status": "parse_error", "error": str(e)}

        normalized = {}
        for key, alias in ENTITLEMENT_KEYS.items():
            if key in parsed:
                normalized[alias] = self._plist_json_safe(parsed[key])

        unknown = {k: self._plist_json_safe(v) for k, v in parsed.items() if k not in ENTITLEMENT_KEYS}
        return {"status": "ok", "normalized": normalized, "other": unknown}

    def _read_provisioning_profile(self, app_path: Path) -> Dict:
        profile = app_path / "embedded.mobileprovision"
        if not profile.exists():
            return {"status": "missing"}
        result = subprocess.run(
            ["openssl", "smime", "-verify", "-inform", "der", "-noverify", "-in", str(profile)],
            capture_output=True,
        )
        if result.returncode != 0:
            return {"status": "error", "error": (result.stderr or b"").decode(errors="replace")[:500]}
        try:
            parsed = plistlib.loads(result.stdout)
        except Exception as e:
            return {"status": "parse_error", "error": str(e)}

        expiry = parsed.get("ExpirationDate")
        days_until_expiry = None
        if isinstance(expiry, datetime):
            delta = expiry.replace(tzinfo=timezone.utc) - datetime.now(timezone.utc)
            days_until_expiry = delta.days

        profile_ents = parsed.get("Entitlements") or {}

        return {
            "status": "ok",
            "team_identifier": parsed.get("TeamIdentifier"),
            "team_name": parsed.get("TeamName"),
            "app_id_name": parsed.get("AppIDName"),
            "application_identifier": profile_ents.get("application-identifier"),
            "expiration_date": expiry.isoformat() if isinstance(expiry, datetime) else None,
            "days_until_expiry": days_until_expiry,
            "uuid": parsed.get("UUID"),
            "push_environment": profile_ents.get("aps-environment"),
        }

    def _check_privacy_manifest(self, app_path: Path) -> Dict:
        candidates = [
            app_path / "PrivacyInfo.xcprivacy",
            app_path / "Contents/Resources/PrivacyInfo.xcprivacy",
        ]
        for c in candidates:
            if c.exists():
                return {"present": True, "path": c.name}
        return {"present": False}

    def _read_signing_cert(self, app_path: Path) -> Dict:
        result = subprocess.run(
            ["codesign", "-dvv", str(app_path)],
            capture_output=True,
            text=True,
        )
        output = (result.stderr or "") + (result.stdout or "")
        if result.returncode != 0:
            return {"status": "error", "error": output[:500]}

        def grab(pattern: str) -> Optional[str]:
            m = re.search(pattern, output)
            return m.group(1).strip() if m else None

        return {
            "status": "ok",
            "authority": grab(r"Authority=([^\n]+)"),
            "team_identifier": grab(r"TeamIdentifier=([^\n]+)"),
            "identifier": grab(r"Identifier=([^\n]+)"),
            "signed_time": grab(r"Signed Time=([^\n]+)"),
        }

    @staticmethod
    def _plist_json_safe(value):
        """Convert plist values to JSON-serializable forms (datetimes -> iso strings)."""
        if isinstance(value, datetime):
            return value.isoformat()
        if isinstance(value, dict):
            return {k: IpaInspector._plist_json_safe(v) for k, v in value.items()}
        if isinstance(value, list):
            return [IpaInspector._plist_json_safe(v) for v in value]
        if isinstance(value, bytes):
            try:
                return value.decode("utf-8")
            except UnicodeDecodeError:
                return value.hex()
        return value


def extract_numeric_app_id(bundle_id_field: Optional[str], store_url: Optional[str]) -> Optional[str]:
    """Derive numeric App Store id from either the 'id1234' field or the store URL."""
    for candidate in (bundle_id_field, store_url):
        if not candidate:
            continue
        m = re.search(r"id(\d{6,})", candidate)
        if m:
            return m.group(1)
    return None


def itunes_lookup(numeric_app_id: str, country: str, session) -> Dict:
    """Query the free iTunes Lookup API for store metadata.

    Returns {status: 'ok', data: {...}} or {status: 'error', error: ...}.
    """
    url = f"https://itunes.apple.com/lookup?id={numeric_app_id}&country={country}"
    try:
        response = session.get(url, timeout=10)
        response.raise_for_status()
        body = response.json()
    except Exception as e:
        return {"status": "error", "error": str(e)}

    if body.get("resultCount", 0) == 0:
        return {"status": "not_found", "country": country}

    r = body["results"][0]
    fields = [
        "bundleId", "version", "trackName", "trackCensoredName", "sellerName",
        "artistName", "sellerUrl", "minimumOsVersion", "fileSizeBytes",
        "currentVersionReleaseDate", "releaseDate", "trackContentRating",
        "contentAdvisoryRating", "primaryGenreName", "genres",
        "languageCodesISO2A", "price", "currency", "formattedPrice",
        "averageUserRating", "userRatingCount", "features",
        "artworkUrl512", "releaseNotes", "supportedDevices",
    ]
    return {"status": "ok", "country": country, "data": {k: r.get(k) for k in fields}}


def country_from_store_url(url: Optional[str], default: str = "us") -> str:
    """Extract country code from an apps.apple.com URL like /us/app/... or /nl/app/..."""
    if not url:
        return default
    m = re.search(r"apps\.apple\.com/([a-z]{2})/", url)
    return m.group(1) if m else default


def run_expected_checks(expected: Dict, info_plist: Dict, entitlements: Dict,
                        provisioning: Dict, lookup: Dict) -> List[Dict]:
    """Compare expected values against observed. Returns list of check dicts."""
    checks = []
    ents = (entitlements or {}).get("normalized", {}) if entitlements else {}
    lookup_data = (lookup or {}).get("data", {}) if lookup else {}

    scalar_map = {
        "team_id": ("Team ID", provisioning.get("team_identifier") if provisioning else None),
        "seller_name": ("Seller Name", lookup_data.get("sellerName")),
        "bundle_id": ("Bundle ID", info_plist.get("CFBundleIdentifier")),
        "min_ios_version": ("Minimum iOS", info_plist.get("MinimumOSVersion")),
        "push_environment": ("Push Env", ents.get("push_environment") or (provisioning or {}).get("push_environment")),
    }
    for key, (label, actual) in scalar_map.items():
        if key not in expected:
            continue
        exp = expected[key]
        checks.append({
            "field": label,
            "expected": exp,
            "actual": actual,
            "status": "PASS" if actual == exp else "FAIL",
        })

    list_map = {
        "apple_pay_merchants": ("Apple Pay Merchants", ents.get("apple_pay_merchants") or []),
        "associated_domains": ("Associated Domains", ents.get("associated_domains") or []),
        "app_groups": ("App Groups", ents.get("app_groups") or []),
        "languages": ("Languages", lookup_data.get("languageCodesISO2A") or []),
    }
    for key, (label, actual_list) in list_map.items():
        if key not in expected:
            continue
        expected_list = expected[key]
        actual_set = set(actual_list)
        missing = [v for v in expected_list if v not in actual_set]
        checks.append({
            "field": label,
            "expected": expected_list,
            "actual": actual_list,
            "status": "PASS" if not missing else "FAIL",
            "missing": missing,
        })

    return checks
