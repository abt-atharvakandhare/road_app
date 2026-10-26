import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'wallet_navigation_state.dart';
part 'wallet_navigation_cubit.freezed.dart';

/// External nav intents for the Wallet bottom-nav section. The wallet has its
/// own inner `TabController` (Sessions / Payment methods / Invoices); this
/// cubit lets non-widget callers (e.g. the notification handler) request a
/// particular sub-tab and force a data refresh.
///
/// `refreshNonce` is incremented on every request so listeners can distinguish
/// repeated identical requests (e.g. two `charging.session.ended` taps in a
/// row both landing the user on the Sessions tab with fresh data each time).
@lazySingleton
class WalletNavigationCubit extends Cubit<WalletNavigationState> {
  WalletNavigationCubit() : super(const WalletNavigationState(tab: WalletTab.sessions, refreshNonce: 0));

  void requestShowSessions() {
    emit(WalletNavigationState(tab: WalletTab.sessions, refreshNonce: state.refreshNonce + 1));
  }
}

enum WalletTab {
  sessions,
  paymentMethods,
  invoices;

  int get tabIndex => switch (this) {
        WalletTab.sessions => 0,
        WalletTab.paymentMethods => 1,
        WalletTab.invoices => 2,
      };
}
