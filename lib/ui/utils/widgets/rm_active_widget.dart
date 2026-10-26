import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

class ActiveWidget extends StatelessWidget {
  const ActiveWidget({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive ? RMColors.activeGreen : RMColors.destructiveRed,
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
              child: Text(isActive ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
