import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/rm_loader.dart';
import 'package:road_mobile/ui/utils/widgets/rm_active_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_destructive_confirmation_sheet.dart';

import '../../../../utils/colors.dart';

class EditPaymentMethodScreen extends StatefulWidget {
  const EditPaymentMethodScreen({super.key, required this.card});
  final UnifiedPaymentCard card;

  static Future<bool?> push(BuildContext context, UnifiedPaymentCard card) async {
    return Navigator.push<bool>(context, MaterialPageRoute(builder: ((routeContext) {
      return MultiBlocProvider(
          providers: [BlocProvider.value(value: BlocProvider.of<PaymentMethodsCubit>(context))],
          child: EditPaymentMethodScreen(card: card));
    })));
  }

  @override
  State<StatefulWidget> createState() => _EditPaymentMethodScreenState();
}

class _EditPaymentMethodScreenState extends State<EditPaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(listener: (context, state) {
      if (state.flow.isError) {
        getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
      }
    }, builder: (context, state) {
      final scrollChildren = _buildScrollChildren(context);
      return RMLoader(
        isLoading: state.flow.isLoading,
        child: Scaffold(
            appBar: AppBar(
                leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            )),
            body: ListView.builder(
              itemCount: scrollChildren.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: scrollChildren[index],
                );
              },
            )),
      );
    });
  }

  List<Widget> _buildScrollChildren(BuildContext context) {
    final scrollChildren = <Widget>[];

    scrollChildren.addAll([
      Text(AppLocalizations.of(context)!.editPaymentMethod, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 40),
      if (widget.card.underlyingCardType == UnderlyingCardType.creditCard)
        ..._buildCreditCardWidgets(context)
      else if (widget.card.underlyingCardType == UnderlyingCardType.rfidCard)
        ..._buildRfidCardWidgets(context)
    ]);

    return scrollChildren;
  }

  List<Widget> _buildCreditCardWidgets(BuildContext context) {
    return [
      Text(AppLocalizations.of(context)!.creditOrDebitCard, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 20),
      RMCardDisplayWidget(paymentInstrument: widget.card, showSeparator: false),
      const SizedBox(height: 10),
      const RMSeparator(),
      const SizedBox(height: 20),
      TextButton(
          onPressed: () async {
            final confirmed = await RMDestructiveConfirmationSheet.show(
              context: context,
              title: AppLocalizations.of(context)!.removeCard,
              message:
                  '${AppLocalizations.of(context)!.areYouSureYouWantToRemoveCard} ${widget.card.visibleCardType(context)}?',
              confirmationButtonText: AppLocalizations.of(context)!.yesRemoveCard,
              cancelButtonText: AppLocalizations.of(context)!.cancel,
              warningText: AppLocalizations.of(context)!.thisActionCannotBeReversed,
            );

            if (confirmed && context.mounted) {
              final deleted = await BlocProvider.of<PaymentMethodsCubit>(context).deleteCard(widget.card);
              if (deleted && context.mounted) {
                Navigator.of(context).pop(true);
              }
            }
          },
          child: Text(
            AppLocalizations.of(context)!.removeCard,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: RMColors.destructiveRed),
          )),
    ];
  }

  List<Widget> _buildRfidCardWidgets(BuildContext context) {
    final isActive = widget.card.rfidCard?.token?.isActive ?? false;
    return [
      Text('${F.appBrandName} ${AppLocalizations.of(context)!.card}', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 20),
      Text(
        AppLocalizations.of(context)!.nameOnCard,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 10),
      Text(widget.card.rfidCard?.nameOnCard ?? '-', style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 20),
      Text(AppLocalizations.of(context)!.identifier, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 10),
      Text(widget.card.rfidCard?.token?.visualNumber ?? widget.card.rfidCard?.id ?? '-',
          style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 20),
      Text(AppLocalizations.of(context)!.billingPlan, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 10),
      Text(widget.card.rfidCard?.billingPlan?.name ?? '-', style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 20),
      Text(AppLocalizations.of(context)!.status, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 10),
      ActiveWidget(isActive: isActive),
      const SizedBox(height: 30),
      const RMSeparator(),
      const SizedBox(height: 20),
      // ToDo - get block / unblock endpoints working
      // TextButton(
      //     onPressed: () {
      //       showModalBottomSheet(
      //           useRootNavigator: true,
      //           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      //           context: context,
      //           builder: (sheetContext) {
      //             final cardWarningAndType =
      //                 '${AppLocalizations.of(sheetContext)!.areYouSureYouWantToBlockCardFrom} ${widget.card.rfidCard?.nameOnCard}?';
      //             return SafeArea(
      //               child: Padding(
      //                 padding: const EdgeInsets.symmetric(horizontal: 24),
      //                 child: Column(
      //                   mainAxisSize: MainAxisSize.min,
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     const SizedBox(height: 16),
      //                     const RMDrawerHandle(),
      //                     const SizedBox(height: 16),
      //                     Text(AppLocalizations.of(sheetContext)!.blockCard,
      //                         style: Theme.of(sheetContext).textTheme.bodyMedium),
      //                     const SizedBox(height: 16),
      //                     Text(cardWarningAndType, style: Theme.of(sheetContext).textTheme.labelMedium),
      //                     const SizedBox(height: 16),
      //                     RMTextButton(
      //                       onPressed: () async {
      //                         Navigator.of(sheetContext).pop(); // Dismiss sheet

      //                         final deleted = await BlocProvider.of<WalletCubit>(context).blockCard(widget.card);
      //                       },
      //                       text: AppLocalizations.of(sheetContext)!.yesBlockCard,
      //                       backgroundColor: RMColors.destructiveRed,
      //                     ),
      //                     const SizedBox(height: 16),
      //                     Center(
      //                         child: TextButton(
      //                             onPressed: () {
      //                               Navigator.of(sheetContext).pop();
      //                             },
      //                             child: Text(AppLocalizations.of(sheetContext)!.cancel)))
      //                   ],
      //                 ),
      //               ),
      //             );
      //           });
      //     },
      //     child: Text(
      //       AppLocalizations.of(context)!.blockCard,
      //       style: Theme.of(context).textTheme.titleSmall?.copyWith(color: RMColors.destructiveRed),
      //     )),
    ];
  }
}
