part of 'invoices_cubit.dart';

@freezed
sealed class InvoicesState with _$InvoicesState {
  const factory InvoicesState.initial({
    List<InvoiceModel>? allInvoices,
    DateTime? allInvoicesYearFilter,
    @Default(UIFlow.established()) UIFlow flow,
  }) = Initial;
}
