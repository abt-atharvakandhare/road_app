import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/report_problem/report_problem_screen.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';

enum ReportProblemPrompt { station, sessionEnded, sessionHistory }

/// Renders the "Report it here →" prompt that appears on the charger detail
/// sheet, the post-session modal, and the session history detail screen.
///
/// Visually: a separator on top, a one-line prompt question, and a tappable
/// purple link beneath it (matches Figma 5104:808).
class ReportProblemEntryLink extends StatelessWidget {
  const ReportProblemEntryLink({
    super.key,
    required this.prompt,
    required this.locationId,
    this.evseUid,
    this.evseDisplayId,
    this.connectorId,
    this.onSubmitted,
    this.showLeadingSeparator = true,
  });

  final ReportProblemPrompt prompt;
  final String locationId;
  final String? evseUid;
  final String? evseDisplayId;
  final String? connectorId;
  final VoidCallback? onSubmitted;

  /// Whether to render a divider above the prompt. Set to `false` when the
  /// surrounding layout already provides one.
  final bool showLeadingSeparator;

  String _promptText(AppLocalizations l10n) {
    switch (prompt) {
      case ReportProblemPrompt.station:
        return l10n.reportProblemEntryStation;
      case ReportProblemPrompt.sessionEnded:
        return l10n.reportProblemEntrySessionEnded;
      case ReportProblemPrompt.sessionHistory:
        return l10n.reportProblemEntrySession;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Backend requires an authenticated user to submit a report, so the entry
    // point isn't useful for guests.
    if (!BlocProvider.of<AuthCubit>(context).state.isLoggedIn) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLeadingSeparator) const RMSeparator(color: RMColors.separatorLightGrey),
          const SizedBox(height: 16),
        Text(_promptText(l10n), style: textTheme.titleSmall),
        TextButton(
          onPressed: () async {
            final submitted = await ReportProblemScreen.push(
              context,
              locationId: locationId,
              evseUid: evseUid,
              evseDisplayId: evseDisplayId,
              connectorId: connectorId,
            );
            if (submitted == true) onSubmitted?.call();
          },
          style: TextButton.styleFrom(foregroundColor: RMColors.rmPrimaryColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.reportProblemEntryCta, style: textTheme.titleSmall?.copyWith(color: RMColors.rmPrimaryColor)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward, color: RMColors.rmPrimaryColor, size: 18),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
