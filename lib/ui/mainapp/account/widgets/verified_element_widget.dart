import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class VerifiedElementWidget extends StatelessWidget {
  const VerifiedElementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: RMColors.verifiedGreen,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/icons/verified_tick.svg'),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.verified,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
