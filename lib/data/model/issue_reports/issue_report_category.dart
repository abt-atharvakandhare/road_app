/// Mirrors the backend `IssueReportCategory` enum at
/// services/api/src/interfaces/domain-models/issue-report.ts.
///
/// We send the raw `id` over the wire. Localized labels live in the UI layer
/// — see `extension IssueReportCategoryLabel` under
/// `lib/ui/mainapp/report_problem/`.
enum IssueReportCategory {
  chargerNotAvailable('charger_not_available'),
  chargerDamaged('charger_damaged'),
  chargerHardToFind('charger_hard_to_find'),
  wrongConnectorType('wrong_connector_type'),
  wrongConnectorSpeed('wrong_connector_speed'),
  missingPriceInformation('missing_price_information'),
  missingPowerInformation('missing_power_information'),
  chargingSessionInterrupted('charging_session_interrupted'),
  chargingSessionNotStarted('charging_session_not_started'),
  other('other');

  const IssueReportCategory(this.id);

  final String id;

  static IssueReportCategory? fromId(String id) {
    for (final category in IssueReportCategory.values) {
      if (category.id == id) return category;
    }
    return null;
  }
}
