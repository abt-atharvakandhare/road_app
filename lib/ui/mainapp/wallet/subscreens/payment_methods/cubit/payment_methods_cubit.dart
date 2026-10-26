import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/cubit/payment_methods_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'payment_methods_state.dart';
part 'payment_methods_cubit.freezed.dart';

@injectable
class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit(this._chargeNowRepository, this._paymentMethodsRepository)
      : super(const PaymentMethodsState.paymentMethods()) {
    updatePaymentMethods(true);
  }

  final ChargeNowRepository _chargeNowRepository;
  final PaymentMethodsRepository _paymentMethodsRepository;

  Future<void> updatePaymentMethods(bool fullLoadingState) async {
    if (fullLoadingState) {
      emit(state.copyWith(flow: const UIFlow.loading()));
    }

    try {
      final cards = await _chargeNowRepository.getMyPaymentCards(true, true);

      if (isClosed) {
        return;
      }
      emit(state.copyWith(cards: cards, flow: const UIFlow.established()));
    } on RMApiError catch (e) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<bool> updateCards() async {
    emit(state.copyWith(flow: const UIFlow.loading()));

    try {
      final cards = await _chargeNowRepository.getMyPaymentCards(true, true);
      emit(state.copyWith(flow: const UIFlow.established(), cards: cards));
      return true;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> deleteCard(UnifiedPaymentCard card) async {
    try {
      final creditCard = card.paymentCard;
      if (creditCard == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Missing instrument ID.'))));
        return false;
      }

      emit(state.copyWith(flow: const UIFlow.loading()));
      final deleteSuccess = await _paymentMethodsRepository.deleteCard(creditCard.id);
      if (deleteSuccess) {
        final cards = await _chargeNowRepository.getMyPaymentCards(true, true);
        emit(state.copyWith(flow: const UIFlow.established(), cards: cards));
        return true;
      } else {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to delete card.'))));
        return false;
      }
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> blockCard(UnifiedPaymentCard card) async {
    try {
      final tokenId = card.rfidCard?.token?.id;
      if (tokenId == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Missing rfid card ID.'))));
        return false;
      }

      emit(state.copyWith(flow: const UIFlow.loading()));
      final blockSuccess = await _paymentMethodsRepository.blockCard(tokenId);
      if (blockSuccess) {
        final cards = await _chargeNowRepository.getMyPaymentCards(true, true);
        emit(state.copyWith(flow: const UIFlow.established(), cards: cards));
        return true;
      } else {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to block card.'))));
        return false;
      }
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> unblockCard(UnifiedPaymentCard card) async {
    try {
      final tokenId = card.rfidCard?.token?.id;
      if (tokenId == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Missing rfid card ID.'))));
        return false;
      }

      emit(state.copyWith(flow: const UIFlow.loading()));
      final unblockSuccess = await _paymentMethodsRepository.unblockCard(tokenId);
      if (unblockSuccess) {
        final cards = await _chargeNowRepository.getMyPaymentCards(true, true);
        emit(state.copyWith(flow: const UIFlow.established(), cards: cards));
        return true;
      } else {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to unblock card.'))));
        return false;
      }
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }
}
