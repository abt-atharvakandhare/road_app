import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/rm_charging_port_status_icon.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_tariff_notes_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_tariff_pricing_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/icon_label_row.dart';

class RMEvseConnectorAccordion extends StatefulWidget {
  const RMEvseConnectorAccordion({
    super.key,
    required this.evse,
    required this.connector,
    required this.location,
    required this.tariffModel,
    required this.specialTariffModels,
    required this.showChargeNow,
    required this.onChargeNowPressed,
  });

  final Evse evse;
  final Connector connector;
  final MapLocationV2 location;
  final TariffModel? tariffModel;
  final List<TariffModel?> specialTariffModels;
  final bool showChargeNow;
  final VoidCallback? onChargeNowPressed;

  @override
  State<RMEvseConnectorAccordion> createState() => _RMEvseConnectorAccordionState();
}

class _RMEvseConnectorAccordionState extends State<RMEvseConnectorAccordion> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _chevronRotation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _chevronRotation = Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: _buildExpandedContent(context),
        ),
      ],
    );
  }

  String get _displayName {
    return widget.evse.physicalReference ?? widget.evse.evseId ?? '';
  }

  String get _evseUid => widget.evse.uid ?? widget.evse.evseId ?? '';

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: _toggleExpanded,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/lightning_bolt_small.svg', width: 12, height: 16),
            const SizedBox(width: 8),
            RMChargingPortStatusIcon(chargePortStatus: widget.evse.chargingPortAvailability),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _displayName,
                style: Theme.of(context).textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            RotationTransition(
              turns: _chevronRotation,
              child: Icon(Icons.expand_more, size: 20, color: RMColors.rmPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEvseIdRow(context),
          const SizedBox(height: 12),
          _buildStatusRow(context),
          const SizedBox(height: 12),
          _buildConnectorRow(context),
          const SizedBox(height: 12),
          IconLabelRow(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset('assets/icons/invoice_small.svg'),
            label: AppLocalizations.of(context)!.pricing,
            type: IconLabelRowType.medium,
          ),
          _buildPricingRows(context),
          _buildSpecialTariffRows(context),
          _buildTariffNotesRow(context),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: RMSeparator(color: RMColors.separatorLightGrey),
          ),
          _buildPaymentOptionsSection(context),
          if (widget.showChargeNow) ...[
            const SizedBox(height: 16),
            RMTextButton(
              onPressed: widget.evse.chargingPortAvailability != ChargingPortAvailability.available
                  ? null
                  : widget.onChargeNowPressed,
              text: AppLocalizations.of(context)!.chargeNow,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvseIdRow(BuildContext context) {
    final hasPhysicalRef = widget.evse.physicalReference != null && widget.evse.physicalReference!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SvgPicture.asset('assets/icons/lightning_bolt_small.svg'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.evse.evseId ?? '',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              if (hasPhysicalRef) ...[
                const SizedBox(height: 4),
                Text(
                  widget.evse.physicalReference!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    final evseMaxPower = widget.evse.maxPower?.maxPowerKwFormattedString ?? AppLocalizations.of(context)!.unknownKW;
    return IconLabelRow(
      padding: EdgeInsets.zero,
      icon: RMChargingPortStatusIcon(chargePortStatus: widget.evse.chargingPortAvailability),
      label: '${widget.evse.chargingPortAvailability.humanString(context)}, $evseMaxPower',
    );
  }

  Widget _buildConnectorRow(BuildContext context) {
    return IconLabelRow(
      padding: EdgeInsets.zero,
      icon: SvgPicture.asset(widget.connector.svgAssetPath),
      label: widget.connector.humanConnectorDetails,
      type: IconLabelRowType.medium,
    );
  }

  Widget _buildPricingRows(BuildContext context) {
    final hasSpecialTariffs = widget.specialTariffModels.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasSpecialTariffs)
          Text(
            AppLocalizations.of(context)!.publicTariff,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        RMTariffPricingWidget(evseUid: _evseUid, tariffModel: widget.tariffModel),
      ],
    );
  }

  Widget _buildSpecialTariffRows(BuildContext context) {
    final specialTariffModels = widget.specialTariffModels;
    if (specialTariffModels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final specialTariffModel in specialTariffModels) ...[
          const SizedBox(height: 12),
          Text(
            specialTariffModel?.name ?? AppLocalizations.of(context)!.specialCardTariff,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          RMTariffPricingWidget(evseUid: _evseUid, tariffModel: specialTariffModel),
        ],
      ],
    );
  }

  Widget _buildTariffNotesRow(BuildContext context) {
    final tariffModel = widget.tariffModel;
    if (tariffModel == null) return const SizedBox.shrink();

    return RMTariffNotesButton(
      location: widget.location,
      evseUid: _evseUid,
      displayType: tariffModel.displayType,
    );
  }

  Widget _buildPaymentOptionsSection(BuildContext context) {
    final capabilities = widget.evse.capabilities ?? [];
    final isEflux = widget.location.isEfluxLocation;

    final showCardOrTag = capabilities.contains('RFID_READER');
    final showDirectPayments = isEflux && capabilities.contains('REMOTE_START_STOP_CAPABLE');
    if (!showCardOrTag && !showDirectPayments) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.paymentMethods,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (showCardOrTag)
          IconLabelRow(
            padding: const EdgeInsets.symmetric(vertical: 4),
            icon: SvgPicture.asset('assets/icons/card_tag.svg', height: 20, width: 20),
            label: AppLocalizations.of(context)!.chargingCardOrTag,
          ),
        if (showDirectPayments)
          IconLabelRow(
            padding: const EdgeInsets.symmetric(vertical: 4),
            icon: SvgPicture.asset('assets/icons/credit_card_small.svg', height: 20, width: 20),
            label: AppLocalizations.of(context)!.directPayments,
          ),
      ],
    );
  }
}
