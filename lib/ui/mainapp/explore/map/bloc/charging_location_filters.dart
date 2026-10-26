import 'package:road_mobile/data/evse_capabilties.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChargingLocationFilters {
  ChargingLocationFilters({
    this.isAvailable = false,
    this.isDcCharger = false,
    bool? appNameBrandedCharger,
    this.withoutAdditionalFee = false,
    this.supportsRemoteCharge = false,
    this.minPowerLevel = 0,
    this.connectorTypes = const <String>[],
    this.capabilities = const <String>[],
    this.remoteSessionEnabledPartyIds = const <String>['EFL'],
    this.includeOperators = const <String>[],
    this.excludeOperators = const <String>[],
  }) : appNameBrandedCharger = appNameBrandedCharger ?? defaultBrandSwitchState;

  bool isAvailable;
  bool isDcCharger;
  bool appNameBrandedCharger;
  bool withoutAdditionalFee;
  bool supportsRemoteCharge;
  int minPowerLevel;
  List<String> connectorTypes;
  List<String> capabilities;
  List<String> remoteSessionEnabledPartyIds;
  // Network operator filters — only used by the map filter screen.
  // Highway mode (CarPlay/Android Auto) uses NearestStationsCubit with its own
  // filter logic and is intentionally unaffected by these operator filters.
  List<String> includeOperators;
  List<String> excludeOperators;

  static const List<String> powerLevels = ['3', '7', '11', '22', '43', '50', '100', '150', '200', '250+'];
  static const List<int> _powerLevelValues = [3, 7, 11, 22, 43, 50, 100, 150, 200, 250];

  static bool get defaultBrandSwitchState {
    return F.mapBrandFilterType == MapBrandFilterType.showBrandFilterToAll;
  }

  ChargingLocationFilters copyWith({
    bool? isAvailable,
    bool? isDcCharger,
    bool? appNameBrandedCharger,
    bool? withoutAdditionalFee,
    bool? supportsRemoteCharge,
    int? minPowerLevel,
    List<String>? connectorTypes,
    List<String>? capabilities,
    List<String>? remoteSessionEnabledPartyIds,
    List<String>? includeOperators,
    List<String>? excludeOperators,
  }) {
    return ChargingLocationFilters(
      isAvailable: isAvailable ?? this.isAvailable,
      isDcCharger: isDcCharger ?? this.isDcCharger,
      appNameBrandedCharger: appNameBrandedCharger ?? this.appNameBrandedCharger,
      withoutAdditionalFee: withoutAdditionalFee ?? this.withoutAdditionalFee,
      supportsRemoteCharge: supportsRemoteCharge ?? this.supportsRemoteCharge,
      minPowerLevel: minPowerLevel ?? this.minPowerLevel,
      connectorTypes: connectorTypes ?? this.connectorTypes,
      capabilities: capabilities ?? this.capabilities,
      remoteSessionEnabledPartyIds: remoteSessionEnabledPartyIds ?? this.remoteSessionEnabledPartyIds,
      includeOperators: includeOperators ?? this.includeOperators,
      excludeOperators: excludeOperators ?? this.excludeOperators,
    );
  }

  static const isAvailableKey = 'MapFiltersIsAvailable';
  static const isDcChargerKey = 'MapFiltersIsDcCharger';
  static const appNameBrandedChargerKey = 'MapFiltersAppNameBrandedCharger';
  static const withoutAdditionalFeeKey = 'MapFiltersWithoutAdditionalFee';
  static const supportsRemoteChargeKey = 'MapFiltersSupportsRemoteCharge';
  static const minPowerLevelKey = 'MapFiltersMinPowerLevel';
  static const connectorTypesKey = 'MapFiltersConnectorTypes';
  static const capabilitiesKey = 'MapFiltersCapabilities';
  static const includeOperatorsKey = 'MapFiltersIncludeOperators';
  static const excludeOperatorsKey = 'MapFiltersExcludeOperators';

  static ChargingLocationFilters loadFromSharedPrefs() {
    final prefs = getIt<SharedPreferences>();
    return ChargingLocationFilters(
      isAvailable: prefs.getBool(isAvailableKey) ?? false,
      isDcCharger: prefs.getBool(isDcChargerKey) ?? false,
      appNameBrandedCharger: prefs.getBool(appNameBrandedChargerKey) ?? defaultBrandSwitchState,
      withoutAdditionalFee: prefs.getBool(withoutAdditionalFeeKey) ?? false,
      supportsRemoteCharge: prefs.getBool(supportsRemoteChargeKey) ?? false,
      minPowerLevel: prefs.getInt(minPowerLevelKey) ?? 0,
      connectorTypes: prefs.getStringList(connectorTypesKey) ?? [],
      capabilities: prefs.getStringList(capabilitiesKey) ?? [],
      includeOperators: prefs.getStringList(includeOperatorsKey) ?? [],
      excludeOperators: prefs.getStringList(excludeOperatorsKey) ?? [],
    );
  }

  void saveToSharedPrefs() {
    final prefs = getIt<SharedPreferences>();
    prefs.setBool(isAvailableKey, isAvailable);
    prefs.setBool(isDcChargerKey, isDcCharger);
    prefs.setBool(appNameBrandedChargerKey, appNameBrandedCharger);
    prefs.setBool(withoutAdditionalFeeKey, withoutAdditionalFee);
    prefs.setBool(supportsRemoteChargeKey, supportsRemoteCharge);
    prefs.setInt(minPowerLevelKey, minPowerLevel);
    prefs.setStringList(connectorTypesKey, connectorTypes);
    prefs.setStringList(capabilitiesKey, capabilities);
    prefs.setStringList(includeOperatorsKey, includeOperators);
    prefs.setStringList(excludeOperatorsKey, excludeOperators);
  }

  int get activeFilterCount {
    var filtersCount = apiMap.length;

    // supportsRemoteCharge adds 3 items to apiMap but should count as 1 filter
    if (supportsRemoteCharge) {
      filtersCount -= 2;
    }

    // The UI enforces mutual exclusivity (only include OR exclude can be active),
    // so at most one of these will be non-empty, each adding 1 key to apiMap = 1 filter.
    // The && guard below is defensive: if both were somehow set, they'd add 2 keys
    // but should still count as 1 filter, so subtract 1.
    if (includeOperators.isNotEmpty && excludeOperators.isNotEmpty) {
      filtersCount -= 1;
    }

    if (F.mapBrandFilterType == MapBrandFilterType.showBrandOnly) {
      if (!getIt<DebugControlsRepo>().showAllStationsOnAllFlavors) {
        assert(filtersCount >= 1);
        return filtersCount - 1;
      }
    }

    return filtersCount;
  }

  Map get apiMap {
    var data = {};
    if (isAvailable) {
      data['status'] = ['AVAILABLE'];
    }

    if (isDcCharger) {
      data['powerType'] = 'dc';
    }

    // supportsRemoteCharge takes priority and sets its own restrictToProvider/partyIds
    if (supportsRemoteCharge) {
      data['capabilities'] = [EvseCapabilities.remoteStartStopCapable];
      data['partyIds'] = remoteSessionEnabledPartyIds;
      data['restrictToProvider'] = F.restrictMapCallsToProvider;
    } else {
      if (appNameBrandedCharger || F.mapBrandFilterType == MapBrandFilterType.showBrandOnly) {
        if (!getIt<DebugControlsRepo>().showAllStationsOnAllFlavors) {
          data['restrictToProvider'] = true;
        }
      }

      if (capabilities.isNotEmpty) {
        data['capabilities'] = capabilities;
      }
    }

    if (withoutAdditionalFee) {
      data['noAdditionalCharges'] = true;
    }

    if (minPowerLevel > 0) {
      data['minPower'] = _powerLevelValues[minPowerLevel];
    }

    if (connectorTypes.isNotEmpty) {
      data['connectorTypes'] = connectorTypes;
    }

    // Note: includeOperators and excludeOperators are mutually exclusive — the UI
    // only allows one to be active at a time. The API supports both simultaneously
    // but the intent is always one or the other.
    if (includeOperators.isNotEmpty) {
      data['includeOperators'] = includeOperators;
    }

    if (excludeOperators.isNotEmpty) {
      data['excludeOperators'] = excludeOperators;
    }

    return data;
  }

  /// Returns the API map with workarounds applied for certain filter combinations.
  /// Currently applies the directPayments workaround: when REMOTE_START_STOP_CAPABLE
  /// is enabled, we also need to set restrictToProvider to true.
  /// This is because we can only be certain that E-Flux chargers actually update their
  /// status over the roaming network fast enough to be useful.
  /// Note: When supportsRemoteCharge is enabled, it handles its own restrictToProvider
  /// setting, so the workaround is skipped. It is also skipped when the user has an
  /// explicit include-operator selection, because the API replaces includeOperators
  /// with the provider's operator list when restrictToProvider is true. An
  /// excludeOperators selection does not skip it: excluding only narrows the results,
  /// so it composes safely with restrictToProvider.
  Map get apiMapWithWorkarounds {
    var data = apiMap;

    // Skip workaround when supportsRemoteCharge is enabled as it sets its own restrictToProvider
    if (!supportsRemoteCharge &&
        includeOperators.isEmpty &&
        capabilities.contains(EvseCapabilities.remoteStartStopCapable)) {
      data['restrictToProvider'] = true;
    }

    return data;
  }
}
