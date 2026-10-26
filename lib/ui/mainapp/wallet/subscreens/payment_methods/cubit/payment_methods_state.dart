part of 'payment_methods_cubit.dart';

@freezed
sealed class PaymentMethodsState with _$PaymentMethodsState {
  const factory PaymentMethodsState.paymentMethods({
    UnifiedPaymentCards? cards,
    @Default(UIFlow.established()) UIFlow flow,
  }) = PaymentMethods;
}
