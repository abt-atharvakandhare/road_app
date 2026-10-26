import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/qr_scanner_widget.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

@GenerateNiceMocks([
  MockSpec<ChargeNowBloc>(),
  MockSpec<AppLocalizations>(),
])
import 'qr_scanner_widget_ui_test.mocks.dart';

void main() {
  late MockChargeNowBloc mockChargeNowBloc;
  late MockAppLocalizations mockLocalizations;

  setUpAll(() {
    provideDummy<ChargeNowState>(const ChargeNowState.scanningQrCode());
  });

  setUp(() {
    mockChargeNowBloc = MockChargeNowBloc();
    mockLocalizations = MockAppLocalizations();

    // Setup default localization strings
    when(mockLocalizations.scanStationQrCode).thenReturn('Scan station QR code');
    when(mockLocalizations.useCameraToIdentifyStationId).thenReturn('Use camera to identify your station ID');
    when(mockLocalizations.cancel).thenReturn('Cancel');
    when(mockLocalizations.cameraPermissionRequired).thenReturn('Camera Permission Required');
    when(mockLocalizations.cameraPermissionMessage).thenReturn('Camera permission is required to scan QR codes.');
    when(mockLocalizations.cameraPermissionDenied).thenReturn('Camera permission denied');
    when(mockLocalizations.errorAccessingCamera).thenReturn('Error accessing camera');
    when(mockLocalizations.openSettings).thenReturn('Open Settings');
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en')],
      home: BlocProvider<ChargeNowBloc>.value(
        value: mockChargeNowBloc,
        child: Scaffold(body: child),
      ),
    );
  }

  group('QrScannerWidget UI Tests', () {
    testWidgets('should display title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const QrScannerWidget()));
      await tester.pumpAndSettle();

      // Note: Due to the MobileScanner dependency, this test might fail in test environment
      // The actual scanner requires platform-specific implementations

      // Check for title
      expect(find.text('Scan station QR code'), findsOneWidget);

      // Check for subtitle
      expect(find.text('Use camera to identify your station ID'), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const QrScannerWidget()));
      await tester.pumpAndSettle();

      // Check for SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Check for container with camera preview (will be a Container due to MobileScanner mock)
      expect(find.byType(Container).first, findsOneWidget);
    });
  });
}
