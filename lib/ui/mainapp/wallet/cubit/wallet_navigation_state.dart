part of 'wallet_navigation_cubit.dart';

@freezed
abstract class WalletNavigationState with _$WalletNavigationState {
  const factory WalletNavigationState({
    required WalletTab tab,
    required int refreshNonce,
  }) = _WalletNavigationState;
}
