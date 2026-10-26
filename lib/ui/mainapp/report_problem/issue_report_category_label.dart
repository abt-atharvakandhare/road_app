import 'package:flutter/widgets.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_category.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

/// UI-layer mapping from category enum to localized label.
extension IssueReportCategoryLabel on IssueReportCategory {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case IssueReportCategory.chargerNotAvailable:
        return l10n.reportProblemCategoryChargerNotAvailable;
      case IssueReportCategory.chargerDamaged:
        return l10n.reportProblemCategoryChargerDamaged;
      case IssueReportCategory.chargerHardToFind:
        return l10n.reportProblemCategoryChargerHardToFind;
      case IssueReportCategory.wrongConnectorType:
        return l10n.reportProblemCategoryWrongConnectorType;
      case IssueReportCategory.wrongConnectorSpeed:
        return l10n.reportProblemCategoryWrongConnectorSpeed;
      case IssueReportCategory.missingPriceInformation:
        return l10n.reportProblemCategoryMissingPriceInformation;
      case IssueReportCategory.missingPowerInformation:
        return l10n.reportProblemCategoryMissingPowerInformation;
      case IssueReportCategory.chargingSessionInterrupted:
        return l10n.reportProblemCategoryChargingSessionInterrupted;
      case IssueReportCategory.chargingSessionNotStarted:
        return l10n.reportProblemCategoryChargingSessionNotStarted;
      case IssueReportCategory.other:
        return l10n.reportProblemCategoryOther;
    }
  }
}
