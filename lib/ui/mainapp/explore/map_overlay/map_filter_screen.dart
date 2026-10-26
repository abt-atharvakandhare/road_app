import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/charging_connector_types.dart';
import 'package:road_mobile/data/evse_capabilties.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/charging_location_filters.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/network_search_bottom_sheet.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

class MapFilterScreen extends StatefulWidget {
  static void pushAsModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((routeContext) {
          return MultiBlocProvider(
            providers: [BlocProvider.value(value: BlocProvider.of<MapBloc>(context))],
            child: MapFilterScreen(BlocProvider.of<MapBloc>(context).mapFilters),
          );
        }),
        fullscreenDialog: true,
      ),
    );
  }

  const MapFilterScreen(this.filters, {super.key});

  final ChargingLocationFilters filters;

  @override
  State<StatefulWidget> createState() => _MapFilterScreenState();
}

enum _NetworkFilterMode { off, include, exclude }

class _MapFilterScreenState extends State<MapFilterScreen> {
  late ChargingLocationFilters filters;
  List<String> _allOperators = [];
  bool _operatorsLoading = false;
  late _NetworkFilterMode _networkFilterMode;

  @override
  void initState() {
    super.initState();
    filters = widget.filters.copyWith();
    // Derive initial mode from persisted filter state, and clear the
    // opposite list defensively (guards against storage corruption where
    // both lists are non-empty).
    if (filters.excludeOperators.isNotEmpty) {
      _networkFilterMode = _NetworkFilterMode.exclude;
      filters = filters.copyWith(includeOperators: []);
    } else if (filters.includeOperators.isNotEmpty) {
      _networkFilterMode = _NetworkFilterMode.include;
      filters = filters.copyWith(excludeOperators: []);
    } else {
      _networkFilterMode = _NetworkFilterMode.off;
    }
    _loadOperators();
  }

  void _updateFilters(ChargingLocationFilters newFilters) {
    setState(() => filters = newFilters);
    BlocProvider.of<MapBloc>(context).add(MapEvent.mapFiltersChanged(newFilters));
  }

  void _applyFilters() {
    final partyIds = BlocProvider.of<AuthCubit>(context).state.remoteSessionEnabledPartyIds;
    final updatedFilters = filters.copyWith(remoteSessionEnabledPartyIds: partyIds);
    BlocProvider.of<MapBloc>(context).add(MapEvent.mapFiltersApplied(updatedFilters));
  }

  Future<void> _loadOperators() async {
    if (_operatorsLoading) return;
    setState(() => _operatorsLoading = true);
    final operators = await BlocProvider.of<MapBloc>(context).getOperators();
    if (mounted) {
      setState(() {
        _allOperators = operators;
        _operatorsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _applyFilters();
      },
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.filters, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.onlyShow, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.availableChargers,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Switch.adaptive(
                        activeThumbColor: RMColors.rmPrimaryColor,
                        value: filters.isAvailable,
                        onChanged: (value) {
                          _updateFilters(filters.copyWith(isAvailable: value));
                        },
                      ),
                    ],
                  ),
                  const RMSeparator(),
                  Row(
                    children: [
                      Expanded(child: Text(AppLocalizations.of(context)!.dCChargers, style: Theme.of(context).textTheme.labelMedium)),
                      Switch.adaptive(
                        activeThumbColor: RMColors.rmPrimaryColor,
                        value: filters.isDcCharger,
                        onChanged: (value) {
                          _updateFilters(filters.copyWith(isDcCharger: value));
                        },
                      ),
                    ],
                  ),
                  const RMSeparator(),
                  if (F.mapBrandFilterType != MapBrandFilterType.showBrandOnly) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.brandnameChargers.replaceAll('--brandname--', F.appBrandName),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        Switch.adaptive(
                          activeThumbColor: RMColors.rmPrimaryColor,
                          value: filters.appNameBrandedCharger,
                          onChanged: (value) {
                            _updateFilters(filters.copyWith(appNameBrandedCharger: value));
                          },
                        ),
                      ],
                    ),
                    const RMSeparator(),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.supportsRemoteCharge,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Switch.adaptive(
                        activeThumbColor: RMColors.rmPrimaryColor,
                        value: filters.supportsRemoteCharge,
                        onChanged: (value) {
                          _updateFilters(filters.copyWith(supportsRemoteCharge: value));
                        },
                      ),
                    ],
                  ),
                  const RMSeparator(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.withoutAdditionalFeePerSession,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Switch.adaptive(
                        activeThumbColor: RMColors.rmPrimaryColor,
                        value: filters.withoutAdditionalFee,
                        onChanged: (value) {
                          _updateFilters(filters.copyWith(withoutAdditionalFee: value));
                        },
                      ),
                    ],
                  ),
                  const RMSeparator(),
                  const SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.chargingPowerkW, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
            _ChargingPowerSlider(
              powerLevels: ChargingLocationFilters.powerLevels,
              value: filters.minPowerLevel.toDouble(),
              onChanged: (value) {
                _updateFilters(filters.copyWith(minPowerLevel: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildNetworkFilters(),
                  Text(AppLocalizations.of(context)!.connectorType, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 20),
                  _buildConnectorTypes(),
                  const SizedBox(height: 20),
                  _buildPaymentMethodFilters(),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        // Preserve remoteSessionEnabledPartyIds when clearing filters
                        _networkFilterMode = _NetworkFilterMode.off;
                        _updateFilters(ChargingLocationFilters(
                          remoteSessionEnabledPartyIds: filters.remoteSessionEnabledPartyIds,
                        ));
                      },
                      child: Text(AppLocalizations.of(context)!.clearFilters),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildConnectorTypes() {
    List<Widget> uiItems = [];
    for (final connectorId in ChargingConnectorTypes.connectorIds) {
      final isSelected = filters.connectorTypes.contains(connectorId);
      uiItems.add(
        InkWell(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SvgPicture.asset(ChargingConnectorTypes.svgAssetPathFor(connectorId)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ChargingConnectorTypes.humanReadableNameFor(connectorId),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    SvgPicture.asset(
                      isSelected
                          ? 'assets/icons/multi_select_selected.svg'
                          : 'assets/icons/multi_select_unselected.svg',
                      colorFilter: ColorFilter.mode(
                        isSelected ? RMColors.rmPrimaryColor : RMColors.sliderGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
              const RMSeparator(),
            ],
          ),
          onTap: () {
            var newConnectorTypes = List<String>.from(filters.connectorTypes);
            if (isSelected) {
              newConnectorTypes.remove(connectorId);
            } else {
              newConnectorTypes.add(connectorId);
            }
            _updateFilters(filters.copyWith(connectorTypes: newConnectorTypes));
          },
        ),
      );
    }

    return Column(children: uiItems);
  }

  List<String> get _activeNetworkList => switch (_networkFilterMode) {
    _NetworkFilterMode.include => filters.includeOperators,
    _NetworkFilterMode.exclude => filters.excludeOperators,
    _NetworkFilterMode.off => [],
  };

  void _setActiveNetworkList(List<String> networks) {
    if (_networkFilterMode == _NetworkFilterMode.off) return;
    if (_networkFilterMode == _NetworkFilterMode.exclude) {
      _updateFilters(filters.copyWith(excludeOperators: networks, includeOperators: []));
    } else {
      _updateFilters(filters.copyWith(includeOperators: networks, excludeOperators: []));
    }
  }

  Widget _buildNetworkFilters() {
    final l10n = AppLocalizations.of(context)!;
    final isIncludeActive = _networkFilterMode == _NetworkFilterMode.include;
    final isExcludeActive = _networkFilterMode == _NetworkFilterMode.exclude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Select Networks" toggle
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.selectNetworks,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isExcludeActive ? Colors.grey : null),
              ),
            ),
            Switch.adaptive(
              activeThumbColor: RMColors.rmPrimaryColor,
              value: isIncludeActive,
              onChanged: isExcludeActive
                  ? null // disabled when exclude is active
                  : (value) {
                      if (value) {
                        setState(() {
                          _networkFilterMode = _NetworkFilterMode.include;
                          if (_allOperators.isEmpty) _loadOperators();
                        });
                      } else {
                        _networkFilterMode = _NetworkFilterMode.off;
                        _updateFilters(filters.copyWith(includeOperators: []));
                      }
                    },
            ),
          ],
        ),
        // Include selection panel (shown directly under its toggle)
        if (isIncludeActive) ...[const RMSeparator(), _buildNetworkSelectionPanel()],
        const RMSeparator(),
        // "Exclude Networks" toggle
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.excludeNetworks,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isIncludeActive ? Colors.grey : null),
              ),
            ),
            Switch.adaptive(
              activeThumbColor: RMColors.rmPrimaryColor,
              value: isExcludeActive,
              onChanged: isIncludeActive
                  ? null // disabled when include is active
                  : (value) {
                      if (value) {
                        setState(() {
                          _networkFilterMode = _NetworkFilterMode.exclude;
                          if (_allOperators.isEmpty) _loadOperators();
                        });
                      } else {
                        _networkFilterMode = _NetworkFilterMode.off;
                        _updateFilters(filters.copyWith(excludeOperators: []));
                      }
                    },
            ),
          ],
        ),
        // Exclude selection panel (shown directly under its toggle)
        if (isExcludeActive) ...[const RMSeparator(), _buildNetworkSelectionPanel()],
        const RMSeparator(),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _openNetworkSearch() async {
    if (_allOperators.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final isExclude = _networkFilterMode == _NetworkFilterMode.exclude;
    final selectedNetworks = _activeNetworkList;
    final result = await NetworkSearchBottomSheet.show(
      context,
      allOperators: _allOperators,
      selectedOperators: selectedNetworks,
      title: isExclude ? l10n.selectNetworksToExclude : l10n.selectNetworksToInclude,
    );
    if (result != null) {
      _setActiveNetworkList(result);
    }
  }

  Widget _buildNetworkSelectionPanel() {
    final l10n = AppLocalizations.of(context)!;
    final selectedNetworks = _activeNetworkList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected networks with X to remove
        ...selectedNetworks.map(
          (network) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text(network, style: Theme.of(context).textTheme.labelMedium)),
                InkWell(
                  onTap: () {
                    final updated = List<String>.from(selectedNetworks)..remove(network);
                    _setActiveNetworkList(updated);
                  },
                  child: const Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        // "+ Add a network" button
        InkWell(
          onTap: !_operatorsLoading && _allOperators.isNotEmpty ? _openNetworkSearch : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: _operatorsLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _allOperators.isEmpty ? l10n.couldNotLoadNetworks : l10n.addANetwork,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _allOperators.isNotEmpty ? RMColors.rmPrimaryColor : Colors.grey,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapabilitiesFilters() {
    final isDirectPaymentSelected = filters.capabilities.contains(EvseCapabilities.remoteStartStopCapable);
    final isChargingCardSelected = filters.capabilities.contains(EvseCapabilities.rfidReader);

    return Column(
      children: [
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/credit_card_medium.svg', width: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(AppLocalizations.of(context)!.directPayments, style: Theme.of(context).textTheme.labelMedium)),
                SvgPicture.asset(
                  isDirectPaymentSelected
                      ? 'assets/icons/multi_select_selected.svg'
                      : 'assets/icons/multi_select_unselected.svg',
                  colorFilter: ColorFilter.mode(
                    isDirectPaymentSelected ? RMColors.rmPrimaryColor : RMColors.sliderGrey,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            var newCapabilities = List<String>.from(filters.capabilities);
            if (isDirectPaymentSelected) {
              newCapabilities.remove(EvseCapabilities.remoteStartStopCapable);
            } else {
              newCapabilities.add(EvseCapabilities.remoteStartStopCapable);
            }
            _updateFilters(filters.copyWith(capabilities: newCapabilities));
          },
        ),
        const RMSeparator(),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/card_tag.svg', width: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(AppLocalizations.of(context)!.chargingCardOrTag, style: Theme.of(context).textTheme.labelMedium)),
                SvgPicture.asset(
                  isChargingCardSelected
                      ? 'assets/icons/multi_select_selected.svg'
                      : 'assets/icons/multi_select_unselected.svg',
                  colorFilter: ColorFilter.mode(
                    isChargingCardSelected ? RMColors.rmPrimaryColor : RMColors.sliderGrey,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            var newCapabilities = List<String>.from(filters.capabilities);
            if (isChargingCardSelected) {
              newCapabilities.remove(EvseCapabilities.rfidReader);
            } else {
              newCapabilities.add(EvseCapabilities.rfidReader);
            }
            _updateFilters(filters.copyWith(capabilities: newCapabilities));
          },
        ),
        const RMSeparator(),
      ],
    );
  }

  Widget _buildPaymentMethodFilters() {
    if (F.appFlavor != Flavor.eflux) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.paymentMethods, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 20),
        _buildCapabilitiesFilters(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ChargingPowerSlider extends StatelessWidget {
  const _ChargingPowerSlider({required this.powerLevels, required this.value, this.onChanged});

  final List<String> powerLevels;

  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Slider(
              value: value,
              min: 0,
              max: (powerLevels.length - 1).toDouble(),
              divisions: powerLevels.length - 1,
              thumbColor: RMColors.rmPrimaryColor,
              activeColor: RMColors.sliderGrey,
              inactiveColor: RMColors.rmPrimaryColor,
              onChanged: onChanged,
            ),
            _buildSliderOverlayCircles(),
          ],
        ),
        _buildLabels(context),
      ],
    );
  }

  Widget _buildSliderOverlayCircles() {
    List<Widget> uiItems = [];
    for (int i = 0; i < powerLevels.length - 1; i++) {
      uiItems.add(_CircleHighlight(active: i >= value.toInt()));
      uiItems.add(const Spacer());
    }

    uiItems.add(const _CircleHighlight(active: true));

    return Row(children: [const SizedBox(width: 21), ...uiItems, const SizedBox(width: 21)]);
  }

  Widget _buildLabels(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // The 10 fixed 36px labels + 2×7px end insets total 374px, which
      // overflows a 360dp-wide screen (e.g. Galaxy S24) by 14px — Spacers
      // can't shrink below zero. Cap the label width to what fits; on wider
      // screens this stays the designed 36px.
      final labelWidth =
          ((constraints.maxWidth - 14) / powerLevels.length).clamp(0.0, 36.0);
      List<Widget> uiItems = [];
      for (final label in powerLevels) {
        uiItems.add(
          SizedBox(
            width: labelWidth,
            child: Align(
              alignment: Alignment.center,
              child: Text(label, softWrap: false, style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
        );

        if (label != powerLevels.last) {
          uiItems.add(const Spacer());
        }
      }

      return Row(children: [const SizedBox(width: 7), ...uiItems, const SizedBox(width: 7)]);
    });
  }
}

class _CircleHighlight extends StatelessWidget {
  const _CircleHighlight({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: active ? RMColors.rmPrimaryColor : RMColors.sliderGrey, shape: BoxShape.circle),
    );
  }
}
