import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';

void main() {
  group('SessionStats', () {
    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'totalKwh': 145.5,
          'totalCosts': 52.30,
          'totalDurationSeconds': 19800.0,
          'currency': 'EUR',
        };

        final stats = SessionStats.fromJson(json);

        expect(stats.totalKwh, equals(145.5));
        expect(stats.totalCosts, equals(52.30));
        expect(stats.totalDurationSeconds, equals(19800.0));
        expect(stats.currency, equals('EUR'));
      });

      test('should handle null values for optional fields', () {
        final json = {
          'totalKwh': null,
          'totalCosts': null,
          'totalDurationSeconds': null,
          'currency': 'EUR',
        };

        final stats = SessionStats.fromJson(json);

        expect(stats.totalKwh, isNull);
        expect(stats.totalCosts, isNull);
        expect(stats.totalDurationSeconds, isNull);
        expect(stats.currency, equals('EUR'));
      });

      test('should handle missing optional fields', () {
        final json = <String, dynamic>{
          'currency': 'EUR',
        };

        final stats = SessionStats.fromJson(json);

        expect(stats.totalKwh, isNull);
        expect(stats.totalCosts, isNull);
        expect(stats.totalDurationSeconds, isNull);
        expect(stats.currency, equals('EUR'));
      });

      test('should parse zero values', () {
        final json = {
          'totalKwh': 0.0,
          'totalCosts': 0.0,
          'totalDurationSeconds': 0.0,
          'currency': 'USD',
        };

        final stats = SessionStats.fromJson(json);

        expect(stats.totalKwh, equals(0.0));
        expect(stats.totalCosts, equals(0.0));
        expect(stats.totalDurationSeconds, equals(0.0));
        expect(stats.currency, equals('USD'));
      });

      test('should handle large numbers', () {
        final json = {
          'totalKwh': 99999.99,
          'totalCosts': 88888.88,
          'totalDurationSeconds': 999999.0,
          'currency': 'GBP',
        };

        final stats = SessionStats.fromJson(json);

        expect(stats.totalKwh, equals(99999.99));
        expect(stats.totalCosts, equals(88888.88));
        expect(stats.totalDurationSeconds, equals(999999.0));
        expect(stats.currency, equals('GBP'));
      });
    });

    group('toJson', () {
      test('should serialize to JSON with all fields', () {
        final stats = SessionStats(
          totalKwh: 145.5,
          totalCosts: 52.30,
          totalDurationSeconds: 19800.0,
          currency: 'EUR',
        );

        final json = stats.toJson();

        expect(json['totalKwh'], equals(145.5));
        expect(json['totalCosts'], equals(52.30));
        expect(json['totalDurationSeconds'], equals(19800.0));
        expect(json['currency'], equals('EUR'));
      });

      test('should serialize null values', () {
        final stats = SessionStats(currency: 'EUR');

        final json = stats.toJson();

        expect(json['totalKwh'], isNull);
        expect(json['totalCosts'], isNull);
        expect(json['totalDurationSeconds'], isNull);
        expect(json['currency'], equals('EUR'));
      });
    });
  });

  group('Meta', () {
    group('fromJson', () {
      test('should parse JSON with stats included', () {
        final json = {
          'limit': 50,
          'skip': 0,
          'total': 100,
          'stats': {
            'totalKwh': 145.5,
            'totalCosts': 52.30,
            'totalDurationSeconds': 19800.0,
            'currency': 'EUR',
          },
        };

        final meta = Meta.fromJson(json);

        expect(meta.limit, equals(50));
        expect(meta.skip, equals(0));
        expect(meta.total, equals(100));
        expect(meta.stats, isNotNull);
        expect(meta.stats!.totalKwh, equals(145.5));
        expect(meta.stats!.currency, equals('EUR'));
      });

      test('should parse JSON with null stats', () {
        final json = {
          'limit': 50,
          'skip': 0,
          'total': 100,
          'stats': null,
        };

        final meta = Meta.fromJson(json);

        expect(meta.limit, equals(50));
        expect(meta.skip, equals(0));
        expect(meta.total, equals(100));
        expect(meta.stats, isNull);
      });

      test('should parse JSON with missing stats field', () {
        final json = {
          'limit': 50,
          'skip': 0,
          'total': 100,
        };

        final meta = Meta.fromJson(json);

        expect(meta.limit, equals(50));
        expect(meta.skip, equals(0));
        expect(meta.total, equals(100));
        expect(meta.stats, isNull);
      });
    });

    group('toJson', () {
      test('should serialize with stats', () {
        final meta = Meta(
          limit: 50,
          skip: 0,
          total: 100,
          stats: SessionStats(
            totalKwh: 145.5,
            totalCosts: 52.30,
            totalDurationSeconds: 19800.0,
            currency: 'EUR',
          ),
        );

        final json = meta.toJson();

        expect(json['limit'], equals(50));
        expect(json['skip'], equals(0));
        expect(json['total'], equals(100));
        expect(json['stats'], isNotNull);
        // stats is serialized as SessionStats object, need to convert to JSON again
        final statsJson = (json['stats'] as SessionStats).toJson();
        expect(statsJson['totalKwh'], equals(145.5));
      });

      test('should serialize with null stats', () {
        final meta = Meta(
          limit: 50,
          skip: 0,
          total: 100,
          stats: null,
        );

        final json = meta.toJson();

        expect(json['limit'], equals(50));
        expect(json['skip'], equals(0));
        expect(json['total'], equals(100));
        expect(json['stats'], isNull);
      });
    });
  });

  group('SessionsResponseModel', () {
    test('should parse complete response with stats', () {
      final json = {
        'data': [],
        'meta': {
          'limit': 50,
          'skip': 0,
          'total': 100,
          'stats': {
            'totalKwh': 145.5,
            'totalCosts': 52.30,
            'totalDurationSeconds': 19800.0,
            'currency': 'EUR',
          },
        },
      };

      final response = SessionsResponseModel.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.meta.total, equals(100));
      expect(response.meta.stats, isNotNull);
      expect(response.meta.stats!.totalKwh, equals(145.5));
    });
  });
}
