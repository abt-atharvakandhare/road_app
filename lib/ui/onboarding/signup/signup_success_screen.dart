import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

class SignupSuccessScreen extends StatelessWidget {
  const SignupSuccessScreen({super.key, required this.didLogin, required this.didAddPaymentCard});

  final bool didLogin;
  final bool didAddPaymentCard;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/signup_completed_tick.svg'),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.accountCreated, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            if (didLogin) ...[
              Text(AppLocalizations.of(context)!.weLoggedYouInAutomatically,
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 40),
            ],

            RMTextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: AppLocalizations.of(context)!.continueStr),

            // When we are asked to add a card in signup, the following code should do most if it.
            // if (didAddPaymentCard) ...[
            // Have loggedin, then added a card
            //   Text(AppLocalizations.of(context)!.cardSaved, style: Theme.of(context).textTheme.bodyMedium),
            //   const SizedBox(height: 20),
            //   Text(AppLocalizations.of(context)!.youCanNowStartYourFirstCharge,
            //       style: Theme.of(context).textTheme.labelMedium),
            //   const SizedBox(height: 28),
            //   RMTextButton(
            //       onPressed: () async {
            //         Navigator.of(context).pop();
            //       },
            //       text: AppLocalizations.of(context)!.continueStr),
            // ] else if (BlocProvider.of<AuthCubit>(context).state.canAddCreditCard) ...[
            //   // We have logged in, should now offer to add a card
            //   Text(AppLocalizations.of(context)!.accountCreated, style: Theme.of(context).textTheme.bodyMedium),
            //   const SizedBox(height: 20),
            //   Text(AppLocalizations.of(context)!.youCanNowAddAPaymentMethod,
            //       textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
            //   const SizedBox(height: 28),
            //   RMTextButton(
            //       onPressed: () async {
            //         final cardAdded = await BlocProvider.of<AddCreditCardCubit>(context)
            //             .addCardTapped(context, "Signup");
            //         if (cardAdded && context.mounted) {
            //           BlocProvider.of<SignupCubit>(context).cardWasAdded();
            //         }
            //       },
            //       text: AppLocalizations.of(context)!.addPaymentMethod),
            //   const SizedBox(height: 35),
            //   TextButton(
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //       },
            //       child: Text(AppLocalizations.of(context)!.skip))
            // ] else ...[
            //   // We can logged in, but cannot offer to add a card.
            //   Text(AppLocalizations.of(context)!.accountCreated, style: Theme.of(context).textTheme.bodyMedium),
            //   const SizedBox(height: 20),
            //   Text(AppLocalizations.of(context)!.weLoggedYouInAutomatically,
            //       style: Theme.of(context).textTheme.labelMedium),
            //   const SizedBox(height: 20),
            //   RMTextButton(
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //       },
            //       text: AppLocalizations.of(context)!.continueStr),
            // ]
          ],
        ),
      ),
    );
  }
}
