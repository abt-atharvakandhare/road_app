import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_cubit.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/cubit/payment_methods_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_shimmer_loader.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'edit_payment_method_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  static const walletSource = "Wallet";

  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCreditCardCubit, AddCreditCardState>(
      listener: (addCreditCardContext, addCreditCardState) {
        if (addCreditCardState.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, addCreditCardState.flow.error);
        }
        final state = BlocProvider.of<AddCreditCardCubit>(context).state;
        switch (state) {
          case CardAdded(:final sourceWidget):
            BlocProvider.of<PaymentMethodsCubit>(context).updateCards().then((_) {
              if (sourceWidget == walletSource && context.mounted) {
                showStyledSnackbar(
                  context,
                  SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                  AppLocalizations.of(context)!.cardSaved,
                );
              }
            });
          default:
            break;
        }
      },
      builder: (context, state) {
        return BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
          listener: (addCreditCardContext, addCreditCardState) {
            if (addCreditCardState.flow.isError) {
              getIt<ModalInfoDialogs>().showErrorDialog(context, addCreditCardState.flow.error);
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<PaymentMethodsCubit>(context).updatePaymentMethods(false);
              },
              // LayoutBuilder + minHeight: constraints.maxHeight forces the content to be
              // at least as tall as the viewport, so pull-to-refresh works on the empty
              // space below the card list — not only on the visible items.
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(AppLocalizations.of(context)!.paymentMethods, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 14),
                          RMShimmerLoader(
                            isLoading: state.flow.isLoading,
                            child:
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildCards(context, state)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildCards(BuildContext context, PaymentMethodsState state) {
    List<Widget> cardWidgets = [];

    if (state.cards == null || state.cards!.paymentCards.isEmpty) {
      cardWidgets.add(Text(AppLocalizations.of(context)!.youDontHaveAnyPaymentMethodsYet,
          style: Theme.of(context).textTheme.titleSmall));
    } else {
      for (var card in state.cards!.paymentCards) {
        cardWidgets.add(RMCardDisplayWidget(
            paymentInstrument: card,
            showSeparator: false,
            onPressed: () async {
              final cardDeleted = await EditPaymentMethodScreen.push(context, card);
              if (cardDeleted == true && context.mounted) {
                showStyledSnackbar(
                  context,
                  SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                  AppLocalizations.of(context)!.cardRemoved,
                );
              }
            }));
        cardWidgets.add(const RMSeparator());
      }
    }

    if (BlocProvider.of<AuthCubit>(context).state.canAddCreditCard) {
      cardWidgets.add(TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () async {
          await BlocProvider.of<AddCreditCardCubit>(context).startAddPaymentMethodFlow(context, walletSource);
        },
        child: Text('+ ${AppLocalizations.of(context)!.addPaymentMethod.capitalized}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: RMColors.rmPrimaryColor)),
      ));
    }

    return cardWidgets;
  }
}
