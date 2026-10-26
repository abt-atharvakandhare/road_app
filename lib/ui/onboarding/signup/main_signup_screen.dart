import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_cubit.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';

import 'cubit/signup_cubit.dart';
import 'first_signup_screen.dart';
import 'mfa_setup_widget.dart';
import 'verification/verify_phone_screen.dart';
import 'verification/verify_email_screen.dart';

class MainSignupScreen extends StatefulWidget {
  const MainSignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainSignupScreenState();

  static Future<void> pushAsModal(BuildContext context) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);

    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: ((routeContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<SignupCubit>()),
            BlocProvider.value(value: BlocProvider.of<LocationBloc>(context)),
            BlocProvider.value(value: authCubit),
          ],
          child: const MainSignupScreen(),
        );
      }),
    ));

    // Refresh account details after signup flow completes to update verification status
    if (authCubit.state is LoggedIn) {
      await authCubit.refreshAccountDetails();
    }
  }
}

class _MainSignupScreenState extends State<MainSignupScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize SignupCubit with provider model from AuthCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signupCubit = BlocProvider.of<SignupCubit>(context);
      signupCubit.trackOnboardingStarted();
      final authState = BlocProvider.of<AuthCubit>(context).state;
      if (authState is LoggedOut) {
        signupCubit.initializeWithProvider(authState.providerModel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) async {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
        if (state is OfferAddPayment) {
          final ccCubit = getIt<AddCreditCardCubit>();
          await ccCubit.startAddPaymentMethodFlow(
            context,
            'signup',
            currentStep: state.currentStep,
            totalSteps: state.totalSteps,
          );

          if (context.mounted) {
            // Web order (spec §19): the Secure Sign-in step follows the
            // payment step; the cubit decides whether it was frozen in.
            BlocProvider.of<SignupCubit>(context).advanceFromPayment();
          }
        }
        if (state is SignupCompleted) {
          if (!context.mounted) return;
          BlocProvider.of<SignupCubit>(context).trackOnboardingCompleted();
          Navigator.of(context).pop();
          showStyledSnackbar(
            context,
            SvgPicture.asset('assets/icons/snackbar_success_celebrate.svg'),
            AppLocalizations.of(context)!.accountCreatedWelcomeOnBoard,
          );
        }
      },
      builder: (context, state) {
        return _buildScreen(context, state);
      },
    );
  }

  Widget _buildScreen(BuildContext context, SignupState state) {
    // The account exists by these steps — leaving is completion, not abandon.
    final isPostAccountStep = state is VerifyPhone || state is VerifyEmail || state is OfferMfaSetup;
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: !isPostAccountStep,
            leading: isPostAccountStep
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
            actions: state is OfferMfaSetup
                ? [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        // Closing the step is skipping it: complete the
                        // journey properly (tracking, pop, welcome snackbar).
                        BlocProvider.of<SignupCubit>(context).completeMfaSetup(skipped: true);
                      },
                    ),
                  ]
                : state is VerifyPhone || state is VerifyEmail
                ? [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        // Log abandonment based on verification state
                        final analytics = getIt<Analytics>();
                        if (state is VerifyPhone) {
                          analytics.logVerificationEvent(
                            VerificationAnalyticsType.phoneVerificationAbandoned,
                            verificationType: 'mobile',
                            context: 'signup',
                          );
                        } else if (state is VerifyEmail) {
                          analytics.logVerificationEvent(
                            VerificationAnalyticsType.emailVerificationAbandoned,
                            verificationType: 'email',
                            context: 'signup',
                          );
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ]
                : null),
        body: switch (state) {
          CreateAccount() => const FirstSignupScreen(),
          VerifyPhone() => const VerifyPhoneScreen(),
          VerifyEmail() => const VerifyEmailScreen(),
          OfferAddPayment() => const FirstSignupScreen(),
          OfferMfaSetup() => const MfaSetupWidget(),
          SignupCompleted() => const SizedBox(),
        });
  }
}
