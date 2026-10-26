part of 'debug_controls_cubit.dart';

@freezed
sealed class DebugControlsState with _$DebugControlsState {
  const factory DebugControlsState.disabled() = DebugControlsDisabled;
  const factory DebugControlsState.enabled(
    StageTarget stageTarget,
    bool showAllStationsOnAllFlavors, {
    @Default(false) bool isGpsSimulating,
    @Default(100.0) double gpsSimulationSpeed,
    @Default(0.0) double gpsSimulationBearing,
    double? currentSimulatedLat,
    double? currentSimulatedLng,
  }) = DebugControlsEnabled;
}

extension DebugControlsStateX on DebugControlsState {
  bool get areDebugControlsEnabled => this is DebugControlsEnabled;
}
