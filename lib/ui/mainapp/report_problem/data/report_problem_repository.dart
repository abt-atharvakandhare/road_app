import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_category.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_request.dart';
import 'package:road_mobile/services/network/api_service.dart';

@lazySingleton
class ReportProblemRepository {
  ReportProblemRepository(this._apiService);

  final ApiService _apiService;

  Future<void> submitReport(IssueReportRequest request) async {
    await _apiService.post('/1/issue-reports', data: request.toJson());
  }

  /// Fetches the category IDs from the backend. Returns the parsed enum values
  /// in the order the backend sent them, plus any unknown raw IDs at the end
  /// (so the picker can still surface them, even if we don't have a label).
  Future<({List<IssueReportCategory> known, List<String> unknown})> fetchCategories() async {
    final response = await _apiService.get('/1/issue-reports/categories');
    final raw = (response.data['data'] as List?)?.cast<String>() ?? const <String>[];

    final known = <IssueReportCategory>[];
    final unknown = <String>[];
    for (final id in raw) {
      final category = IssueReportCategory.fromId(id);
      if (category != null) {
        known.add(category);
      } else {
        unknown.add(id);
      }
    }
    return (known: known, unknown: unknown);
  }
}
