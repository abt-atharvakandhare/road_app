import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

class ActiveNowWidget extends StatelessWidget {
  const ActiveNowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: RMColors.activeChargeBlueText.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          border: Border.all(color: RMColors.activeChargeBlueText.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
        child: Text(AppLocalizations.of(context)!.activeNow,
            style:
                Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 10.0, color: RMColors.activeChargeBlueText)),
      ),
    );
  }
}
