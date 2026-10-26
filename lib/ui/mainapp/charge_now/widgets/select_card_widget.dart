import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/cards/preauth_limits_model.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/data/model/charging/charging_start_data_model.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/icon_label_row.dart';
import 'package:road_mobile/ui/utils/widgets/rm_capabilities_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_charging_port_status_icon.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_tariff_pricing_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_station_direct_line_map_widget.dart';
import 'package:road_mobile/ui/utils/widgets/tick_radio_list_tile.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../bloc/charge_now_bloc.dart';

class StartChargingSessionWidget extends StatelessWidget {
  const StartChargingSessionWidget(
      {super.key,
      required this.locationMetadata,
      required this.availablePaymentInstruments,
      required this.selectedPaymentInstrument,
      required this.preAuthLimits});

  final StartChargingLocationMetadata locationMetadata;
  final UnifiedPaymentCards availablePaymentInstruments;
  final UnifiedPaymentCard? selectedPaymentInstrument;
  final PreauthLimitsModel preAuthLimits;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFixedHeader(context),
        Expanded(
          child: SingleChildScrollView(
            child: _buildScrollableContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SvgPicture.asset('assets/icons/lightning_bolt.svg'),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.startChargingSession),
          const SizedBox(height: 16),
          const RMSeparator(),
          RMStationDirectLineMapWidget(
            stationLocation: locationMetadata.latLng,
            stationId: locationMetadata.locationId,
            stationName: locationMetadata.name,
            stationStatus: locationMetadata.status,
            userLocation: locationMetadata.searchLocation,
          ),
          const RMSeparator(),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    final connectorMaxPowerStr =
        locationMetadata.maxPower?.maxPowerKwFormattedString ?? AppLocalizations.of(context)!.unknownKW;

    final bestTariff = locationMetadata.getBestTariff(selectedPaymentInstrument?.rfidCard?.token?.visualNumber);

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  locationMetadata.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const RMSeparator(color: RMColors.separatorLightGrey, edgeInsets: EdgeInsets.only(top: 20.0)),
                IconLabelRow(
                  icon: SvgPicture.asset('assets/icons/lightning_bolt_small.svg'),
                  label: locationMetadata.displayId,
                ),
                IconLabelRow(
                  icon: RMChargingPortStatusIcon(chargePortStatus: locationMetadata.status),
                  label: '${locationMetadata.status.humanString(context)}, $connectorMaxPowerStr',
                ),
                IconLabelRow(
                  icon: SvgPicture.asset('assets/icons/charging_port_small.svg'),
                  label: locationMetadata.powerType,
                  type: IconLabelRowType.small,
                ),
                IconLabelRow(
                  icon: SvgPicture.asset('assets/icons/invoice_small.svg'),
                  label: AppLocalizations.of(context)!.pricing,
                  type: IconLabelRowType.small,
                ),
                RMTariffPricingWidget(evseUid: locationMetadata.evseUid, tariffModel: bestTariff),
                const SizedBox(height: 20),
                const RMSeparator(),
                const SizedBox(height: 20),
                RMCapabilitiesWidget(
                  capabilities: locationMetadata.capabilities,
                  isEflux: locationMetadata.evseId.contains("EFL"),
                ),
                const SizedBox(height: 20),
                const RMSeparator(),
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.payWith, style: Theme.of(context).textTheme.labelLarge),
              ])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: (selectedPaymentInstrument != null)
                ? Column(
                    children: [
                      RMCardDisplayWidget(
                        showSeparator: false,
                        paymentInstrument: selectedPaymentInstrument!,
                        onPressed: () => _showInstrumentPicker(context),
                      ),
                      const RMSeparator(),
                    ],
                  )
                : _buildPaymentMethodWidget(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                BlocBuilder<ChargeNowBloc, ChargeNowState>(
                  builder: (context, state) {
                    final isLoading = state.flow.isLoading;
                    return RMTextButton(
                        isLoading: isLoading,
                        onPressed: (selectedPaymentInstrument == null ||
                                locationMetadata.status != ChargingPortAvailability.available)
                            ? null
                            : () {
                                BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.startCharging(
                                    locationMetadata, selectedPaymentInstrument!, preAuthLimits));
                              },
                        text: AppLocalizations.of(context)!.startSession);
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 40)
        ],
      ),
    );
  }

  Widget _buildPaymentMethodWidget(BuildContext context) {
    if (availablePaymentInstruments.paymentCards.isEmpty) {
      // No cards (credit or RFID) to pick, and the picker — which is the only
      // other place that hosts the add button — can't be opened from here. Keep
      // the "no cards" message and offer to add one inline below it (the button
      // hides itself when the user isn't allowed to add a card).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.noCardsAvailable, style: Theme.of(context).textTheme.labelSmall),
          _AddCardButton(),
        ],
      );
    }

    return RMInkwellButton(
        onPressed: () => _showInstrumentPicker(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/credit_card_visa.svg'),
              const SizedBox(width: 8),
              SvgPicture.asset('assets/icons/credit_card_mastercard.svg'),
              const SizedBox(width: 8),
              if (Platform.isIOS) SvgPicture.asset('assets/icons/apple_pay_logo.svg'),
              if (Platform.isAndroid) SvgPicture.asset('assets/icons/google_pay_logo.svg'),
            ],
          ),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.selectPaymentMethod,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: RMColors.rmPrimaryColor)),
        ]));
  }

  void _showInstrumentPicker(BuildContext context) {
    // Capture providers from the outer tree; the modal route is a sibling of
    // the current route, not a descendant, so it can't see them otherwise.
    final chargeNowBloc = context.read<ChargeNowBloc>();
    final authCubit = context.read<AuthCubit>();
    final addCreditCardCubit = context.read<AddCreditCardCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: chargeNowBloc),
            BlocProvider.value(value: authCubit),
            BlocProvider.value(value: addCreditCardCubit),
          ],
          // Surface add-card errors from inside the sheet. The root screen's
          // listener can't: its showErrorDialog bails when the screen isn't the
          // current route, and this bottom sheet sits on top of it.
          child: BlocListener<AddCreditCardCubit, AddCreditCardState>(
            listenWhen: (prev, curr) => curr.flow.isError,
            listener: (context, state) =>
                getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error),
            child: _PaymentInstrumentPicker(fallbackCards: availablePaymentInstruments),
          ),
        );
      },
    );
  }
}

class _PaymentInstrumentPicker extends StatelessWidget {
  const _PaymentInstrumentPicker({required this.fallbackCards});

  final UnifiedPaymentCards fallbackCards;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChargeNowBloc, ChargeNowState>(
      builder: (context, state) {
        // Prefer live bloc state so additions/selections stay reactive; fall
        // back to the cards passed in if we've transitioned out of the picker
        // state (e.g. during reload).
        final cards = state is StartChargingSession ? state.cards : fallbackCards;
        final selectedCard = state is StartChargingSession ? state.selectedCard : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.paymentMethod, style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const RMSeparator(),
              if (cards.paymentCards.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(AppLocalizations.of(context)!.noCardsAvailable),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: cards.paymentCards.map((card) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TickRadioListTile<UnifiedPaymentCard>(
                              title: RMCardDisplayWidget(paymentInstrument: card, showSeparator: false),
                              value: card,
                              groupValue: selectedCard,
                              controlAffinity: ListTileControlAffinity.trailing,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (_) {
                                context.read<ChargeNowBloc>().add(ChargeNowEvent.selectNewPaymentCard(card));
                              },
                            ),
                            const RMSeparator(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              _AddCardButton(),
            ],
          ),
        );
      },
    );
  }
}

class _AddCardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      if (!state.canAddCreditCard) {
        return const SizedBox.shrink();
      }
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () async {
            final addedCard =
                await context.read<AddCreditCardCubit>().startAddPaymentMethodFlow(context, "ChargeNow");
            if (context.mounted && addedCard == true) {
              context.read<ChargeNowBloc>().add(const ChargeNowEvent.reloadPaymentCards());
            }
          },
          child: Text('+ ${AppLocalizations.of(context)!.addPaymentMethod.capitalized}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: RMColors.rmPrimaryColor)),
        ),
      );
    });
  }
}
