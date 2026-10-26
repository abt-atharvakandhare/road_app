import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/map_filter_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';
import 'package:road_mobile/ui/onboarding/login/login_email_password_widget.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/app_launch.dart';
import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// White-label branding: assert the running flavor's brand renders where the UI
// is brand-parameterised, and that NO other flavor's brand leaks in. Running
// under `--flavor friwigo` must show "FRIWIGO Account" — never "E-Flux
// Account".
//
// Both tests read the expectation from the app's own flavor config (F) at
// runtime, so this file is flavor-agnostic: build any flavor and the
// assertions follow. Neither test logs in, so it also runs on WL flavors
// before a per-provider staging test account exists.
//
// Brand surfaces covered (the credential-free ones):
//   1. Login sheet subtitle: '${F.appBrandName} ${l10n.account}'
//      (login_email_password_widget.dart).
//   2. Map filter "brand chargers" toggle: shown with the brand-substituted
//      l10n.brandnameChargers label unless F.mapBrandFilterType is
//      showBrandOnly, in which case the row is absent (map_filter_screen.dart).
// Logged-in surfaces (Account header, "<Brand> Card" on edit-payment-method,
// payment-consent copy) are exercised by the existing logged-in tests, which
// would surface a wrong brand indirectly but don't assert on it.

/// Brand names of every flavor EXCEPT the one running — none of these may
/// render. Enumerated from the app's own lookup, so a new flavor is covered
/// automatically.
Iterable<String> get _foreignBrands =>
    Flavor.values.map(F.brandNameOf).where((b) => b != F.appBrandName);

void main() {
  e2eTest(
    'wl branding: login sheet shows the flavor brand account label and no foreign brand',
    ($) async {
      await bootApp($);

      // Logged-out Account tab → open the login sheet via the SignupNow CTA
      // (same steps as loginAsStagingUser, minus credentials/submit).
      await tapTab($, AppTab.account);
      await $(SignupNowWidget).waitUntilVisible();
      await $(SignupNowWidget).$(RMTextButton).tap();
      await $(LoginEmailPasswordWidget).$(TextField).waitUntilVisible();

      // Compose the expected label from the app's own config + live l10n
      // (Phrase OTA may override the bundled arb — never hardcode the word
      // "Account" here, and the locale may not be English).
      final context = $.tester.element(find.byType(LoginEmailPasswordWidget));
      final l10n = AppLocalizations.of(context)!;
      final expected = '${F.appBrandName} ${l10n.account}';
      expect(
        $(LoginEmailPasswordWidget).$(expected),
        findsOneWidget,
        reason: 'login sheet must brand the account label as "$expected"',
      );

      // No other flavor's brand may appear anywhere on this screen (substring
      // match, so composed strings like "E-Flux Account" are caught too).
      for (final brand in _foreignBrands) {
        expect(
          find.textContaining(brand),
          findsNothing,
          reason: 'foreign brand "$brand" must not render in a ${F.appBrandName} build',
        );
      }
    },
  );

  e2eTest(
    'wl branding: map filter brand toggle follows flavor config',
    ($) async {
      await bootApp($);

      // Map tab (available logged out) → filter screen. Same readiness signals
      // as the map filter tests: the search TextField, then the filter
      // IconButton at index 1 in InitialWidget.
      await tapTab($, AppTab.map);
      await $(ExploreRootScreen).waitUntilVisible();
      await $(InitialWidget).$(TextField).waitUntilVisible();
      await $(InitialWidget).$(IconButton).at(1).tap();
      await $(MapFilterScreen).waitUntilVisible();
      await $(MapFilterScreen).$(Switch).waitUntilVisible();

      final context = $.tester.element(find.byType(MapFilterScreen));
      final l10n = AppLocalizations.of(context)!;
      final brandToggleLabel =
          l10n.brandnameChargers.replaceAll('--brandname--', F.appBrandName);

      if (F.mapBrandFilterType == MapBrandFilterType.showBrandOnly) {
        // Brand-only flavors (elexon, opcharge) have no toggle — the map is
        // already restricted to the brand.
        expect(
          $(MapFilterScreen).$(brandToggleLabel),
          findsNothing,
          reason: 'showBrandOnly flavors must not render the "$brandToggleLabel" toggle',
        );
      } else {
        expect(
          $(MapFilterScreen).$(brandToggleLabel),
          findsOneWidget,
          reason: 'the map filter must offer the "$brandToggleLabel" toggle for this flavor',
        );
      }
    },
  );
}
