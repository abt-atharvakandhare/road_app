import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class DebugControlsRepo {
  // Prefixed with `persist:` so these device-scoped debug toggles survive logout.
  // See [PersistentPrefs] for the convention.
  //
  // The first two are public (not private) because the e2e suite seeds them
  // directly before `app.main()` runs (integration_test/_helpers/reset.dart) —
  // importing them keeps a rename from silently breaking the tests.
  static const debugControlsEnabledKey = 'persist:debug_controls_enabled';
  static const debugStageTargetKey = 'persist:debug_stage_target';
  static const debugProviderSlugKey = 'persist:debug_provider_slug';
  static const _showAllStationsOnAllFlavorsKey = 'persist:debug_show_all_stations_on_all_flavors';

  final SharedPreferences _sharedPreferences;

  bool _areDebugControlsEnabled;
  bool get areDebugControlsEnabled => _areDebugControlsEnabled;

  StageTarget _stageTarget;
  StageTarget get stageTarget => _areDebugControlsEnabled ? _stageTarget : StageTarget.production;

  /// Provider slug used instead of the flavor's own for the public-provider
  /// lookup. Staging only hosts a subset of the white-label provider slugs, so
  /// multi-flavor staging runs set this to a slug that exists there (`e-flux`).
  String? _providerSlugOverride;
  String? get providerSlugOverride => _areDebugControlsEnabled ? _providerSlugOverride : null;

  bool _showAllStationsOnAllAllFlavors;
  bool get showAllStationsOnAllFlavors => _areDebugControlsEnabled && _showAllStationsOnAllAllFlavors;

  DebugControlsRepo(SharedPreferences sharedPrefs)
      : _sharedPreferences = sharedPrefs,
        _areDebugControlsEnabled = sharedPrefs.getBool(debugControlsEnabledKey) ?? false,
        _stageTarget = _loadStageTarget(sharedPrefs),
        _providerSlugOverride = sharedPrefs.getString(debugProviderSlugKey),
        _showAllStationsOnAllAllFlavors = sharedPrefs.getBool(_showAllStationsOnAllFlavorsKey) ?? false;

  static StageTarget _loadStageTarget(SharedPreferences prefs) {
    final stageTargetString = prefs.getString(debugStageTargetKey);
    if (stageTargetString != null) {
      return StageTarget.values.firstWhere(
        (e) => e.name == stageTargetString,
        orElse: () => StageTarget.production,
      );
    }
    return StageTarget.production;
  }

  void save() {
    _sharedPreferences.setBool(debugControlsEnabledKey, _areDebugControlsEnabled);
    _sharedPreferences.setString(debugStageTargetKey, _stageTarget.name);
    final providerSlugOverride = _providerSlugOverride;
    if (providerSlugOverride != null) {
      _sharedPreferences.setString(debugProviderSlugKey, providerSlugOverride);
    } else {
      _sharedPreferences.remove(debugProviderSlugKey);
    }
    _sharedPreferences.setBool(_showAllStationsOnAllFlavorsKey, _showAllStationsOnAllAllFlavors);
  }

  void setDebugControlsEnabled(bool enabled) {
    _areDebugControlsEnabled = enabled;
    if (!enabled) {
      _stageTarget = StageTarget.production;
      _providerSlugOverride = null;
      _showAllStationsOnAllAllFlavors = false;
    }

    save();
  }

  void setProviderSlugOverride(String? slug) {
    _providerSlugOverride = slug;
    save();
  }

  void setStageTarget(StageTarget target) {
    _stageTarget = target;
    save();
  }

  void setShowAllStationsOnAllFlavors(bool enabled) {
    _showAllStationsOnAllAllFlavors = enabled;
    save();
  }
}
