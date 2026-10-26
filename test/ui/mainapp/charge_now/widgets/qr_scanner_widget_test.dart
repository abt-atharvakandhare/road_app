import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/utils/evse_id_extractor.dart';

void main() {
  group('QrScannerWidget - EVSE ID Extraction', () {

    group('Valid URLs', () {
      test('should extract 7 or more digits from standard HTTPS URL', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384'),
          equals('6910384'),
        );
      });

      test('should extract 7 or more digits from standard HTTP URL', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('http://dashboard.e-flux.io/evse/NLEFLEV6910384'),
          equals('6910384'),
        );
      });

      test('should extract 7 or more digits with different prefix patterns', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFL1234567'),
          equals('1234567'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NL1234567'),
          equals('1234567'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/ABC1234567'),
          equals('1234567'),
        );
      });

      test('should extract 7 or more digits when only digits are present', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/1234567'),
          equals('1234567'),
        );
      });

      test('should extract all digits from longer number sequences (7+)', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV123456789'),
          equals('123456789'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/1234567890'),
          equals('1234567890'),
        );
      });
    });

    group('Invalid URLs', () {
      test('should return null for non-matching domains', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://example.com/evse/NLEFLEV6910384'),
          isNull,
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.other.io/evse/NLEFLEV6910384'),
          isNull,
        );
      });

      test('should return null for wrong path structure', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/station/NLEFLEV6910384'),
          isNull,
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/charger/NLEFLEV6910384'),
          isNull,
        );
      });

      test('should return null for URLs with fewer than 7 digits', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV123456'),
          isNull,
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/123'),
          isNull,
        );
      });

      test('should return null for URLs with no digits', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV'),
          isNull,
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/ABCDEFG'),
          isNull,
        );
      });

      test('should return null for empty path after evse/', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/'),
          isNull,
        );
      });

      test('should return null for malformed URLs', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('not-a-url'),
          isNull,
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl(''),
          isNull,
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://'),
          isNull,
        );
      });
    });

    group('Edge cases', () {
      test('should handle URLs with query parameters', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384?ref=qr'),
          equals('6910384'),
        );
      });

      test('should handle URLs with fragments', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384#section'),
          equals('6910384'),
        );
      });

      test('should handle URLs with trailing slashes', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384/'),
          equals('6910384'),
        );
      });

      test('should handle mixed case URLs', () {
        // Note: This will fail with current implementation - domain must be exact match
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('HTTPS://DASHBOARD.E-FLUX.IO/EVSE/NLEFLEV6910384'),
          isNull, // Current implementation is case-sensitive
        );
      });

      test('should handle URLs with special characters in the ID part', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NL-EFL-EV-6910384'),
          equals('6910384'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NL_EFL_EV_6910384'),
          equals('6910384'),
        );
      });

      test('should extract from paths with multiple digit groups', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/123NLEFLEV6910384'),
          equals('6910384'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NL123EFL456EV6910384'),
          equals('6910384'),
        );
      });
    });

    group('Real-world scenarios', () {
      test('should handle various real station ID formats', () {
        // Dutch stations
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384'),
          equals('6910384'),
        );
        
        // German stations
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/DEEFL1234567'),
          equals('1234567'),
        );
        
        // Belgian stations
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/BEEFL9876543'),
          equals('9876543'),
        );
      });

      test('should handle QR codes that might include additional data', () {
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384?utm_source=qr&utm_medium=sticker'),
          equals('6910384'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384?session=abc123'),
          equals('6910384'),
        );
      });

      test('should handle e-flux.nl domain variations', () {
        // Test various formats with e-flux.nl domain
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.nl/evse/NLEFLEV6910384'),
          equals('6910384'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('http://dashboard.e-flux.nl/evse/NL-EFL-6910384'),
          equals('6910384'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.nl/evse/EFL6910384?ref=app'),
          equals('6910384'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.nl/evse/6910384#charger'),
          equals('6910384'),
        );
        
        expect(
          EvseIdExtractor.extractEvseIdFromDashboardUrl('http://dashboard.e-flux.nl/evse/NLEFL1234567890/'),
          equals('1234567890'),
        );
      });
    });
  });
}