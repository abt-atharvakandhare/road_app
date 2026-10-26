import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/network/api_error_details.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: Scaffold(body: child),
  );
}

void main() {
  group('RMApiError.causeString', () {
    Future<String> resolve(WidgetTester tester, RMApiError error) async {
      late String resolved;
      await tester.pumpWidget(buildTestWidget(Builder(builder: (context) {
        resolved = error.causeString(context);
        return const SizedBox.shrink();
      })));
      return resolved;
    }

    testWidgets('APP_UPGRADE_REQUIRED resolves to the update-the-app message', (tester) async {
      final error = RMApiError(cause: 'Unauthorized', details: [ErrorDetails(code: 'APP_UPGRADE_REQUIRED')]);

      final resolved = await resolve(tester, error);

      expect(resolved, contains('update'));
      expect(resolved, isNot(contains('Unauthorized')));
    });

    testWidgets('defaultErrorMessage resolves to the generic message', (tester) async {
      final error = RMApiError(cause: '', defaultErrorMessage: true);

      expect(await resolve(tester, error), 'Something went wrong. Please try again later.');
    });

    testWidgets('any other error passes its cause through', (tester) async {
      final error = RMApiError(cause: 'Invalid credentials', details: [ErrorDetails(code: 'INVALID_CREDENTIALS')]);

      expect(await resolve(tester, error), 'Invalid credentials');
    });

    testWidgets('passkey verification failures resolve to the localized retry message', (tester) async {
      final error = RMApiError.passkeyVerificationFailed();

      expect(error.isPasskeyVerificationFailed, isTrue);
      expect(await resolve(tester, error), 'Passkey verification failed. Please try again.');
    });

    testWidgets('a server-sent MFA_PASSKEY_VERIFICATION_FAILED resolves the same way', (tester) async {
      final error = RMApiError(
          cause: 'Passkey could not be verified.',
          details: [ErrorDetails(code: 'MFA_PASSKEY_VERIFICATION_FAILED')]);

      expect(await resolve(tester, error), 'Passkey verification failed. Please try again.');
    });

    testWidgets('a missing passkey challenge resolves to the localized message', (tester) async {
      final error = RMApiError.passkeyChallengeMissing();

      expect(error.isPasskeyChallengeMissing, isTrue);
      expect(await resolve(tester, error), 'Passkey verification could not be started. Please try again.');
    });

    testWidgets('a failed passkey creation resolves to the localized message', (tester) async {
      final error = RMApiError.passkeyCreationFailed();

      expect(error.isPasskeyCreationFailed, isTrue);
      expect(await resolve(tester, error), 'Could not create a passkey on this device.');
    });

    testWidgets('an already-on-device refusal resolves to the localized message', (tester) async {
      final error = RMApiError.passkeyAlreadyOnDevice();

      expect(error.isPasskeyAlreadyOnDevice, isTrue);
      expect(await resolve(tester, error),
          'This device already has a passkey for this account. You can use it to sign in, or pick another verification method.');
    });
  });
}
