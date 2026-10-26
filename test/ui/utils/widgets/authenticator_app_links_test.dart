import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/authenticator_app_links.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  group('AuthenticatorAppLinks', () {
    testWidgets('substitutes all three app names into the template', (tester) async {
      await tester.pumpWidget(buildTestWidget(const AuthenticatorAppLinks()));

      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final rendered = richText.text.toPlainText();

      expect(rendered, isNot(contains('--authoption--')));
      expect(rendered, contains('Google Authenticator'));
      expect(rendered, contains('1Password'));
      expect(rendered, contains('Authy'));
      expect(rendered, isNot(contains('Translation failure')));
    });
  });
}
