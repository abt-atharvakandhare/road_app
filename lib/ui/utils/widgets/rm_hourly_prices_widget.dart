import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/date_time_extensions.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/icon_label_row.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import 'rm_active_now_widget.dart';

class RMHourlyPricesButton extends StatelessWidget {
  RMHourlyPricesButton({super.key, required this.evseUid, required this.tariffModel}) {
    currencyFormatter = NumberFormat.simpleCurrency(name: tariffModel.currency);
  }

  final String evseUid;
  final TariffModel tariffModel;
  late final NumberFormat currencyFormatter;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                    initialChildSize: 1.0,
                    minChildSize: 0.99,
                    maxChildSize: 1.0,
                    builder: (context, scrollController) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 24, right: 3),
                        child: ListView(
                            controller: scrollController,
                            shrinkWrap: true,
                            children: _buildAllDynamicPrices(context, tariffModel)),
                      );
                    });
              });
        },
        child: Text(
          AppLocalizations.of(context)!.viewAllHourlyPrices,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: RMColors.rmPrimaryColor),
        ));
  }

  List<Widget> _buildAllDynamicPrices(BuildContext context, TariffModel tariffModel) {
    final widgets = <Widget>[];

    widgets.addAll([
      Row(
        children: [
          Expanded(
              child: Text(AppLocalizations.of(context)!.hourlyPrices, style: Theme.of(context).textTheme.bodyMedium)),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.close,
                size: 29,
              ))
        ],
      ),
      IconLabelRow(
        icon: SvgPicture.asset('assets/icons/lightning_bolt_small.svg'),
        label: evseUid,
      )
    ]);

    DateTime? lastDisplayedDate;

    for (final item in tariffModel.nonStandardItems) {
      final startDateTime = item.startDateTime;
      if (startDateTime == null) {
        continue;
      }

      final startDateOnly = DateUtils.dateOnly(startDateTime);
      if (startDateOnly != lastDisplayedDate) {
        lastDisplayedDate = startDateOnly;
        widgets.add(const SizedBox(height: 16));
        // Format dateTimeString as string of date resembling "Tuesday, 25th July"
        final dateTimeString = startDateOnly.dayDateMonth;

        widgets.add(Text(
          '${AppLocalizations.of(context)!.dynamicTariff} - $dateTimeString',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ));

        widgets.add(const SizedBox(height: 10));
      }

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

    return widgets;
  }
}
