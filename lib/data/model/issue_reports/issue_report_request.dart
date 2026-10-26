/// Body for `POST /1/issue-reports`. See
/// services/api/src/v1/issue-reports.ts for the Joi schema.
class IssueReportRequest {
  final String locationId;
  final String? evseUid;
  final String? connectorId;
  final String category;
  final String? description;

  const IssueReportRequest({
    required this.locationId,
    this.evseUid,
    this.connectorId,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'locationId': locationId,
        if (evseUid != null) 'evseUid': evseUid,
        if (connectorId != null) 'connectorId': connectorId,
        'category': category,
        if (description != null && description!.isNotEmpty) 'description': description,
      };
}
