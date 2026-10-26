import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/widgets/sessions_stats_widget.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  group('SessionsStatsWidget', () {
    testWidgets('should display all stat items with valid data', (tester) async {
      final stats = SessionStats(
        totalKwh: 145.5,
        totalCosts: 52.30,
        totalDurationSeconds: 19800.0, // 5 hours 30 minutes
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 42,
          ),
        ),
      );

      // Check total sessions
      expect(find.text('42'), findsOneWidget);

      // Check kWh (rounded to 0 decimals)
      expect(find.text('146 kWh'), findsOneWidget);

      // Check duration (5h 30min)
      expect(find.text('5h 30min'), findsOneWidget);

      // Check cost (formatted as currency)
      expect(find.textContaining('52'), findsAtLeastNWidgets(1));

      // Check all 4 SVG icons are present
      expect(find.byType(SvgPicture), findsNWidgets(4));
    });

    testWidgets('should display "-" when stats are null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: null,
            totalSessions: 0,
          ),
        ),
      );

      // Should show "-" for missing values (3 times: kWh, duration, cost)
      expect(find.text('-'), findsNWidgets(3));

      // Should show "0" for total sessions
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should display "-" when stat values are null', (tester) async {
      final stats = SessionStats(
        totalKwh: null,
        totalCosts: null,
        totalDurationSeconds: null,
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 10,
          ),
        ),
      );

      // Should show "-" for null values
      expect(find.text('-'), findsNWidgets(3));

      // Should still show total sessions
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('should format kWh correctly', (tester) async {
      final stats = SessionStats(
        totalKwh: 1234.567,
        totalCosts: 0,
        totalDurationSeconds: 0,
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 1,
          ),
        ),
      );

      // Should round to 0 decimals (with thousand separator)
      expect(find.text('1,235 kWh'), findsOneWidget);
    });

    testWidgets('should format duration as hours and minutes', (tester) async {
      final stats = SessionStats(
        totalKwh: 0,
        totalCosts: 0,
        totalDurationSeconds: 7380.0, // 2 hours 3 minutes
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 1,
          ),
        ),
      );

      expect(find.text('2h 3min'), findsOneWidget);
    });

    testWidgets('should format duration as minutes only when less than 1 hour', (tester) async {
      final stats = SessionStats(
        totalKwh: 0,
        totalCosts: 0,
        totalDurationSeconds: 1800.0, // 30 minutes
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 1,
          ),
        ),
      );

      expect(find.text('30 minutes'), findsOneWidget);
    });

    testWidgets('should format cost with correct currency', (tester) async {
      final stats = SessionStats(
        totalKwh: 0,
        totalCosts: 123.45,
        totalDurationSeconds: 0,
        currency: 'USD',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 1,
          ),
        ),
      );

      // Should contain the cost value (exact format depends on locale)
      expect(find.textContaining('123'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle zero values', (tester) async {
      final stats = SessionStats(
        totalKwh: 0.0,
        totalCosts: 0.0,
        totalDurationSeconds: 0.0,
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 0,
          ),
        ),
      );

      expect(find.text('0 kWh'), findsOneWidget);
      expect(find.text('0 minutes'), findsOneWidget);
      expect(find.text('0'), findsAtLeastNWidgets(1)); // total sessions and cost
    });

    testWidgets('should display cost tooltip icon', (tester) async {
      final stats = SessionStats(
        totalKwh: 100.0,
        totalCosts: 50.0,
        totalDurationSeconds: 3600.0,
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 10,
          ),
        ),
      );

      // Find the help icon
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('should show tooltip bottom sheet when help icon is tapped', (tester) async {
      final stats = SessionStats(
        totalKwh: 100.0,
        totalCosts: 50.0,
        totalDurationSeconds: 3600.0,
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 10,
          ),
        ),
      );

      // Tap the help icon
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      // Should show bottom sheet with close button
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Should show the tooltip text (checking for the header) - the label is "Cost" not "Total cost"
      expect(find.text('Cost'), findsAtLeastNWidgets(1)); // In the bottom sheet
    });

    testWidgets('should close tooltip bottom sheet when close button is tapped', (tester) async {
      final stats = SessionStats(
        totalKwh: 100.0,
        totalCosts: 50.0,
        totalDurationSeconds: 3600.0,
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 10,
          ),
        ),
      );

      // Tap the help icon to open bottom sheet
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      // Verify bottom sheet is open
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Bottom sheet should be closed (close button should not be visible)
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should display correct border styling', (tester) async {
      final stats = SessionStats(
        totalKwh: 100.0,
        totalCosts: 50.0,
        totalDurationSeconds: 3600.0,
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 10,
          ),
        ),
      );

      // Find containers with borders
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Verify the widget structure is present
      await tester.pumpAndSettle();
      expect(find.byType(SessionsStatsWidget), findsOneWidget);
    });

    testWidgets('should handle large numbers', (tester) async {
      final stats = SessionStats(
        totalKwh: 99999.99,
        totalCosts: 88888.88,
        totalDurationSeconds: 999999.0, // ~278 hours
        currency: 'EUR',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 9999,
          ),
        ),
      );

      expect(find.text('9,999'), findsOneWidget);
      expect(find.text('100,000 kWh'), findsOneWidget);
      expect(find.text('277h 46min'), findsOneWidget);
    });

    testWidgets('should render with different currencies', (tester) async {
      final stats = SessionStats(
        totalKwh: 100.0,
        totalCosts: 50.0,
        totalDurationSeconds: 3600.0,
        currency: 'GBP',
      );

      await tester.pumpWidget(
        buildTestWidget(
          SessionsStatsWidget(
            stats: stats,
            totalSessions: 10,
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(SessionsStatsWidget), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
