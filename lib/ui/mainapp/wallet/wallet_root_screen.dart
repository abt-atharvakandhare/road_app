import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/wallet/cubit/wallet_navigation_cubit.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/invoices/cubit/invoices_cubit.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/invoices/invoices_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/payment_methods_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/sessions_cubit.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';

import '../add_credit_card/cubit/add_credit_card_cubit.dart';
import 'subscreens/sessions/sessions_screen.dart';

class WalletRootScreen extends StatefulWidget {
  const WalletRootScreen({super.key});

  @override
  State<WalletRootScreen> createState() => _WalletRootNavigatorState();
}

class _WalletRootNavigatorState extends State<WalletRootScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (result) => _navigatorKey.currentState!.pop(result),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) {
            return _WalletRootScreen();
          });
        },
      ),
    );
  }
}

class _WalletRootScreen extends StatefulWidget {
  @override
  State<_WalletRootScreen> createState() => _WalletRootScreenState();
}

class _WalletRootScreenState extends State<_WalletRootScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MixpanelService _mixpanelService = getIt<MixpanelService>();

  @override
  void initState() {
    super.initState();
    // Seed the TabController from WalletNavigationCubit's *current* state so a
    // tap-to-open-sessions intent that fired *before* this screen was mounted
    // (e.g. user was on a non-wallet tab) still lands on Sessions. The
    // BlocListener in build() handles intents fired *after* mount.
    final initialTab = getIt<WalletNavigationCubit>().state.tab;
    _tabController = TabController(
      length: F.showInvoices ? 3 : 2,
      vsync: this,
      initialIndex: _clampTabIndex(initialTab.tabIndex),
    );
    _tabController.addListener(_onTabChanged);
    _trackTabView(_tabController.index);
  }

  int _clampTabIndex(int index) {
    final maxIndex = (F.showInvoices ? 3 : 2) - 1;
    return index.clamp(0, maxIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _trackTabView(_tabController.index);
    }
  }

  void _trackTabView(int index) {
    final buttonName = switch (index) {
      0 => MixpanelButtonName.sessions,
      1 => MixpanelButtonName.paymentMethods,
      2 => MixpanelButtonName.invoices,
      _ => null,
    };
    if (buttonName != null) {
      _mixpanelService.trackButtonClick(buttonName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletNavigationCubit, WalletNavigationState>(
      // Drives the TabController in response to external nav intents (e.g. a
      // `charging.session.ended` push tap). `listenWhen` keys on the
      // refresh-nonce so repeated identical requests still fire — the cubit
      // increments the nonce on every request precisely for this reason.
      bloc: getIt<WalletNavigationCubit>(),
      listenWhen: (previous, current) => previous.refreshNonce != current.refreshNonce,
      listener: (context, state) {
        final target = _clampTabIndex(state.tab.tabIndex);
        if (_tabController.index != target) {
          _tabController.animateTo(target);
        }
      },
      child: SafeArea(
        child: Column(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(AppLocalizations.of(context)!.wallet, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Expanded(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.sessions, height: 30),
                  Tab(text: AppLocalizations.of(context)!.payments, height: 30),
                  if (F.showInvoices) ...[
                    Tab(text: AppLocalizations.of(context)!.invoices, height: 30),
                  ],
                ],
              ),
            ),
            Expanded(
                child: BlocBuilder<AuthCubit, AuthState>(buildWhen: (previous, current) {
              return previous.runtimeType != current.runtimeType;
            }, builder: (context, state) {
              return switch (state) {
                LoggedIn(profile: _, token: _, flow: _) => _loggedInTabBarView(context),
                _ => _loggedOutTabBarView(context),
              };
            }))
            ]))
          ]))
        ]),
      ),
    );
  }

  Widget _loggedInTabBarView(BuildContext context) {
    return TabBarView(controller: _tabController, children: [
      BlocProvider(
        create: (context) => getIt<SessionsCubit>(),
        child: const SessionsScreen(),
      ),
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => getIt<PaymentMethodsCubit>()),
          BlocProvider(create: (context) => getIt<AddCreditCardCubit>()),
        ],
        child: const PaymentMethodsScreen(),
      ),
      if (F.showInvoices) ...[
        BlocProvider(
          create: (context) => getIt<InvoicesCubit>(),
          child: const InvoicesScreen(),
        ),
      ],
    ]);
  }

  Widget _loggedOutTabBarView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TabBarView(controller: _tabController, children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.sessions, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              const SignupNowWidget(
                motivation: SignupNowMotivation.viewSessions,
                style: SignupNowStyle.extendedContainer,
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.paymentMethods, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              const SignupNowWidget(
                motivation: SignupNowMotivation.makePayments,
                style: SignupNowStyle.extendedContainer,
              ),
            ],
          ),
        ),
        if (F.showInvoices) ...[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(AppLocalizations.of(context)!.chargeCardInvoices, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 14),
                const SignupNowWidget(
                  motivation: SignupNowMotivation.viewInvoices,
                  style: SignupNowStyle.extendedContainer,
                ),
              ],
            ),
          ),
        ],
      ]),
    );
  }
}
