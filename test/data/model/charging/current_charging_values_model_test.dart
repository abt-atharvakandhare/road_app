import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/charging/current_charging_values_model.dart';

void main() {
  group('CurrentChargingValues.fromJson', () {
    test('parses all fields from a complete payload', () {
      final values = CurrentChargingValues.fromJson({
        'costCurrentTotal': 125,
        'energy': 4300,
        'stateOfCharge': 72,
      });

      expect(values.costCurrentTotal, 125);
      expect(values.energy, 4300);
      expect(values.stateOfCharge, 72);
      expect(values.sessionStartedAt, isNull);
    });

    test('defaults missing cost/energy fields to 0 and leaves stateOfCharge null', () {
      // BE is known to send partial payloads early in a session — see Apr 2026 testing
      // where only costCurrentTotal was returned. stateOfCharge is null when omitted
      // (typical of AC chargers that don't report SoC) so the UI can hide it.
      final values = CurrentChargingValues.fromJson({'costCurrentTotal': 0});

      expect(values.costCurrentTotal, 0);
      expect(values.energy, 0);
      expect(values.stateOfCharge, isNull);
    });

    test('ignores sessionStartedAt in the JSON (set by caller only)', () {
      final values = CurrentChargingValues.fromJson({
        'costCurrentTotal': 0,
        'energy': 0,
        'stateOfCharge': 0,
        'sessionStartedAt': 1775646179528,
      });

      expect(values.sessionStartedAt, isNull);
    });
  });

  group('CurrentChargingValues.withSessionStartedAt', () {
    test('returns a copy with the session start set', () {
      const original = CurrentChargingValues(
        costCurrentTotal: 10,
        energy: 100,
        stateOfCharge: 50,
      );
      final started = DateTime.utc(2026, 4, 14, 13);
      final copy = original.withSessionStartedAt(started);

      expect(copy.costCurrentTotal, 10);
      expect(copy.energy, 100);
      expect(copy.stateOfCharge, 50);
      expect(copy.sessionStartedAt, started);
      // Original stays unchanged (sessionStartedAt is final).
      expect(original.sessionStartedAt, isNull);
    });

    test('accepts null to clear the session start', () {
      final seeded = CurrentChargingValues(
        costCurrentTotal: 0,
        energy: 0,
        stateOfCharge: 0,
        sessionStartedAt: DateTime.utc(2026, 4, 14),
      );
      expect(seeded.withSessionStartedAt(null).sessionStartedAt, isNull);
    });
  });

  group('CurrentChargingValues stateOfCharge nullability', () {
    test('null SoC round-trips through JSON', () {
      final values = CurrentChargingValues.fromJson({'costCurrentTotal': 0, 'energy': 0});
      expect(values.stateOfCharge, isNull);
    });

    test('toDictionary omits stateOfCharge when null', () {
      const values = CurrentChargingValues(costCurrentTotal: 0, energy: 0);
      expect(values.toDictionary().containsKey('stateOfCharge'), isFalse);
    });
  });

  group('CurrentChargingValues.toDictionary', () {
    test('serialises every numeric field plus sessionStartedAt when present', () {
      final started = DateTime.fromMillisecondsSinceEpoch(1775646179528, isUtc: true);
      final dict = CurrentChargingValues(
        costCurrentTotal: 42,
        energy: 1234,
        stateOfCharge: 61,
        sessionStartedAt: started,
      ).toDictionary();

      expect(dict, {
        'costCurrentTotal': 42,
        'energy': 1234,
        'stateOfCharge': 61,
        'sessionStartedAt': 1775646179528,
      });
    });

    test('omits sessionStartedAt when null', () {
      const values = CurrentChargingValues(costCurrentTotal: 0, energy: 0, stateOfCharge: 0);
      expect(values.toDictionary().containsKey('sessionStartedAt'), isFalse);
    });

    test('toDictionary includes stateOfCharge when explicitly 0', () {
      // Null vs 0 distinction matters: null means "no data" and the UI hides SoC,
      // 0 means "the charger reported 0%" and the UI must show it.
      const values = CurrentChargingValues(costCurrentTotal: 0, energy: 0, stateOfCharge: 0);
      expect(values.toDictionary()['stateOfCharge'], 0);
    });
  });
}
