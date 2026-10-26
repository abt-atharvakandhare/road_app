import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';

/// Renders the scheme/wallet logo + last-4 line that appears on active and
/// completed session screens. Reads the display-only fields the BE already
/// puts on `externalPayment` — no resolution against stored payment instruments
/// required.
class SessionPaymentDisplayWidget extends StatelessWidget {
  const SessionPaymentDisplayWidget({
    super.key,
    required this.paymentMethod,
    required this.displayIdentifier,
  });

  final String paymentMethod;
  final String displayIdentifier;

  @override
  Widget build(BuildContext context) {
    final method = paymentMethod.toLowerCase();
    final typeLabel = switch (method) {
      'apple-pay' => AppLocalizations.of(context)!.applePay,
      'google-pay' => AppLocalizations.of(context)!.googlePay,
      _ => paymentMethod.capitalized,
    };
    final logoAsset = switch (method) {
      'apple-pay' => 'assets/icons/apple_pay_logo.svg',
      'google-pay' => 'assets/icons/google_pay_logo.svg',
      'visa' => 'assets/icons/credit_card_visa.svg',
      'mastercard' => 'assets/icons/credit_card_mastercard.svg',
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(typeLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Row(
          children: [
            if (logoAsset != null) ...[
              SvgPicture.asset(logoAsset),
              const SizedBox(width: 10),
            ],
            Text('•••• •••• •••• $displayIdentifier', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
