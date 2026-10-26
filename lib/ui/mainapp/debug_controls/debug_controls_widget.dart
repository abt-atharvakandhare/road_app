import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/services/intercom/intercom_utils.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'car_play_debug_widget.dart';
import 'cubit/debug_controls_cubit.dart';

class DebugControlsWidget extends StatefulWidget {
  const DebugControlsWidget({super.key});

  @override
  State<DebugControlsWidget> createState() => _DebugControlsWidgetState();
}

class _DebugControlsWidgetState extends State<DebugControlsWidget> {
  final TextEditingController _bearingController = TextEditingController();
  final FocusNode _bearingFocusNode = FocusNode();
  bool _hasInitialized = false;

  @override
  void dispose() {
    _bearingController.dispose();
    _bearingFocusNode.dispose();
    super.dispose();
  }

  static String _bearingToDirection(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'N';
    if (bearing >= 22.5 && bearing < 67.5) return 'NE';
    if (bearing >= 67.5 && bearing < 112.5) return 'E';
    if (bearing >= 112.5 && bearing < 157.5) return 'SE';
    if (bearing >= 157.5 && bearing < 202.5) return 'S';
    if (bearing >= 202.5 && bearing < 247.5) return 'SW';
    if (bearing >= 247.5 && bearing < 292.5) return 'W';
    if (bearing >= 292.5 && bearing < 337.5) return 'NW';
    return 'N';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DebugControlsCubit, DebugControlsState>(
      listener: (context, state) {
        // Initialize the controller with the initial bearing value
        if (!_hasInitialized && state is DebugControlsEnabled) {
          _bearingController.text = state.gpsSimulationBearing.toStringAsFixed(1);
          _hasInitialized = true;
        }

        // Only update from state if the field doesn't have focus (user not editing)
        if (state is DebugControlsEnabled && !_bearingFocusNode.hasFocus) {
          final stateValue = state.gpsSimulationBearing.toStringAsFixed(1);
          final currentValue = double.tryParse(_bearingController.text);

          // Update if the numeric values don't match
          if (currentValue != state.gpsSimulationBearing) {
            _bearingController.text = stateValue;
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          DebugControlsDisabled() => const SizedBox(),
          DebugControlsEnabled() => _buildDebugControlsEnabled(context, state),
        };
      },
    );
  }

  Widget _buildDebugControlsEnabled(BuildContext context, DebugControlsEnabled state) {
    final stageTarget = state.stageTarget;
    final showAllStationsOnAllFlavors = state.showAllStationsOnAllFlavors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  getIt<Stage>().setTarget(StageTarget.production);
                  getIt<ApiService>().setStageTarget(StageTarget.production);
                  await IntercomUtils.reinitializeForEnvironment(true);

                  if (!context.mounted) {
                    return;
                  }
                  // Logout clears shared prefs, so do this first.
                  await BlocProvider.of<AuthCubit>(context).logout();
                  if (!context.mounted) {
                    return;
                  }

                  BlocProvider.of<DebugControlsCubit>(context).setDebugControlsEnabled(false);
                },
                child: const Text('Disable debug controls'),
              ),
              Text('Using: ${getIt<ApiService>().baseUrl}', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Text('Environment', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              SegmentedButton<StageTarget>(
                segments: [
                  ButtonSegment<StageTarget>(
                    value: StageTarget.localdev,
                    label: Text('LocalDev', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12)),
                  ),
                  ButtonSegment<StageTarget>(
                    value: StageTarget.staging,
                    label: Text('Staging', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12)),
                  ),
                  ButtonSegment<StageTarget>(
                    value: StageTarget.production,
                    label: Text('Production', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12)),
                  ),
                ],
                selected: {stageTarget},
                onSelectionChanged: (Set<StageTarget> newSelection) async {
                  final target = newSelection.first;
                  getIt<Stage>().setTarget(target);
                  getIt<ApiService>().setStageTarget(target);
                  await IntercomUtils.reinitializeForEnvironment(target == StageTarget.production);
                  await getIt<MixpanelService>().reinitialize(getIt<Stage>());

                  // Logout clears shared prefs, so do this first.
                  if (!context.mounted) {
                    return;
                  }
                  await BlocProvider.of<AuthCubit>(context).logout();
                  if (!context.mounted) {
                    return;
                  }

                  BlocProvider.of<DebugControlsCubit>(context).setStageTarget(target);
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Show all stations on all WL apps', style: Theme.of(context).textTheme.labelMedium),
                  const Spacer(),
                  Switch.adaptive(
                    activeThumbColor: RMColors.rmPrimaryColor,
                    value: showAllStationsOnAllFlavors,
                    onChanged: (value) {
                      BlocProvider.of<DebugControlsCubit>(context).setShowAllStationsOnAllFlavors(value);
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  BlocProvider.of<AuthCubit>(context).invalidateAuthToken();
                },
                child: const Text('Invalidate JWT token'),
              ),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<AuthCubit>(context).forceSessionRenewal();
                },
                child: const Text('Force session renewal (Face ID test)'),
              ),
              const SizedBox(height: 16),
              const CarPlayDebugWidget(),
              const SizedBox(height: 16),
              _buildGpsSimulationSection(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGpsSimulationSection(BuildContext context, DebugControlsEnabled state) {
    final locationState = context.watch<LocationBloc>().state;
    final hasDebugLocation = locationState is LocationProvided;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Text('GPS Simulation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!hasDebugLocation) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Text(
              'Set a debug location first to enable GPS simulation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          if (state.isGpsSimulating) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.satellite_alt, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'SIMULATING',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (state.currentSimulatedLat != null && state.currentSimulatedLng != null)
                    Text(
                      '${state.currentSimulatedLat!.toStringAsFixed(6)}, ${state.currentSimulatedLng!.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 10),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Text('Speed: ${state.gpsSimulationSpeed.toInt()} km/h', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: state.gpsSimulationSpeed,
                  min: 0,
                  max: 200,
                  divisions: 40,
                  label: '${state.gpsSimulationSpeed.toInt()} km/h',
                  onChanged: (value) {
                    BlocProvider.of<DebugControlsCubit>(context).setGpsSimulationSpeed(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Bearing (°):', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _bearingController,
                  focusNode: _bearingFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: '0.0 - 359.9',
                    suffixText: '°',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) {
                    final bearing = double.tryParse(value);
                    if (bearing != null && bearing >= 0 && bearing <= 359.9) {
                      BlocProvider.of<DebugControlsCubit>(context).setGpsSimulationBearing(bearing);
                    }
                  },
                  onFieldSubmitted: (value) {
                    final bearing = double.tryParse(value);
                    if (bearing != null && bearing >= 0 && bearing <= 359.9) {
                      BlocProvider.of<DebugControlsCubit>(context).setGpsSimulationBearing(bearing);
                    }
                    _bearingFocusNode.unfocus();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.gpsSimulationBearing.toStringAsFixed(1)}°',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              if (state.isGpsSimulating) {
                BlocProvider.of<DebugControlsCubit>(context).stopGpsSimulation();
              } else {
                BlocProvider.of<DebugControlsCubit>(context).startGpsSimulation();
              }
            },
            icon: Icon(state.isGpsSimulating ? Icons.stop : Icons.play_arrow, color: Colors.white),
            label: Text(
              state.isGpsSimulating ? 'Stop Simulation' : 'Start Simulation',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isGpsSimulating ? Colors.red : RMColors.rmPrimaryColor,
            ),
          ),
          if (state.isGpsSimulating) ...[
            const SizedBox(height: 8),
            Text(
              'Moving ${_bearingToDirection(state.gpsSimulationBearing)} (${state.gpsSimulationBearing.toStringAsFixed(1)}°) at ${(state.gpsSimulationSpeed / 3.6).toStringAsFixed(1)} m/s',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }
}
