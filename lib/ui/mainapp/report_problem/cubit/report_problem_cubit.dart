import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_category.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_request.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart';
import 'package:road_mobile/ui/mainapp/report_problem/data/report_problem_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'report_problem_state.dart';
part 'report_problem_cubit.freezed.dart';

@injectable
class ReportProblemCubit extends Cubit<ReportProblemState> {
  ReportProblemCubit(this._reportRepository, this._chargeNowRepository) : super(const ReportProblemState());

  final ReportProblemRepository _reportRepository;
  final ChargeNowRepository _chargeNowRepository;

  /// Initialize the form for a given location/EVSE/connector.
  ///
  /// One of [evseUid] or [evseDisplayId] should be provided when known. When
  /// neither is provided, the form lets the user pick from any connector at
  /// the location.
  Future<void> initialize({
    required String locationId,
    String? evseUid,
    String? evseDisplayId,
    String? connectorId,
  }) async {
    final hasPreselectedEvse = evseUid != null || evseDisplayId != null;
    emit(
      state.copyWith(
        locationId: locationId,
        headerDisplayId: evseDisplayId,
        selectedEvseUid: evseUid,
        selectedConnectorId: connectorId,
        flow: const UIFlow.loading(),
      ),
    );

    final categoriesFuture = _reportRepository.fetchCategories();
    final detailsFuture = _chargeNowRepository.getChargingLocationsDetails([locationId]);

    var categories = IssueReportCategory.values;
    var unknownCategoryIds = const <String>[];
    try {
      final fetched = await categoriesFuture;
      // BE shouldn't ever return zero categories; if it does, keep the
      // hardcoded fallback so the form stays usable.
      if (fetched.known.isNotEmpty || fetched.unknown.isNotEmpty) {
        categories = fetched.known;
        unknownCategoryIds = fetched.unknown;
      }
    } on RMApiError {
      // Network/server failure — same fallback applies.
    }

    var availableEvses = const <Evse>[];
    String? headerDisplayId = evseDisplayId;
    String? selectedEvseUid = evseUid;
    String? selectedConnectorId = connectorId;

    try {
      final response = await detailsFuture;
      final location =
          response.data.firstWhereOrNull((l) => l.id == locationId) ??
          (response.data.isNotEmpty ? response.data.first : null);
      if (location != null) {
        if (hasPreselectedEvse) {
          final pinnedEvse =
              location.evses.firstWhereOrNull((e) => evseUid != null && e.uid == evseUid) ??
              location.evses.firstWhereOrNull((e) => evseDisplayId != null && e.evseId == evseDisplayId);
          if (pinnedEvse != null) {
            availableEvses = [pinnedEvse];
            selectedEvseUid = pinnedEvse.uid;
            headerDisplayId = pinnedEvse.evseId ?? headerDisplayId;
          }
        } else {
          availableEvses = location.evses;
          headerDisplayId ??= location.address;
        }
      }
    } on RMApiError {
      // Connectors won't be available; the form still allows submitting without one.
    }

    final allOptions = _flatten(availableEvses);
    if (allOptions.length == 1 && selectedConnectorId == null) {
      selectedEvseUid = allOptions.first.evseUid;
      selectedConnectorId = allOptions.first.connector.id;
    } else if (selectedConnectorId != null &&
        !allOptions.any((o) => o.evseUid == selectedEvseUid && o.connector.id == selectedConnectorId)) {
      selectedConnectorId = null;
      if (!hasPreselectedEvse) selectedEvseUid = null;
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        headerDisplayId: headerDisplayId,
        availableEvses: availableEvses,
        selectedEvseUid: selectedEvseUid,
        selectedConnectorId: selectedConnectorId,
        categories: categories,
        unknownCategoryIds: unknownCategoryIds,
        flow: const UIFlow.established(),
      ),
    );
  }

  /// All `(evse, connector)` pairs that the user can pick from.
  List<EvseConnectorOption> get connectorOptions => _flatten(state.availableEvses);

  void selectConnector({required String evseUid, required String connectorId}) {
    emit(state.copyWith(selectedEvseUid: evseUid, selectedConnectorId: connectorId));
  }

  void selectCategory(IssueReportCategory category) {
    emit(state.copyWith(selectedCategory: category, selectedUnknownCategoryId: null));
  }

  /// Used when the BE returns a category we don't have a label for.
  void selectUnknownCategory(String rawId) {
    emit(state.copyWith(selectedCategory: null, selectedUnknownCategoryId: rawId));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  bool get canSubmit {
    final hasCategory = state.selectedCategory != null || state.selectedUnknownCategoryId != null;
    if (!hasCategory) return false;
    if (state.selectedCategory == IssueReportCategory.other) {
      return state.description.trim().isNotEmpty;
    }
    return true;
  }

  Future<void> submit() async {
    if (!canSubmit || state.locationId == null) return;

    emit(state.copyWith(flow: const UIFlow.loading()));

    final categoryId = state.selectedCategory?.id ?? state.selectedUnknownCategoryId!;
    final description = state.description.trim();
    final request = IssueReportRequest(
      locationId: state.locationId!,
      evseUid: state.selectedEvseUid,
      connectorId: state.selectedConnectorId,
      category: categoryId,
      description: description.isEmpty ? null : description,
    );

    try {
      await _reportRepository.submitReport(request);
      if (isClosed) return;
      emit(state.copyWith(flow: const UIFlow.established(), submitted: true));
    } on RMApiError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  static List<EvseConnectorOption> _flatten(List<Evse> evses) {
    final options = <EvseConnectorOption>[];
    for (final evse in evses) {
      if (evse.uid == null) continue;
      for (final connector in evse.connectors) {
        if (connector.id == null) continue;
        options.add(EvseConnectorOption(evse: evse, connector: connector));
      }
    }
    return options;
  }
}

class EvseConnectorOption {
  const EvseConnectorOption({required this.evse, required this.connector});

  final Evse evse;
  final Connector connector;

  String get evseUid => evse.uid!;
  String get connectorId => connector.id!;
  String get displayId => evse.uniqueEvseConnectorStringFor(connector);
}

