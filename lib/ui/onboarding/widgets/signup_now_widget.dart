import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/onboarding/login/login_screen.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '../signup/main_signup_screen.dart';

enum SignupNowMotivation { makePayments, viewSessions, viewInvoices, viewProfile }

enum SignupNowStyle { singleContainer, extendedContainer }

class SignupNowWidget extends StatelessWidget {
  const SignupNowWidget({super.key, required this.motivation, required this.style});

  final SignupNowMotivation motivation;
  final SignupNowStyle style;

  @override
  Widget build(BuildContext context) {
    final String headerIcon;
    final String headerText;
    switch (motivation) {
      case SignupNowMotivation.makePayments:
        headerIcon = 'assets/icons/signup_card.svg';
        headerText = AppLocalizations.of(context)!.viewYourChargeCards;
      case SignupNowMotivation.viewSessions:
        headerIcon = 'assets/icons/signup_sessions.svg';
        headerText = AppLocalizations.of(context)!.viewYourPreviousChargingSessions;
      case SignupNowMotivation.viewInvoices:
        headerIcon = 'assets/icons/signup_invoices.svg';
        headerText = AppLocalizations.of(context)!.viewInvoicesForYourChargeCards;
      case SignupNowMotivation.viewProfile:
        headerIcon = 'assets/icons/signup_profile.svg';
        headerText = AppLocalizations.of(context)!.viewYourProfileAndAccount;
    }

    final headerWidgets = [
      const SizedBox(height: 30),
      SvgPicture.asset(headerIcon),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(headerText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 20),
      const SizedBox(height: 24),
    ];

    final footerWidgets = [
      RMTextButton(
          onPressed: () async {
            await LoginScreen.pushAsModal(context);
          },
          text: AppLocalizations.of(context)!.login),
      const SizedBox(height: 20),
      Text(
        AppLocalizations.of(context)!.dontHaveAnAccount,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      TextButton(
          onPressed: () async {
            MainSignupScreen.pushAsModal(context);
          },
          child: Text(AppLocalizations.of(context)!.signup)),
      const SizedBox(height: 20),
    ];

    final Widget contentWidget;

    switch (style) {
      case SignupNowStyle.singleContainer:
        contentWidget = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: headerWidgets + footerWidgets),
        );
      case SignupNowStyle.extendedContainer:
        contentWidget = Column(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RMColors.containerBorderGrey),
              ),
              constraints: const BoxConstraints(minHeight: 200),
              child: Column(mainAxisSize: MainAxisSize.min, children: headerWidgets),
            ),
            const SizedBox(height: 24),
            ...footerWidgets
          ],
        );
    }

    return contentWidget;
  }
}
