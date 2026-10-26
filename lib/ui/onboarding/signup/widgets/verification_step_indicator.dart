import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class VerificationStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  const VerificationStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RMColors.rmPrimaryBackground,
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.stepCounter(currentStep, totalSteps),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 4),
          Text(
            stepTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
