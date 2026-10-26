import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_category.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/report_problem/issue_report_category_label.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/report_problem/cubit/report_problem_cubit.dart';
import 'package:road_mobile/ui/mainapp/report_problem/widgets/options_bottom_sheet.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  /// Navigates to the report screen. Resolves to `true` when a report was
  /// submitted, otherwise `null`/`false`.
  static Future<bool?> push(
    BuildContext context, {
    required String locationId,
    String? evseUid,
    String? evseDisplayId,
    String? connectorId,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<ReportProblemCubit>()
            ..initialize(
              locationId: locationId,
              evseUid: evseUid,
              evseDisplayId: evseDisplayId,
              connectorId: connectorId,
            ),
          child: const ReportProblemScreen(),
        ),
      ),
    );
  }

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ReportProblemCubit, ReportProblemState>(
      listenWhen: (prev, curr) => prev.flow != curr.flow || prev.submitted != curr.submitted,
      listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
        if (state.submitted) {
          showStyledSnackbar(
            context,
            SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
            l10n.reportProblemSuccess,
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ReportProblemCubit>();
        final showDescription = state.selectedCategory == IssueReportCategory.other;

        return Scaffold(
          backgroundColor: RMColors.rmPrimaryBackground,
          appBar: AppBar(
            backgroundColor: RMColors.rmPrimaryBackground,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reportProblemTitle, style: Theme.of(context).textTheme.headlineLarge),
                  if (state.headerDisplayId != null) ...[
                    const SizedBox(height: 8),
                    Text(state.headerDisplayId!, style: Theme.of(context).textTheme.titleMedium),
                  ],
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cubit.connectorOptions.isNotEmpty) ...[
                            _FieldLabel(text: l10n.reportProblemFieldConnector),
                            const SizedBox(height: 6),
                            _SelectorField(
                              text: _connectorLabel(cubit, state),
                              onTap: () => _pickConnector(context, cubit, state),
                            ),
                            const SizedBox(height: 20),
                          ],
                          _FieldLabel(text: l10n.reportProblemFieldCategory),
                          const SizedBox(height: 6),
                          _SelectorField(
                            text: _categoryLabel(context, state),
                            onTap: () => _pickCategory(context, cubit, state),
                          ),
                          if (showDescription) ...[
                            const SizedBox(height: 20),
                            _FieldLabel(text: l10n.reportProblemFieldDescription),
                            const SizedBox(height: 6),
                            _DescriptionField(
                              controller: _descriptionController,
                              hintText: l10n.reportProblemDescriptionPlaceholder,
                              onChanged: cubit.updateDescription,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RMTextButton(
                    onPressed: cubit.canSubmit ? cubit.submit : null,
                    text: l10n.reportProblemSubmit,
                    isLoading: state.flow.isLoading,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _connectorLabel(ReportProblemCubit cubit, ReportProblemState state) {
    if (state.selectedConnectorId == null || state.selectedEvseUid == null) return '—';
    return cubit.connectorOptions
            .where((o) => o.evseUid == state.selectedEvseUid && o.connectorId == state.selectedConnectorId)
            .firstOrNull
            ?.displayId ??
        '—';
  }

  String _categoryLabel(BuildContext context, ReportProblemState state) {
    if (state.selectedCategory != null) return state.selectedCategory!.label(context);
    if (state.selectedUnknownCategoryId != null) return state.selectedUnknownCategoryId!;
    return '—';
  }

  Future<void> _pickConnector(
    BuildContext context,
    ReportProblemCubit cubit,
    ReportProblemState state,
  ) async {
    final options = cubit.connectorOptions;
    final entries = [
      for (var i = 0; i < options.length; i++)
        OptionsBottomSheetEntry<int>(value: i, label: options[i].displayId),
    ];
    final currentIndex = options.indexWhere(
      (o) => o.evseUid == state.selectedEvseUid && o.connectorId == state.selectedConnectorId,
    );
    final picked = await OptionsBottomSheet.show<int>(
      context,
      title: AppLocalizations.of(context)!.reportProblemFieldConnector,
      entries: entries,
      selectedValue: currentIndex == -1 ? null : currentIndex,
    );
    if (picked == null) return;
    final option = options[picked];
    cubit.selectConnector(evseUid: option.evseUid, connectorId: option.connectorId);
  }

  Future<void> _pickCategory(
    BuildContext context,
    ReportProblemCubit cubit,
    ReportProblemState state,
  ) async {
    final entries = <OptionsBottomSheetEntry<String>>[
      ...state.categories.map(
        (c) => OptionsBottomSheetEntry<String>(value: c.id, label: c.label(context)),
      ),
      ...state.unknownCategoryIds.map(
        (id) => OptionsBottomSheetEntry<String>(value: id, label: id),
      ),
    ];
    final currentId = state.selectedCategory?.id ?? state.selectedUnknownCategoryId;
    final picked = await OptionsBottomSheet.show<String>(
      context,
      title: AppLocalizations.of(context)!.reportProblemFieldCategory,
      entries: entries,
      selectedValue: currentId,
    );
    if (picked == null) return;
    final known = IssueReportCategory.fromId(picked);
    if (known != null) {
      cubit.selectCategory(known);
    } else {
      cubit.selectUnknownCategory(picked);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

class _SelectorField extends StatelessWidget {
  const _SelectorField({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RMColors.containerBorderGrey),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.keyboard_arrow_down, color: RMColors.searchTextGrey),
          ],
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller, required this.hintText, required this.onChanged});

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RMColors.containerBorderGrey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        minLines: 4,
        maxLines: 6,
        style: Theme.of(context).textTheme.titleSmall,
        // Override the app's inputDecorationTheme — it sets filled:true and
        // OutlineInputBorders for every state, which would render a second
        // rounded box inside our outer Container.
        decoration: InputDecoration(
          hintText: hintText,
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
