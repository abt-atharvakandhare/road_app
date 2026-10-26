part of 'add_credit_card_cubit.dart';

@freezed
sealed class AddCreditCardState with _$AddCreditCardState {
  const factory AddCreditCardState.initial({@Default(UIFlow.established()) UIFlow flow}) = Initial;
  const factory AddCreditCardState.addingCard({@Default(UIFlow.established()) UIFlow flow}) = AddingCard;
  const factory AddCreditCardState.cardAdded(
      {required String sourceWidget, @Default(UIFlow.established()) UIFlow flow}) = CardAdded;
}
