import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/gps_simulation_service.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';

part 'debug_controls_state.dart';
part 'debug_controls_cubit.freezed.dart';

@lazySingleton
class DebugControlsCubit extends Cubit<DebugControlsState> {
  final DebugControlsRepo _debugControlsRepo;
  final GpsSimulationService _gpsSimulationService;
  final LocationBloc _locationBloc;
  StreamSubscription<UserLocation>? _simulationSubscription;

  DebugControlsCubit(
    DebugControlsRepo debugControlsRepo,
    GpsSimulationService gpsSimulationService,
    LocationBloc locationBloc,
  ) : _debugControlsRepo = debugControlsRepo,
      _gpsSimulationService = gpsSimulationService,
      _locationBloc = locationBloc,
      super(
        debugControlsRepo.areDebugControlsEnabled
            ? DebugControlsState.enabled(debugControlsRepo.stageTarget, debugControlsRepo.showAllStationsOnAllFlavors)
            : const DebugControlsState.disabled(),
      );

  @override
  Future<void> close() {
    _simulationSubscription?.cancel();
    _gpsSimulationService.dispose();
    return super.close();
  }

  void setDebugControlsEnabled(bool enabled) {
    _debugControlsRepo.setDebugControlsEnabled(enabled);
    if (!enabled) {
      stopGpsSimulation();
    }
    emit(
      enabled
          ? DebugControlsState.enabled(_debugControlsRepo.stageTarget, _debugControlsRepo.showAllStationsOnAllFlavors)
          : const DebugControlsState.disabled(),
    );
  }

  void setStageTarget(StageTarget target) {
    _debugControlsRepo.setStageTarget(target);
    final currentState = state;
    if (currentState is! DebugControlsEnabled) return;

    emit(
      currentState.copyWith(
        stageTarget: _debugControlsRepo.stageTarget,
        showAllStationsOnAllFlavors: _debugControlsRepo.showAllStationsOnAllFlavors,
      ),
    );
  }

  void setShowAllStationsOnAllFlavors(bool enabled) {
    _debugControlsRepo.setShowAllStationsOnAllFlavors(enabled);
    final currentState = state;
    if (currentState is! DebugControlsEnabled) return;

    emit(
      currentState.copyWith(
        stageTarget: _debugControlsRepo.stageTarget,
        showAllStationsOnAllFlavors: _debugControlsRepo.showAllStationsOnAllFlavors,
      ),
    );
  }

  void startGpsSimulation() {
    final currentState = state;
    if (currentState is! DebugControlsEnabled) return;

    // Get current debug location from LocationBloc
    final locationState = _locationBloc.state;
    if (locationState is! LocationProvided) {
      // User needs to set a debug location first
      return;
    }

    final userLocation = locationState.userLocation;

    // Cancel any existing subscription
    _simulationSubscription?.cancel();

    // Start the simulation
    _gpsSimulationService.startSimulation(
      startLatitude: userLocation.latitude,
      startLongitude: userLocation.longitude,
      speedKmh: currentState.gpsSimulationSpeed,
      bearing: currentState.gpsSimulationBearing,
    );

    // Subscribe to simulation updates
    _simulationSubscription = _gpsSimulationService.locationStream.listen((location) {
      // Update LocationBloc with simulated location
      _locationBloc.add(LocationEvent.useDebugLocation(location));

      // Update state with current simulated location
      final state = this.state;
      if (state is DebugControlsEnabled) {
        emit(state.copyWith(currentSimulatedLat: location.latitude, currentSimulatedLng: location.longitude));
      }
    });

    // Update state to show simulation is active
    emit(
      currentState.copyWith(
        isGpsSimulating: true,
        currentSimulatedLat: userLocation.latitude,
        currentSimulatedLng: userLocation.longitude,
      ),
    );
  }

  void stopGpsSimulation() {
    _simulationSubscription?.cancel();
    _simulationSubscription = null;
    _gpsSimulationService.stopSimulation();

    final currentState = state;
    if (currentState is! DebugControlsEnabled) return;

    // Emit a location with speed 0 to indicate the user has stopped
    if (currentState.currentSimulatedLat != null && currentState.currentSimulatedLng != null) {
      _locationBloc.add(
        LocationEvent.useDebugLocation(
          UserLocation(
            latitude: currentState.currentSimulatedLat!,
            longitude: currentState.currentSimulatedLng!,
            accuracy: 10.0,
            speed: 0.0,
            heading: null,
          ),
        ),
      );
    }

    emit(currentState.copyWith(isGpsSimulating: false, currentSimulatedLat: null, currentSimulatedLng: null));
  }

  void setGpsSimulationSpeed(double speedKmh) {
    final currentState = state;
    if (currentState is! DebugControlsEnabled) return;

    emit(currentState.copyWith(gpsSimulationSpeed: speedKmh));

    // Update the service if currently simulating
    if (currentState.isGpsSimulating) {
      _gpsSimulationService.updateSpeed(speedKmh);
    }
  }

  void setGpsSimulationBearing(double bearing) {
    final currentState = state;
    if (currentState is! DebugControlsEnabled) return;

    // Clamp bearing to 0-359.9 range
    final clampedBearing = bearing.clamp(0.0, 359.9);

    emit(currentState.copyWith(gpsSimulationBearing: clampedBearing));

    // Update the service if currently simulating
    if (currentState.isGpsSimulating) {
      _gpsSimulationService.updateBearing(clampedBearing);
    }
  }
}
