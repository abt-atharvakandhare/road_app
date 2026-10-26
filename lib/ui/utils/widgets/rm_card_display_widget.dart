import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import 'rm_inkwell_button.dart';
import 'rm_separator.dart';

class RMCardDisplayWidget extends StatelessWidget {
  final UnifiedPaymentCard? paymentInstrument;
  final bool showSeparator;
  final VoidCallback? onPressed;

  const RMCardDisplayWidget({super.key, required this.paymentInstrument, this.showSeparator = true, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final visibleCardType = paymentInstrument?.visibleCardType(context);
    return Column(children: [
      if (showSeparator) const RMSeparator(),
      if (paymentInstrument != null) ...[
        RMInkwellButton(
            onPressed: onPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (visibleCardType != null) ...[
                  Text(visibleCardType, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    if (paymentInstrument!.logoImageAssetPath != null) ...[
                      SvgPicture.asset(paymentInstrument!.logoImageAssetPath!),
                      const SizedBox(width: 10),
                    ],
                    Text(paymentInstrument!.visibleCardDescription(context),
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ],
            ))
      ] else ...[
        Text(AppLocalizations.of(context)!.cardDetailsUnavailable, style: Theme.of(context).textTheme.bodySmall)
      ],
      if (showSeparator) const RMSeparator(),
    ]);
  }
}
