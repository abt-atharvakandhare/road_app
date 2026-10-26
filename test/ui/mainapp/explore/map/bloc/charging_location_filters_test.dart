import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:road_mobile/data/evse_capabilties.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/charging_location_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([SharedPreferences, DebugControlsRepo])
import 'charging_location_filters_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSharedPreferences mockPrefs;
  late MockDebugControlsRepo mockDebugControlsRepo;

  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockDebugControlsRepo = MockDebugControlsRepo();

    // Register mocks with GetIt
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    getIt.registerSingleton<SharedPreferences>(mockPrefs);

    if (getIt.isRegistered<DebugControlsRepo>()) {
      getIt.unregister<DebugControlsRepo>();
    }
    getIt.registerSingleton<DebugControlsRepo>(mockDebugControlsRepo);

    // Default mock behavior
    when(mockDebugControlsRepo.showAllStationsOnAllFlavors).thenReturn(false);
  });

  tearDown(() {
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    if (getIt.isRegistered<DebugControlsRepo>()) {
      getIt.unregister<DebugControlsRepo>();
    }
  });

  group('ChargingLocationFilters', () {
    group('Constructor Defaults', () {
      test('should have correct default values', () {
        final filters = ChargingLocationFilters();

        expect(filters.isAvailable, isFalse);
        expect(filters.isDcCharger, isFalse);
        expect(filters.withoutAdditionalFee, isFalse);
        expect(filters.supportsRemoteCharge, isFalse);
        expect(filters.minPowerLevel, equals(0));
        expect(filters.connectorTypes, isEmpty);
        expect(filters.capabilities, isEmpty);
        expect(filters.remoteSessionEnabledPartyIds, equals(['EFL']));
        expect(filters.includeOperators, isEmpty);
        expect(filters.excludeOperators, isEmpty);
      });

      test('should accept custom values', () {
        final filters = ChargingLocationFilters(
          isAvailable: true,
          isDcCharger: true,
          withoutAdditionalFee: true,
          supportsRemoteCharge: true,
          minPowerLevel: 3,
          connectorTypes: ['TYPE_2', 'CCS'],
          capabilities: ['RFID_READER'],
          remoteSessionEnabledPartyIds: ['EFL', 'OPC'],
        );

        expect(filters.isAvailable, isTrue);
        expect(filters.isDcCharger, isTrue);
        expect(filters.withoutAdditionalFee, isTrue);
        expect(filters.supportsRemoteCharge, isTrue);
        expect(filters.minPowerLevel, equals(3));
        expect(filters.connectorTypes, equals(['TYPE_2', 'CCS']));
        expect(filters.capabilities, equals(['RFID_READER']));
        expect(filters.remoteSessionEnabledPartyIds, equals(['EFL', 'OPC']));
      });
    });

    group('copyWith', () {
      test('should copy all fields when provided', () {
        final original = ChargingLocationFilters();
        final copied = original.copyWith(
          isAvailable: true,
          isDcCharger: true,
          withoutAdditionalFee: true,
          supportsRemoteCharge: true,
          minPowerLevel: 5,
          connectorTypes: ['CCS'],
          capabilities: ['RFID_READER'],
          remoteSessionEnabledPartyIds: ['ABC'],
        );

        expect(copied.isAvailable, isTrue);
        expect(copied.isDcCharger, isTrue);
        expect(copied.withoutAdditionalFee, isTrue);
        expect(copied.supportsRemoteCharge, isTrue);
        expect(copied.minPowerLevel, equals(5));
        expect(copied.connectorTypes, equals(['CCS']));
        expect(copied.capabilities, equals(['RFID_READER']));
        expect(copied.remoteSessionEnabledPartyIds, equals(['ABC']));
      });

      test('should preserve original values when not provided', () {
        final original = ChargingLocationFilters(
          isAvailable: true,
          supportsRemoteCharge: true,
          remoteSessionEnabledPartyIds: ['TEST'],
        );
        final copied = original.copyWith(isDcCharger: true);

        expect(copied.isAvailable, isTrue);
        expect(copied.isDcCharger, isTrue);
        expect(copied.supportsRemoteCharge, isTrue);
        expect(copied.remoteSessionEnabledPartyIds, equals(['TEST']));
      });
    });

    group('supportsRemoteCharge filtering', () {
      test('apiMap should include remote charge capability when enabled', () {
        final filters = ChargingLocationFilters(supportsRemoteCharge: true);
        final apiMap = filters.apiMap;

        expect(apiMap['capabilities'],
            contains(EvseCapabilities.remoteStartStopCapable));
      });

      test('apiMap should include partyIds when supportsRemoteCharge enabled',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: true,
          remoteSessionEnabledPartyIds: ['EFL', 'OPC'],
        );
        final apiMap = filters.apiMap;

        expect(apiMap['partyIds'], equals(['EFL', 'OPC']));
      });

      test(
          'apiMap should include restrictToProvider when supportsRemoteCharge enabled',
          () {
        final filters = ChargingLocationFilters(supportsRemoteCharge: true);
        final apiMap = filters.apiMap;

        expect(apiMap['restrictToProvider'], equals(F.restrictMapCallsToProvider));
      });

      test(
          'supportsRemoteCharge should override capabilities when both are set',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: true,
          capabilities: ['RFID_READER', 'OTHER_CAPABILITY'],
        );
        final apiMap = filters.apiMap;

        // When supportsRemoteCharge is true, it sets its own capabilities
        expect(apiMap['capabilities'],
            equals([EvseCapabilities.remoteStartStopCapable]));
      });

      test('capabilities should be used when supportsRemoteCharge is false',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          capabilities: ['RFID_READER', 'OTHER_CAPABILITY'],
        );
        final apiMap = filters.apiMap;

        expect(
            apiMap['capabilities'], equals(['RFID_READER', 'OTHER_CAPABILITY']));
      });

      test('partyIds should not be set when supportsRemoteCharge is false', () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          remoteSessionEnabledPartyIds: ['EFL', 'OPC'],
        );
        final apiMap = filters.apiMap;

        expect(apiMap.containsKey('partyIds'), isFalse);
      });
    });

    group('activeFilterCount with supportsRemoteCharge', () {
      test(
          'should count supportsRemoteCharge as 1 filter despite adding 3 items to apiMap',
          () {
        final filters = ChargingLocationFilters(supportsRemoteCharge: true);

        // supportsRemoteCharge adds: capabilities, partyIds, restrictToProvider (3 items)
        // But should only count as 1 filter
        final apiMapLength = filters.apiMap.length;
        expect(apiMapLength, equals(3));

        // activeFilterCount should be 1 (3 - 2 = 1)
        expect(filters.activeFilterCount, equals(1));
      });

      test(
          'should correctly count multiple filters including supportsRemoteCharge',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: true,
          isAvailable: true,
          isDcCharger: true,
        );

        // isAvailable adds: status (1)
        // isDcCharger adds: powerType (1)
        // supportsRemoteCharge adds: capabilities, partyIds, restrictToProvider (3)
        // Total apiMap items: 5
        // But supportsRemoteCharge should count as 1, so: 5 - 2 = 3
        expect(filters.activeFilterCount, equals(3));
      });

      test('should not subtract when supportsRemoteCharge is false', () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          isAvailable: true,
          isDcCharger: true,
        );

        // isAvailable adds: status (1)
        // isDcCharger adds: powerType (1)
        // Total: 2
        expect(filters.activeFilterCount, equals(2));
      });
    });

    group('apiMapWithWorkarounds', () {
      test(
          'should skip workaround when supportsRemoteCharge is enabled and capabilities contains REMOTE_START_STOP_CAPABLE',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: true,
        );
        final apiMap = filters.apiMapWithWorkarounds;

        // restrictToProvider should come from supportsRemoteCharge logic, not workaround
        expect(apiMap['restrictToProvider'], equals(F.restrictMapCallsToProvider));
      });

      test(
          'should apply workaround when supportsRemoteCharge is false but capabilities contains REMOTE_START_STOP_CAPABLE',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          capabilities: [EvseCapabilities.remoteStartStopCapable],
        );
        final apiMap = filters.apiMapWithWorkarounds;

        // Workaround should set restrictToProvider to true
        expect(apiMap['restrictToProvider'], isTrue);
      });

      test(
          'should apply workaround when REMOTE_START_STOP_CAPABLE is set and no operators are selected',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          capabilities: [EvseCapabilities.remoteStartStopCapable],
          includeOperators: [],
        );
        final apiMap = filters.apiMapWithWorkarounds;

        expect(apiMap['restrictToProvider'], isTrue);
      });

      test(
          'should skip workaround and preserve includeOperators when operators are selected',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          capabilities: [EvseCapabilities.remoteStartStopCapable],
          includeOperators: ['Tesla'],
        );
        final apiMap = filters.apiMapWithWorkarounds;

        expect(apiMap.containsKey('restrictToProvider'), isFalse);
        expect(apiMap['includeOperators'], equals(['Tesla']));
        expect(apiMap['capabilities'],
            equals([EvseCapabilities.remoteStartStopCapable]));
      });

      test(
          'should still apply workaround when only excludeOperators is selected',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          capabilities: [EvseCapabilities.remoteStartStopCapable],
          excludeOperators: ['Tesla'],
        );
        final apiMap = filters.apiMapWithWorkarounds;

        expect(apiMap['restrictToProvider'], isTrue);
        expect(apiMap['excludeOperators'], equals(['Tesla']));
      });

      test(
          'should not apply workaround when capabilities does not contain REMOTE_START_STOP_CAPABLE',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: false,
          capabilities: ['OTHER_CAPABILITY'],
        );
        final apiMap = filters.apiMapWithWorkarounds;

        // restrictToProvider should not be set by workaround
        expect(apiMap.containsKey('restrictToProvider'), isFalse);
      });
    });

    group('SharedPreferences Integration', () {
      test('loadFromSharedPrefs should load supportsRemoteCharge', () {
        when(mockPrefs.getBool(ChargingLocationFilters.isAvailableKey))
            .thenReturn(false);
        when(mockPrefs.getBool(ChargingLocationFilters.isDcChargerKey))
            .thenReturn(false);
        when(mockPrefs.getBool(ChargingLocationFilters.appNameBrandedChargerKey))
            .thenReturn(null);
        when(mockPrefs.getBool(ChargingLocationFilters.withoutAdditionalFeeKey))
            .thenReturn(false);
        when(mockPrefs.getBool(ChargingLocationFilters.supportsRemoteChargeKey))
            .thenReturn(true);
        when(mockPrefs.getInt(ChargingLocationFilters.minPowerLevelKey))
            .thenReturn(0);
        when(mockPrefs.getStringList(ChargingLocationFilters.connectorTypesKey))
            .thenReturn([]);
        when(mockPrefs.getStringList(ChargingLocationFilters.capabilitiesKey))
            .thenReturn([]);
        when(mockPrefs.getStringList(ChargingLocationFilters.includeOperatorsKey))
            .thenReturn([]);
        when(mockPrefs.getStringList(ChargingLocationFilters.excludeOperatorsKey))
            .thenReturn([]);

        final filters = ChargingLocationFilters.loadFromSharedPrefs();

        expect(filters.supportsRemoteCharge, isTrue);
      });

      test('loadFromSharedPrefs should default supportsRemoteCharge to false',
          () {
        when(mockPrefs.getBool(ChargingLocationFilters.isAvailableKey))
            .thenReturn(null);
        when(mockPrefs.getBool(ChargingLocationFilters.isDcChargerKey))
            .thenReturn(null);
        when(mockPrefs.getBool(ChargingLocationFilters.appNameBrandedChargerKey))
            .thenReturn(null);
        when(mockPrefs.getBool(ChargingLocationFilters.withoutAdditionalFeeKey))
            .thenReturn(null);
        when(mockPrefs.getBool(ChargingLocationFilters.supportsRemoteChargeKey))
            .thenReturn(null);
        when(mockPrefs.getInt(ChargingLocationFilters.minPowerLevelKey))
            .thenReturn(null);
        when(mockPrefs.getStringList(ChargingLocationFilters.connectorTypesKey))
            .thenReturn(null);
        when(mockPrefs.getStringList(ChargingLocationFilters.capabilitiesKey))
            .thenReturn(null);
        when(mockPrefs.getStringList(ChargingLocationFilters.includeOperatorsKey))
            .thenReturn(null);
        when(mockPrefs.getStringList(ChargingLocationFilters.excludeOperatorsKey))
            .thenReturn(null);

        final filters = ChargingLocationFilters.loadFromSharedPrefs();

        expect(filters.supportsRemoteCharge, isFalse);
      });

      test('saveToSharedPrefs should save supportsRemoteCharge', () {
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

        final filters = ChargingLocationFilters(supportsRemoteCharge: true);
        filters.saveToSharedPrefs();

        verify(mockPrefs.setBool(
                ChargingLocationFilters.supportsRemoteChargeKey, true))
            .called(1);
      });
    });

    group('remoteSessionEnabledPartyIds', () {
      test('default value should be [EFL]', () {
        final filters = ChargingLocationFilters();
        expect(filters.remoteSessionEnabledPartyIds, equals(['EFL']));
      });

      test('should be included in apiMap when supportsRemoteCharge is true',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: true,
          remoteSessionEnabledPartyIds: ['EFL', 'OPC', 'NXT'],
        );
        final apiMap = filters.apiMap;

        expect(apiMap['partyIds'], equals(['EFL', 'OPC', 'NXT']));
      });

      test('should support copyWith', () {
        final original = ChargingLocationFilters();
        final copied =
            original.copyWith(remoteSessionEnabledPartyIds: ['CUSTOM']);

        expect(copied.remoteSessionEnabledPartyIds, equals(['CUSTOM']));
      });
    });

    group('Operator Filters', () {
      test('apiMap should include includeOperators when non-empty', () {
        final filters = ChargingLocationFilters(
          includeOperators: ['Operator A', 'Operator B'],
        );
        final apiMap = filters.apiMap;

        expect(apiMap['includeOperators'], equals(['Operator A', 'Operator B']));
        expect(apiMap.containsKey('excludeOperators'), isFalse);
      });

      test('apiMap should include excludeOperators when non-empty', () {
        final filters = ChargingLocationFilters(
          excludeOperators: ['Bad Operator'],
        );
        final apiMap = filters.apiMap;

        expect(apiMap['excludeOperators'], equals(['Bad Operator']));
        expect(apiMap.containsKey('includeOperators'), isFalse);
      });

      test('apiMap should not include operator keys when empty', () {
        final filters = ChargingLocationFilters();
        final apiMap = filters.apiMap;

        expect(apiMap.containsKey('includeOperators'), isFalse);
        expect(apiMap.containsKey('excludeOperators'), isFalse);
      });

      test('activeFilterCount should count includeOperators as 1 filter', () {
        final filters = ChargingLocationFilters(
          includeOperators: ['Op A', 'Op B', 'Op C'],
        );

        expect(filters.activeFilterCount, equals(1));
      });

      test('activeFilterCount should count excludeOperators as 1 filter', () {
        final filters = ChargingLocationFilters(
          excludeOperators: ['Op A'],
        );

        expect(filters.activeFilterCount, equals(1));
      });

      test('activeFilterCount should count both operators lists as 1 filter total', () {
        // Defensive case: UI prevents this, but the model guard should handle it
        final filters = ChargingLocationFilters(
          includeOperators: ['Op A'],
          excludeOperators: ['Op B'],
        );

        expect(filters.activeFilterCount, equals(1));
      });

      test('copyWith should support includeOperators and excludeOperators', () {
        final original = ChargingLocationFilters();
        final copied = original.copyWith(
          includeOperators: ['Op A'],
          excludeOperators: ['Op B'],
        );

        expect(copied.includeOperators, equals(['Op A']));
        expect(copied.excludeOperators, equals(['Op B']));
      });

      test('loadFromSharedPrefs should load operator filters', () {
        when(mockPrefs.getBool(any)).thenReturn(null);
        when(mockPrefs.getInt(any)).thenReturn(null);
        when(mockPrefs.getStringList(any)).thenReturn(null);
        when(mockPrefs.getStringList(ChargingLocationFilters.includeOperatorsKey))
            .thenReturn(['Op A', 'Op B']);
        when(mockPrefs.getStringList(ChargingLocationFilters.excludeOperatorsKey))
            .thenReturn(['Op C']);

        final filters = ChargingLocationFilters.loadFromSharedPrefs();

        expect(filters.includeOperators, equals(['Op A', 'Op B']));
        expect(filters.excludeOperators, equals(['Op C']));
      });

      test('saveToSharedPrefs should save operator filters', () {
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

        final filters = ChargingLocationFilters(
          includeOperators: ['Op A'],
          excludeOperators: ['Op B'],
        );
        filters.saveToSharedPrefs();

        verify(mockPrefs.setStringList(
                ChargingLocationFilters.includeOperatorsKey, ['Op A']))
            .called(1);
        verify(mockPrefs.setStringList(
                ChargingLocationFilters.excludeOperatorsKey, ['Op B']))
            .called(1);
      });
    });

    group('Combined Filters', () {
      test('should build correct apiMap with all filters enabled', () {
        final filters = ChargingLocationFilters(
          isAvailable: true,
          isDcCharger: true,
          supportsRemoteCharge: true,
          withoutAdditionalFee: true,
          minPowerLevel: 6,
          connectorTypes: ['TYPE_2', 'CCS'],
          remoteSessionEnabledPartyIds: ['EFL', 'OPC'],
        );

        final apiMap = filters.apiMap;

        expect(apiMap['status'], equals(['AVAILABLE']));
        expect(apiMap['powerType'], equals('dc'));
        expect(apiMap['capabilities'],
            equals([EvseCapabilities.remoteStartStopCapable]));
        expect(apiMap['partyIds'], equals(['EFL', 'OPC']));
        expect(apiMap['restrictToProvider'], equals(F.restrictMapCallsToProvider));
        expect(apiMap['noAdditionalCharges'], isTrue);
        expect(apiMap['minPower'], equals(100)); // Index 6 = 100kW (powerLevelValues[6])
        expect(apiMap['connectorTypes'], equals(['TYPE_2', 'CCS']));
      });

      test(
          'should not include capabilities in apiMap when supportsRemoteCharge overrides them',
          () {
        final filters = ChargingLocationFilters(
          supportsRemoteCharge: true,
          capabilities: ['RFID_READER'], // This should be overridden
        );

        final apiMap = filters.apiMap;

        // capabilities should only contain REMOTE_START_STOP_CAPABLE from supportsRemoteCharge
        expect(apiMap['capabilities'],
            equals([EvseCapabilities.remoteStartStopCapable]));
        expect(apiMap['capabilities'].contains('RFID_READER'), isFalse);
      });
    });
  });
}
