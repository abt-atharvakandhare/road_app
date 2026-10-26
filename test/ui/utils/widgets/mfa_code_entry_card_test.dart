import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_code_entry_card.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:sms_autofill/sms_autofill.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  const smsChannel = MethodChannel('sms_autofill');

  /// Outgoing sms_autofill calls made by the widget under test.
  late List<String> smsChannelLog;

  setUp(() {
    smsChannelLog = [];
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(smsChannel,
        (call) async {
      smsChannelLog.add(call.method);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(smsChannel, null);
  });

  /// Delivers an SMS-retriever code as the platform side would.
  Future<void> receiveSmsCode(WidgetTester tester, String code) async {
    final data = const StandardMethodCodec().encodeMethodCall(MethodCall('smscode', code));
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage('sms_autofill', data, (_) {});
    await tester.pump();
    await tester.pump();
  }

  group('code entry mechanics', () {
    testWidgets('six digits auto-submit and a wrong code shows the inline error', (tester) async {
      final submitted = <String>[];
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: null,
        isLoading: false,
        onSubmit: (code) async {
          submitted.add(code);
          return TwoFactorAuthResult.wrongCode;
        },
      )));

      await tester.enterText(find.byType(PinInputTextField), '123456');
      await tester.pump();

      expect(submitted, ['123456']);
      expect(find.text('Code entered is incorrect. Please try again or request a new code.'), findsOneWidget);
    });

    testWidgets('an exhausted code clears the pin and steers to resend', (tester) async {
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: null,
        isLoading: false,
        onSubmit: (code) async => TwoFactorAuthResult.codeExhausted,
        onResend: () async {},
      )));

      await tester.enterText(find.byType(PinInputTextField), '123456');
      await tester.pump();

      expect(find.text('That code is no longer valid. Please request a new one.'), findsOneWidget);
      final pin = tester.widget<PinInputTextField>(find.byType(PinInputTextField));
      expect(pin.controller!.text, isEmpty);
    });

    testWidgets('a guess-limit result counts down and re-enables verify after the wait', (tester) async {
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: null,
        isLoading: false,
        onSubmit: (code) async => const TwoFactorAuthRateLimited(2),
      )));

      await tester.enterText(find.byType(PinInputTextField), '123456');
      await tester.pump();

      expect(find.textContaining('Too many attempts.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Too many attempts.'), findsNothing);
    });

    testWidgets('the resend link is held behind the server-sent wait', (tester) async {
      var resends = 0;
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: 2,
        isLoading: false,
        onSubmit: (code) async => TwoFactorAuthResult.success,
        onResend: () async {
          resends++;
        },
      )));

      expect(find.textContaining('Resend available in'), findsOneWidget);
      expect(find.text('resend verification code'), findsNothing);

      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('Resend available in'), findsNothing);
      await tester.tap(find.text('resend verification code'));
      await tester.pump();
      expect(resends, 1);
    });

    testWidgets('without a resend handler or footer there is no separator section', (tester) async {
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: null,
        isLoading: false,
        onSubmit: (code) async => TwoFactorAuthResult.success,
      )));

      expect(find.byType(RMSeparator), findsNothing);
      expect(find.textContaining("Didn't receive the code?"), findsNothing);
    });

    testWidgets('host footer links render below the separator', (tester) async {
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: null,
        isLoading: false,
        onSubmit: (code) async => TwoFactorAuthResult.success,
        footer: const [Text('switch-method-link'), Text('recovery-link')],
      )));

      expect(find.byType(RMSeparator), findsOneWidget);
      expect(find.text('switch-method-link'), findsOneWidget);
      expect(find.text('recovery-link'), findsOneWidget);
    });
  });

  group('SMS autofill', () {
    testWidgets('an SMS context starts the retriever listener and submits the received code', (tester) async {
      final submitted = <String>[];
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: null,
        isLoading: false,
        smsAutofill: true,
        onSubmit: (code) async {
          submitted.add(code);
          return TwoFactorAuthResult.success;
        },
      )));
      await tester.pump();

      expect(smsChannelLog, contains('listenForCode'));

      await receiveSmsCode(tester, '654321');

      final pin = tester.widget<PinInputTextField>(find.byType(PinInputTextField));
      expect(pin.controller!.text, '654321');
      expect(submitted, ['654321']);
    });

    testWidgets('a non-SMS context never starts the listener and ignores retriever codes', (tester) async {
      final submitted = <String>[];
      await tester.pumpWidget(buildTestWidget(MfaCodeEntryCard(
        header: 'header',
        nextSendAfterSeconds: null,
        isLoading: false,
        onSubmit: (code) async {
          submitted.add(code);
          return TwoFactorAuthResult.success;
        },
      )));
      await tester.pump();

      expect(smsChannelLog, isNot(contains('listenForCode')));

      await receiveSmsCode(tester, '654321');

      final pin = tester.widget<PinInputTextField>(find.byType(PinInputTextField));
      expect(pin.controller!.text, isEmpty);
      expect(submitted, isEmpty);
    });
  });
}
