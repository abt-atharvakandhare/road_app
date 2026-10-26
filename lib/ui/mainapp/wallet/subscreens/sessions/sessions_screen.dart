import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/wallet/cubit/wallet_navigation_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/date_time_extensions.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_shimmer_loader.dart';

import 'session_item_widget.dart';
import 'cubit/sessions_cubit.dart';
import 'session_details_screen.dart';
import 'sessions_filter_screen.dart';
import 'widgets/sessions_stats_widget.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        BlocProvider.of<SessionsCubit>(context).loadMoreAllSessions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletNavigationCubit, WalletNavigationState>(
      // External refresh trigger — fires when the user taps a
      // `charging.session.ended` push while this screen is already mounted.
      // (If the screen wasn't mounted, SessionsCubit's constructor handles
      // the initial fetch.) Keyed on refreshNonce so repeated taps each
      // trigger a fresh fetch.
      bloc: getIt<WalletNavigationCubit>(),
      listenWhen: (previous, current) =>
          previous.refreshNonce != current.refreshNonce && current.tab == WalletTab.sessions,
      listener: (context, _) {
        BlocProvider.of<SessionsCubit>(context).loadAllSessions(false);
      },
      child: BlocConsumer<SessionsCubit, SessionsState>(listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
      }, builder: (context, state) {
      final scrollChildren = _buildScrollChildren(context, state);
      return RefreshIndicator(
        onRefresh: () async {
          await BlocProvider.of<SessionsCubit>(context).loadAllSessions(false);
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: scrollChildren.length,
                itemBuilder: (context, index) {
                  return scrollChildren[index];
                },
              ),
            ),
            BottomLoadingWidget(isLoading: state.flow.isLoading),
          ],
        ),
      );
    }),
    );
  }

  List<Widget> _buildScrollChildren(BuildContext context, SessionsState state) {
    final scrollChildren = <Widget>[];
    final cubit = BlocProvider.of<SessionsCubit>(context);

    scrollChildren.add(const SizedBox(height: 24));
    scrollChildren.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.sessions, style: Theme.of(context).textTheme.bodyMedium),
        _buildFilterButton(context, state),
      ],
    ));
    if (state.selectedYear != null) {
      scrollChildren.add(const SizedBox(height: 10));
      scrollChildren.add(Text(_getFilterSubtitle(state), style: Theme.of(context).textTheme.headlineMedium));
    }
    scrollChildren.add(const SizedBox(height: 16));

    // Stats widget
    scrollChildren.add(SessionsStatsWidget(
      stats: state.stats,
      totalSessions: cubit.allSessionsTotal ?? 0,
    ));
    scrollChildren.add(const SizedBox(height: 20));

    scrollChildren.add(RMShimmerLoader(
      isLoading: state.flow.isLoading && (state.allSessions == null || state.allSessions!.isEmpty),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildSessions(context, state)),
    ));
    scrollChildren.add(const SizedBox(height: 24));

    return scrollChildren;
  }

  String _getFilterSubtitle(SessionsState state) {
    if (state.selectedMonth != null) {
      // Month + Year: "January 2026"
      final date = DateTime(state.selectedYear!, state.selectedMonth!);
      return date.monthYear;
    } else {
      // Year only: "2025"
      return state.selectedYear.toString();
    }
  }

  Widget _buildFilterButton(BuildContext context, SessionsState state) {
    final hasActiveFilters = state.hasActiveFilters;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: RMColors.rmWhiteText,
            border: Border.all(color: RMColors.separatorDarkGrey, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: IconButton(
            onPressed: () {
              SessionsFilterScreen.pushAsModal(context);
            },
            icon: SvgPicture.asset('assets/icons/maps_filter.svg'),
          ),
        ),
        if (hasActiveFilters)
          IgnorePointer(
            child: Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RMColors.rmPrimaryColor,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSessions(BuildContext context, SessionsState state) {
    final combinedSessions = (state.activeSessions ?? []) + (state.allSessions ?? []);

    if (combinedSessions.isEmpty) {
      return [
        Text(AppLocalizations.of(context)!.noSessionDataAvailable, style: Theme.of(context).textTheme.titleSmall)
      ];
    }

    // Skip month/year headers if filtering by both month and year
    // (since the filter subtitle already shows "January 2026")
    final skipMonthYearHeaders = state.selectedYear != null && state.selectedMonth != null;

    List<Widget> sessionWidgets = [];
    DateTime? lastHeaderDateShown;

    for (var session in combinedSessions) {
      if (!skipMonthYearHeaders &&
          (lastHeaderDateShown == null || !lastHeaderDateShown.isSameMonthAndYear(session.startedAt))) {
        sessionWidgets.add(const SizedBox(height: 10));
        sessionWidgets.add(Text(session.startedAt.monthYear, style: Theme.of(context).textTheme.headlineMedium));
        sessionWidgets.add(const SizedBox(height: 20));
        lastHeaderDateShown = session.startedAt;
      }

      sessionWidgets.add(SessionItemWidget(
          session: session,
          onPressed: () {
            SessionDetailsScreen.push(context, session);
          }));
      sessionWidgets.add(const SizedBox(height: 20));
      sessionWidgets.add(const RMSeparator());

      final isLastSession = session == combinedSessions.last;
      if (!isLastSession) {
        sessionWidgets.add(const SizedBox(height: 20));
      }
    }

    return sessionWidgets;
  }
}
