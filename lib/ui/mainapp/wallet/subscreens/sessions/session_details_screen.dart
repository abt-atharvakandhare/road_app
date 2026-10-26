import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/report_problem/widgets/report_problem_entry_link.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_station_direct_line_map_widget.dart';

import 'cubit/session_detail_cubit.dart';

class SessionDetailsScreen extends StatelessWidget {
  const SessionDetailsScreen({super.key, required this.session});

  final SessionModel session;

  static Future<bool?> push(BuildContext context, SessionModel session) async {
    return Navigator.push<bool>(context, MaterialPageRoute(builder: ((routeContext) {
      return BlocProvider(
        create: (_) {
          final cubit = getIt<SessionDetailCubit>();
          // The active-sessions list already returns everything we can render
          // for an ongoing session (and /1/sessions/:id would 404 on its id),
          // so the detail fetch is only meaningful for completed sessions.
          if (session.id != null && !session.isActiveListEntry) {
            cubit.loadDetail(session.id!);
          }
          return cubit;
        },
        child: SessionDetailsScreen(session: session),
      );
    })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<SessionDetailCubit, SessionDetailState>(
        listenWhen: (prev, curr) => prev.flow != curr.flow,
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
        },
        buildWhen: (prev, curr) =>
            prev.detailSession != curr.detailSession || prev.flow != curr.flow,
        builder: (context, state) {
          final displaySession = state.detailSession ?? session;
          final isLoadingDetail = state.detailSession == null &&
              session.id != null &&
              !session.isActiveListEntry &&
              !state.flow.isError;
          return _buildBody(context, displaySession, isLoadingDetail: isLoadingDetail);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionModel displaySession, {required bool isLoadingDetail}) {
    final hasCoordinates = displaySession.lat != null && displaySession.lng != null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: isLoadingDetail
                ? Column(
                    children: [
                      const RMSeparator(),
                      AspectRatio(
                        aspectRatio: 375.0 / 200.0,
                        child: Shimmer.fromColors(
                          baseColor: RMColors.separatorLightGrey,
                          highlightColor: RMColors.separatorDarkGrey,
                          child: Container(color: RMColors.separatorLightGrey),
                        ),
                      ),
                    ],
                  )
                : hasCoordinates
                    ? Column(
                        children: [
                          const RMSeparator(),
                          RMStationDirectLineMapWidget(
                            stationLocation: LatLng(displaySession.lat!, displaySession.lng!),
                            stationId: displaySession.mspLocation?.id ?? displaySession.id ?? 'session',
                            stationName: displaySession.locationName ?? '',
                            stationStatus: ChargingPortAvailability.notAvailable,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
          ),
          const RMSeparator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildLocationHeader(context, displaySession),
                const SizedBox(height: 16),
                _buildStatsGrid(context, displaySession),
                if (displaySession.mspLocation?.id != null)
                  ReportProblemEntryLink(
                    prompt: ReportProblemPrompt.sessionHistory,
                    locationId: displaySession.mspLocation!.id!,
                    evseDisplayId: displaySession.displayChargePointId,
                    showLeadingSeparator: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context, SessionModel displaySession) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displaySession.locationName ?? l10n.unknownAddress,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        const RMSeparator(),
        const SizedBox(height: 12),
        if (displaySession.locationName != displaySession.location?.address)
          _buildIconRow(
            context,
            iconWidget: SvgPicture.asset('assets/icons/session_detail_map_marker.svg', width: 12, height: 16),
            text: displaySession.location?.address ?? l10n.unknownAddress,
          ),
        if (displaySession.displayChargePointId != null) ...[
          const SizedBox(height: 14),
          _buildIconRow(
            context,
            iconWidget: SvgPicture.asset('assets/icons/sessions_total_energy_lightning.svg', width: 14, height: 18),
            text: displaySession.displayChargePointId!,
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildIconRow(BuildContext context, {required Widget iconWidget, required String text}) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Center(child: iconWidget),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, SessionModel displaySession) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final localStart = displaySession.startedAt.toLocal();

    return Column(
      children: [
        _buildStatsRow(
          context,
          left: _StatCell(
            value: displaySession.durationSeconds != null
                ? displaySession.durationSeconds!.toInt().toDaysHoursMinutesString(context)
                : '--',
            label: l10n.duration,
            icon: SvgPicture.asset('assets/icons/session_detail_clock_duration.svg', width: 16, height: 16),
          ),
          right: _StatCell(
            value: displaySession.formattedKwhString,
            label: l10n.charged,
            icon: SvgPicture.asset('assets/icons/sessions_total_energy_lightning.svg', width: 13, height: 18),
          ),
          showTopBorder: true,
        ),
        _buildStatsRow(
          context,
          left: _StatCell(
            value: DateFormat.jm(locale).format(localStart),
            label: l10n.startTime,
            icon: SvgPicture.asset('assets/icons/sessions_total_time_clock.svg', width: 16, height: 16),
          ),
          right: _StatCell(
            value: displaySession.endedAt != null ? DateFormat.jm(locale).format(displaySession.endedAt!.toLocal()) : '--',
            label: l10n.endTime,
            icon: SvgPicture.asset('assets/icons/session_detail_clock_end.svg', width: 16, height: 16),
          ),
        ),
        _buildStatsRow(
          context,
          left: _StatCell(
            // MMMMd gives locale-aware ordering without the year (deliberate — year omitted by design)
            value: DateFormat.MMMMd(locale).format(localStart),
            label: l10n.date,
            icon: SvgPicture.asset('assets/icons/session_detail_calendar.svg', width: 14, height: 16),
          ),
          right: _StatCell(
            value: displaySession.finalBillingString ?? '--',
            label: l10n.totalCosts,
            icon: SvgPicture.asset('assets/icons/sessions_cost_coins.svg', width: 16, height: 16),
          ),
          showBottomBorder: true,
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    BuildContext context, {
    required _StatCell left,
    required _StatCell right,
    bool showTopBorder = false,
    bool showBottomBorder = false,
  }) {
    const borderSide = BorderSide(color: RMColors.separatorDarkGrey);
    final showIntermediateBorder = !showBottomBorder;

    return Column(
      children: [
        if (showTopBorder) const RMSeparator(),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: showIntermediateBorder
                    ? const BoxDecoration(border: Border(bottom: borderSide))
                    : null,
                child: _buildStatCell(context, left),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Container(
                decoration: showIntermediateBorder
                    ? const BoxDecoration(border: Border(bottom: borderSide))
                    : null,
                child: _buildStatCell(context, right),
              ),
            ),
          ],
        ),
        if (showBottomBorder) const RMSeparator(),
      ],
    );
  }

  Widget _buildStatCell(BuildContext context, _StatCell cell) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cell.value,
                  style: textTheme.headlineMedium?.copyWith(
                    letterSpacing: -0.14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cell.label,
                  style: textTheme.bodySmall?.copyWith(
                    color: RMColors.rmBlackText,
                  ),
                ),
              ],
            ),
          ),
          cell.icon,
        ],
      ),
    );
  }
}

class _StatCell {
  final String value;
  final String label;
  final Widget icon;

  const _StatCell({required this.value, required this.label, required this.icon});
}
