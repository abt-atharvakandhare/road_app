import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:road_mobile/l10n/app_localizations.dart';
import 'icon_label_row.dart';

class RMCapabilitiesWidget extends StatelessWidget {
  const RMCapabilitiesWidget({
    super.key,
    required this.capabilities,
    required this.isEflux,
  });

  final List<String> capabilities;
  final bool isEflux;

  @override
  Widget build(BuildContext context) {
    final showCardOrTag = capabilities.contains("RFID_READER");
    final showDirectPayments = isEflux && capabilities.contains("REMOTE_START_STOP_CAPABLE");
    if (!showCardOrTag && !showDirectPayments) return const SizedBox.shrink();

    if (!isEflux) {
      return Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: Text(AppLocalizations.of(context)!.paymentMethods,
                    textAlign: TextAlign.start, style: Theme.of(context).textTheme.headlineSmall),
              ),
            ],
          ),
          if (showCardOrTag)
            IconLabelRow(
              icon: SvgPicture.asset(
                'assets/icons/card_tag.svg',
                height: 20,
                width: 20,
              ),
              label: AppLocalizations.of(context)!.chargingCardOrTag,
            ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
              child: Text(
                AppLocalizations.of(context)!.paymentMethods,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        if (showDirectPayments)
          IconLabelRow(
            icon: SvgPicture.asset(
              'assets/icons/credit_card_small.svg',
              height: 20,
              width: 20,
            ),
            label: AppLocalizations.of(context)!.directPayments,
          ),
        if (showCardOrTag)
          IconLabelRow(
            icon: SvgPicture.asset(
              'assets/icons/card_tag.svg',
              height: 20,
              width: 20,
            ),
            label: AppLocalizations.of(context)!.chargingCardOrTag,
          ),
      ],
    );
  }
}
