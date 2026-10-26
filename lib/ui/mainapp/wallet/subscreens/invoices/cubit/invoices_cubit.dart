import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/invoices/invoices_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

import 'invoices_repository.dart';

part 'invoices_state.dart';
part 'invoices_cubit.freezed.dart';

@injectable
class InvoicesCubit extends Cubit<InvoicesState> {
  InvoicesCubit(this._invoicesRepository) : super(const InvoicesState.initial()) {
    loadAllInvoices(true);
  }

  final InvoicesRepository _invoicesRepository;

  int? allInvoicesLimit;
  int? allInvoicesSkip;
  int? allInvoicesTotal;
  Future<void> loadAllInvoices(bool fullLoadingState, {DateTime? yearFilter}) async {
    try {
      if (fullLoadingState) {
        emit(state.copyWith(flow: const UIFlow.loading()));
      }
      final invoices = await _invoicesRepository.listInvoices(yearFilter: yearFilter?.year);

      allInvoicesLimit = invoices.meta.limit;
      allInvoicesSkip = invoices.meta.skip;
      allInvoicesTotal = invoices.meta.total;

      if (isClosed) {
        return;
      }

      emit(state.copyWith(
          allInvoices: invoices.data, allInvoicesYearFilter: yearFilter, flow: const UIFlow.established()));
    } on RMApiError catch (e) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<void> loadMoreAllInvoices() async {
    // Prevent duplicate loads while already loading
    if (state.flow.isLoading) {
      log('Already loading invoices, skipping');
      return;
    }

    final allInvoices = state.allInvoices;
    if (allInvoices == null || allInvoices.isEmpty) {
      log('No invoices to load more');
      return;
    }

    if (allInvoices.length >= (allInvoicesTotal ?? 0)) {
      log('No more invoices to load');
      return;
    }

    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final InvoicesResponseModel invoices = await _invoicesRepository.listInvoices(
          yearFilter: state.allInvoicesYearFilter?.year, skip: allInvoices.length);

      allInvoicesLimit = invoices.meta.limit;
      allInvoicesSkip = invoices.meta.skip;
      allInvoicesTotal = invoices.meta.total;

      if (isClosed) {
        return;
      }

      emit(state.copyWith(allInvoices: [...allInvoices, ...invoices.data], flow: const UIFlow.established()));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }
}
