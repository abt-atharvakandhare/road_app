import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_hourly_prices_widget.dart';

import '../colors.dart';
import 'rm_active_now_widget.dart';

class RMTariffPricingWidget extends StatelessWidget {
  const RMTariffPricingWidget({super.key, required this.evseUid, required this.tariffModel});

  final String evseUid;
  final TariffModel? tariffModel;

  @override
  Widget build(BuildContext context) {
    if (tariffModel == null) {
      return Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context)!.noTariffAvailable,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
          ]));
    }

    return _buildMainWidget(context, tariffModel!);
  }

  Widget _buildMainWidget(BuildContext context, TariffModel tariffModel) {
    switch (tariffModel.displayType) {
      case TariffDisplayType.fixedFee:
        return _buildFixedFeePricingWidget(context, tariffModel);
      case TariffDisplayType.scheduled:
        return _buildScheduledPricingWidget(context, tariffModel);
      case TariffDisplayType.dynamic:
        return _buildDynamicPricingWidget(context, tariffModel);
    }
  }

  Widget _buildFixedFeePricingWidget(BuildContext context, TariffModel tariffModel) {
    final widgets = <Widget>[];

    final standardItemPricing = tariffModel.standardItem?.tariffText(
        context, tariffModel.currency, Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700));
    if (standardItemPricing != null) {
      widgets.addAll(standardItemPricing);
    } else {
      widgets.add(Text(AppLocalizations.of(context)!.noTariffAvailable,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)));
    }

    return Align(
        alignment: Alignment.centerLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets));
  }

  Widget _buildScheduledPricingWidget(BuildContext context, TariffModel tariffModel) {
    final widgets = <Widget>[];

    bool isAnyNonStandardTariffActive = tariffModel.nonStandardItems.any((element) => element.isActiveNow);
    var standardTextStyle = Theme.of(context).textTheme.bodySmall;
    standardTextStyle =
        isAnyNonStandardTariffActive ? standardTextStyle : standardTextStyle?.copyWith(fontWeight: FontWeight.w700);

    final standardItemPricing = tariffModel.standardItem?.tariffText(context, tariffModel.currency, standardTextStyle);
    if (standardItemPricing != null) {
      widgets.addAll([
        Row(
          children: [
            Text(AppLocalizations.of(context)!.baseTariff,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 7),
            if (!isAnyNonStandardTariffActive) const ActiveNowWidget()
          ],
        ),
        const SizedBox(height: 4),
      ]);
      widgets.addAll(standardItemPricing);
    } else {
      if (!isAnyNonStandardTariffActive) {
        widgets.add(Text(AppLocalizations.of(context)!.noTariffAvailable,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)));
      }
    }

    for (final item in tariffModel.nonStandardItems) {
      var textStyle = Theme.of(context).textTheme.bodySmall;
      textStyle = item.isActiveNow ? textStyle?.copyWith(fontWeight: FontWeight.w700) : textStyle;
      final dayAndTimeString = item.dayAndTimeString(context);
      final tariffText = item.tariffText(context, tariffModel.currency, textStyle);

      if (tariffText == null) {
        log('Tariff string is null for tariff item: $item');
        continue;
      }
      if (dayAndTimeString != null) {
        widgets.addAll([
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(child: Text(dayAndTimeString, style: textStyle)),
              const SizedBox(width: 7),
              if (item.isActiveNow) const ActiveNowWidget()
            ],
          ),
        ]);
      }
      widgets.addAll(tariffText);
    }

    return Align(
        alignment: Alignment.centerLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets));
  }

  Widget _buildDynamicPricingWidget(BuildContext context, TariffModel tariffModel) {
    final currencyFormatter = NumberFormat.simpleCurrency(name: tariffModel.currency);

    final widgets = <Widget>[];

    final standardItemPricing =
        tariffModel.standardItem?.tariffText(context, tariffModel.currency, Theme.of(context).textTheme.bodySmall);
    if (standardItemPricing != null) {
      widgets.addAll(standardItemPricing);
      widgets.add(const SizedBox(height: 10));
    }

    widgets.add(Text(AppLocalizations.of(context)!.dynamicTariff,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)));

    final threeItems = tariffModel.threeHourItems;
    if (threeItems == null) {
      widgets.add(Text(AppLocalizations.of(context)!.noTariffAvailable,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)));
    } else {
      for (final item in threeItems) {
        final priceString = currencyFormatter.formatRoundingMidUp(item.kwhPrice ?? 0);
        TextStyle? style;
        if (item.isActiveNow) {
          style = Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700);
        } else {
          style = Theme.of(context).textTheme.bodySmall;
        }

        widgets.add(SizedBox(
          height: 21,
          child: Row(children: [
            SizedBox(width: 86, child: Text('${item.startTime} - ${item.endTime}', style: style)),
            SizedBox(width: 2, child: Text('|', style: style?.copyWith(color: RMColors.rmDisabledGray))),
            const SizedBox(width: 11),
            SizedBox(width: 86, child: Text('$priceString / kWh', style: style)),
            if (item.isActiveNow) const ActiveNowWidget()
          ]),
        ));
      }
    }

    if (tariffModel.displayType == TariffDisplayType.dynamic) {
      widgets.add(RMHourlyPricesButton(evseUid: evseUid, tariffModel: tariffModel));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
