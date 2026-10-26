# Integration tests — background & setup

Setup, fork rationale, and caveats for the Patrol e2e suite. The run commands
live in [README.md](README.md).

## Why we're on a fork

The published `patrol` package (4.5–4.6) crashes on Android in this project
with `MobileAutomatorServerKt:53 NullPointerException`, triggered by Kotlin
2.x dependencies (this app is on Kotlin 2.3.20 via the Compose plugin).
Upstream tracking: [#2731][p2731]. The fix lives in upstream PR [#2791][p2791]
which bumps `http4k`; that PR has been open ~6 months and has two minor bugs
that block it being used directly. We carry both as patches in
[`e-flux-platform/patrol`][fork], branch
`experiment/http-proxy+road-mobile-fixes`, along with an iOS fix of our own:
stock patrol silently reported iOS tests as PASSED in ~150ms without running
the test body — the fork patches that, which is what makes the iOS path work.
The Android fix is upstreamable; we revert to a pub.dev version once #2791
lands (and keep the iOS patch on any rebase — don't blindly `patrol update`).

[p2731]: https://github.com/leancodepl/patrol/issues/2731
[p2791]: https://github.com/leancodepl/patrol/pull/2791
[fork]: https://github.com/e-flux-platform/patrol

## One-time setup

### 1. Install the CLI from the fork

```sh
dart pub global activate \
  --source=git https://github.com/e-flux-platform/patrol.git \
  --git-ref=608a8b2e3a2311b0dc08a8e8dbcf239b3eea9ee0 \
  --git-path=packages/patrol_cli

patrol doctor
```

`patrol doctor` should be green for Android. Ensure `ANDROID_HOME` is set and
`$ANDROID_HOME/platform-tools` is on `PATH` (see `~/.bash_profile`). The
"Update available!" banner on each invocation is harmless — pub.dev's latest
is newer than our fork SHA by design.

### 2. Android — already done

Committed to the repo, applies to all flavors:

- [`android/app/build.gradle`](../android/app/build.gradle) — Patrol JUnit
  runner (the BrowserStack-aware variant; falls back to local-loopback so it
  works both ways), `clearPackageData: "false"` (app data survives between
  tests so a device run can reuse one logged-in session — per-test isolation
  is `resetAppState()` in the test helpers, same as iOS; a password login per
  test trips the API's per-account login throttle. NOTE: `resetAppState()`
  only wipes FlutterSecureStorage and SharedPreferences — state persisted
  anywhere else (Hive boxes, SQLite, arbitrary files, biometric_storage)
  silently survives between tests, so a future feature that persists there
  needs a corresponding wipe added to `resetAppState()`), Test Orchestrator,
  `androidTestUtil`
  dep, `minSdkVersion 26` (required by the fork's `http4k`), and a
  `packagingOptions` block to strip duplicate META-INF entries from the new
  http4k.
- [`android/app/src/androidTest/java/com/eflux/ev/MainActivityTest.java`](../android/app/src/androidTest/java/com/eflux/ev/MainActivityTest.java)
  — the parameterised JUnit harness that hosts every Dart test as one Android
  test case.

If a new flavor with a different `namespace` is added (currently all flavors
share `com.eflux.ev`), update the `MainActivityTest.java` package path.

### 3. iOS — already done

Works end-to-end (locally on a real device and on BrowserStack) on the fork —
see the fork section above for the silent-pass bug it patches. The committed
infrastructure:

- `ios/RunnerUITests/` — the UI Testing Bundle target sources.
- `ios/Runner.xcodeproj/project.pbxproj` — RunnerUITests target with 24 build
  configurations (7 flavors × Debug/Profile/Release + 3 defaults).
- `ios/Podfile` — `inherit! :complete` on the RunnerUITests target.
- `ios/scripts/add_patrol_uitest_target.rb`,
  `ios/scripts/add_flutter_embed_phase.rb`,
  `ios/scripts/wire_test_action_to_schemes.rb` — idempotent Xcode-project
  manipulators that produced the committed `project.pbxproj` above.

  **Do not run these in normal development.** The pbxproj is committed,
  so `flutter clean` / `flutter pub get` / `flutter run` will not touch
  it. Only re-run them if something blows the project file away —
  typically a `dart run flutter_flavorizr ...` invocation (see the root
  CLAUDE.md), or a fresh `flutter create .` over the existing tree.
  Per-flavor Apple Developer team IDs and bundle IDs are baked into the
  scripts.

## How the BrowserStack flow works

Wrapper scripts:
[`scripts/run_browserstack_android.sh`](../scripts/run_browserstack_android.sh)
and [`scripts/run_browserstack_ios.sh`](../scripts/run_browserstack_ios.sh).
Each builds the test artefacts, uploads them, and triggers the run (commands
in [README.md](README.md)).

**Android** is three calls to App Automate's Espresso v2 API: `POST /app` for
the app APK, `POST /test-suite` for the androidTest APK, then `POST /build`
with both URLs and the device list. `patrol build android` produces both APKs
in debug (BrowserStack Espresso is happy with debug-signed APKs):
`build/app/outputs/apk/<flavor>/debug/` and
`build/app/outputs/apk/androidTest/<flavor>/debug/`.

**iOS** uses the XCUITest xctestrun endpoint. `patrol build ios --release`
builds unsigned; BrowserStack resigns the uploaded .ipa with its own
certificate, so no provisioning profile or device registration is needed. The
script packages the Runner.app as an .ipa, rewrites the TestPlan xctestrun
(BS rejects `DiagnosticCollectionPolicy`; paths are flattened to the zip
root), and uploads both. One constraint: the built bundle only runs on
devices whose iOS major matches the Xcode SDK that built it — a runner built
with a newer Xcode strong-links XCTest symbols older devices lack and aborts
at launch.

**Biometrics**: `enableBiometric: "true"` makes BrowserStack intercept the OS
biometric prompt and present a controllable pop-up with **Pass / Fail /
Cancel** buttons that the tests tap via Patrol's native finder. **Requires
Device Cloud Pro tier or higher.** No effect on tests that don't trigger
biometrics, so it's on by default. Apps with ProGuard/R8 obfuscation aren't
supported by this feature — our builds don't enable `minifyEnabled`, so we're
fine.

The trigger response includes a `build_id`; track it in the App Automate
dashboard, poll the builds API, or just pass `--wait`.

## Caveats

- **The login flow hits the real API.** Use a dedicated staging account so
  you don't trip rate limits, and so failed sessions don't pollute prod
  analytics. The account may have MFA enabled, as long as its factor is an
  authenticator app: pass its base32 secret as `TEST_TOTP_SECRET` and
  `loginAsStagingUser` answers the challenge (method picker → App
  Authentication → computed RFC 6238 code, `_helpers/totp.dart`). SMS and
  email factors cannot be answered unattended and fail the login fast.
- **Credentials are baked into the test artefacts.** `--dart-define=TEST_EMAIL=…`,
  `--dart-define=TEST_PASSWORD=…` (and `TEST_TOTP_SECRET`, which is worth as
  much as the password) are compiled in at build time, so
  anyone with the test APK/IPA can extract them with `strings` / `apktool`.
  The threat model we accept is:
    1. The BrowserStack workspace is private — only the team can pull
       artefacts.
    2. The credentials belong to a throwaway staging account, never a real
       user's, so a leak is recoverable without prod impact.
    3. The test artefacts are never pushed to a public store (Play Store,
       Firebase distribution, public CI artefacts, etc.).
  If any of those change, swap to a runtime credential mechanism (e.g.
  fetching from a per-run secret store) before the next build.
- **Localisation:** tests match English strings ("Login", "Account",
  "Notifications", …). If a flavor or device locale flips to another
  language, add stable `Key`s or `Semantics(identifier: ...)` to the target
  widgets instead.
- **Other flavors:** update `--flavor`, and re-run the build per flavor. The
  bundle IDs in `pubspec.yaml`'s `patrol:` block are eflux defaults; the CLI
  reads the real IDs from each flavor's build config when you pass
  `--flavor`.
- **minSdk bumped to 26.** Required by the fork's http4k version. Drops
  support for Android 5.0–7.x. If product cares, we need to revisit (perhaps
  by finding an http4k version that works at the older floor).
- **BrowserStack Android builds are debug** (assertions live, slower) while
  iOS local/BS runs are release — debug-only asserts and async races can fail
  on BS Android but not on an iPhone. Triage those first.
