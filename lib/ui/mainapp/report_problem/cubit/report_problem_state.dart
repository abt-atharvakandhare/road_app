part of 'report_problem_cubit.dart';

@freezed
sealed class ReportProblemState with _$ReportProblemState {
  const factory ReportProblemState({
    String? locationId,
    String? headerDisplayId,
    @Default([]) List<Evse> availableEvses,
    String? selectedEvseUid,
    String? selectedConnectorId,
    @Default(IssueReportCategory.values) List<IssueReportCategory> categories,
    @Default([]) List<String> unknownCategoryIds,
    IssueReportCategory? selectedCategory,
    String? selectedUnknownCategoryId,
    @Default('') String description,
    @Default(UIFlow.established()) UIFlow flow,
    @Default(false) bool submitted,
  }) = _ReportProblemState;
}
