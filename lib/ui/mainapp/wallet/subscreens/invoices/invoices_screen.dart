import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_shimmer_loader.dart';
import 'package:road_mobile/ui/utils/widgets/rm_year_picker.dart';

import 'invoice_item_widget.dart';
import 'cubit/invoices_cubit.dart';
import 'invoices_details_screen.dart';

class InvoicesScreen extends StatefulWidget {
  static void push(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: ((routeContext) {
      return BlocProvider(
        create: (context) => getIt<InvoicesCubit>(),
        child: const InvoicesScreen(),
      );
    })));
  }

  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        BlocProvider.of<InvoicesCubit>(context).loadMoreAllInvoices();
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
    return BlocConsumer<InvoicesCubit, InvoicesState>(listener: (context, state) {
      if (state.flow.isError) {
        getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
      }
    }, builder: (context, state) {
      final scrollChildren = _buildScrollChildren(context, state);
      return RefreshIndicator(
        onRefresh: () async {
          await BlocProvider.of<InvoicesCubit>(context).loadAllInvoices(false, yearFilter: state.allInvoicesYearFilter);
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
    });
  }

  List<Widget> _buildScrollChildren(BuildContext context, InvoicesState state) {
    final scrollChildren = <Widget>[];

    scrollChildren.add(const SizedBox(height: 24));
    scrollChildren.add(Text(AppLocalizations.of(context)!.chargeCardInvoices));
    scrollChildren.add(const SizedBox(height: 24));
    scrollChildren.add(_buildFilterButton(context, state));
    scrollChildren.add(const SizedBox(height: 20));
    scrollChildren.add(RMShimmerLoader(
      isLoading: state.flow.isLoading && (state.allInvoices == null || state.allInvoices!.isEmpty),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildInvoices(context, state)),
    ));
    scrollChildren.add(const SizedBox(height: 24));

    return scrollChildren;
  }

  Widget _buildFilterButton(BuildContext context, InvoicesState state) {
    return InkWell(
      onTap: () async {
        _selectYear(context, state);
      },
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: RMColors.separatorDarkGrey),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.allInvoicesYearFilter == null
                        ? AppLocalizations.of(context)!.filterByYear
                        : state.allInvoicesYearFilter!.year.toString(),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                IconButton(
                    icon: state.allInvoicesYearFilter == null
                        ? const Icon(Icons.expand_more_rounded)
                        : const Icon(Icons.close),
                    onPressed: () {
                      state.allInvoicesYearFilter == null
                          ? _selectYear(context, state)
                          : BlocProvider.of<InvoicesCubit>(context).loadAllInvoices(true);
                    })
              ],
            ),
          )),
    );
  }

  void _selectYear(BuildContext screenContext, InvoicesState state) async {
    showDialog(
        context: context,
        builder: (BuildContext dialogBuilderContext) {
          return RmYearPicker(
            initialYear: state.allInvoicesYearFilter?.year ?? DateTime.now().year,
            onYearSelected: (newYear) {
              BlocProvider.of<InvoicesCubit>(screenContext).loadAllInvoices(true, yearFilter: DateTime(newYear));
            },
          );
        });
  }

  List<Widget> _buildInvoices(BuildContext context, InvoicesState state) {
    if (state.allInvoices == null || state.allInvoices!.isEmpty == true) {
      return [
        Text(AppLocalizations.of(context)!.noInvoiceDataAvailable, style: Theme.of(context).textTheme.titleSmall)
      ];
    }

    List<Widget> invoiceWidgets = [];
    int? lastHeaderYearShown;

    for (var invoice in state.allInvoices!) {
      if (lastHeaderYearShown == null || (lastHeaderYearShown != invoice.year)) {
        invoiceWidgets.add(const SizedBox(height: 10));
        invoiceWidgets.add(Text(invoice.year.toString(), style: Theme.of(context).textTheme.headlineMedium));
        invoiceWidgets.add(const SizedBox(height: 20));
        lastHeaderYearShown = invoice.year;
      }

      invoiceWidgets.add(InvoiceItemWidget(
          invoice: invoice,
          isActive: false,
          onPressed: () {
            InvoiceDetailsScreen.push(context, invoice);
          }));
      invoiceWidgets.add(const SizedBox(height: 20));
      invoiceWidgets.add(const RMSeparator());

      final isLastInvoice = invoice == state.allInvoices!.last;
      if (!isLastInvoice) {
        invoiceWidgets.add(const SizedBox(height: 20));
      }
    }

    return invoiceWidgets;
  }
}
