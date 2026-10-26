import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';

import '_helpers/app_launch.dart';
import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Locale resolution: boot the app under each supported device language and
// assert it resolves + renders that language; boot under two UNsupported
// languages and assert the EN fallback engages.
//
// ──────────────────────────────────────────────────────────────────────────────
// HOW THE DEVICE LOCALE IS FAKED (no device-language change needed)
// ──────────────────────────────────────────────────────────────────────────────
// Patrol's binding descends from TestWidgetsFlutterBinding, whose
// `platformDispatcher` is a TestPlatformDispatcher wrapping the real one.
// Setting `localesTestValue` BEFORE `app.main()` makes MaterialApp see that
// list as the device's preferred languages, exactly as if the OS were set to
// it — so each case runs in a stock (English) BrowserStack device. The app has
// no in-app language setting and no `locale:` override on MaterialApp; it
// follows the (faked) system locale through the standard resolution against
// AppLocalizations.supportedLocales, which falls back to EN (the list's first
// entry) for unsupported languages.
//
// ──────────────────────────────────────────────────────────────────────────────
// ASSERTION STRATEGY
// ──────────────────────────────────────────────────────────────────────────────
// 1. Localizations.localeOf(context) == the expected resolved locale (this is
//    what proves pl/ja fall back to en).
// 2. AppLocalizations.of(context).localeName matches it (the delegate really
//    loaded that language's instance, not just resolved the Locale).
// 3. A visible string on screen equals that SAME live instance's value —
//    self-consistency, never a hardcoded translation: runtime strings come
//    from Phrase OTA and may drift from the bundled arb (and from this file).
//
// The assertion surface is the logged-out Account tab's SignupNowWidget
// (login / signup CTA copy — localized). Navigation there is safe in every
// language because the bottom-nav labels are hardcoded English in
// main_app_root_screen.dart, not localized — tapTab's finders keep working.
//
// No login, so no credential defines needed. Each case is its own e2eTest and
// runs in a fresh app process (fresh state) like every other test in the suite.

/// (injected device language, expected resolved app language)
const _cases = [
  // All six supported languages resolve to themselves.
  ('en', 'en'),
  ('de', 'de'),
  ('es', 'es'),
  ('fr', 'fr'),
  ('it', 'it'),
  ('nl', 'nl'),
  // Unsupported languages fall back to EN (first entry of supportedLocales).
  ('pl', 'en'),
  ('ja', 'en'),
];

void main() {
  for (final (device, resolved) in _cases) {
    e2eTest(
      'locale $device resolves to $resolved and renders its strings',
      ($) async {
        // Fake the device's preferred languages BEFORE the app boots, so the
        // very first MaterialApp build resolves against them.
        final dispatcher = $.tester.binding.platformDispatcher;
        dispatcher.localeTestValue = Locale(device);
        dispatcher.localesTestValue = [Locale(device)];

        await bootApp($);

        // Logged-out Account tab hosts the localized SignupNow CTA copy.
        await tapTab($, AppTab.account);
        await $(SignupNowWidget).waitUntilVisible();

        final context = $.tester.element(find.byType(SignupNowWidget).first);

        // 1. Resolution (the fallback assertion for pl/ja).
        expect(
          Localizations.localeOf(context).languageCode,
          resolved,
          reason: 'device language "$device" must resolve to app locale "$resolved"',
        );

        // 2. The delegate loaded that language's AppLocalizations instance.
        final l10n = AppLocalizations.of(context)!;
        expect(
          l10n.localeName.split('_').first,
          resolved,
          reason: 'the loaded AppLocalizations instance must be "$resolved"',
        );

        // 3. The rendered CTA copy is that instance's strings. localeName being
        // right already pins WHICH translations l10n holds; this pins that the
        // widget tree actually renders them.
        expect(
          $(SignupNowWidget).$(l10n.dontHaveAnAccount),
          findsWidgets,
          reason: 'SignupNowWidget must render the resolved language\'s CTA copy',
        );
        expect(
          $(SignupNowWidget).$(l10n.signup),
          findsWidgets,
          reason: 'SignupNowWidget must render the resolved language\'s signup label',
        );
      },
    );
  }
}
