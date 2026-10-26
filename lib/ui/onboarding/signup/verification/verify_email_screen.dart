import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/verify_code_widget.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/widgets/verification_step_indicator.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        if (state is! VerifyEmail) {
          return const SizedBox();
        }

        final email = state.email;
        final currentStep = state.currentStep;
        final totalSteps = state.totalSteps;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: VerificationStepIndicator(
                currentStep: currentStep,
                totalSteps: totalSteps,
                stepTitle: AppLocalizations.of(context)!.verifyEmailStepTitle,
              ),
            ),

            // Verification widget
            Expanded(
              child: VerifyCodeWidget(
                title: AppLocalizations.of(context)!.verifyYourEmailAddress,
                message: AppLocalizations.of(context)!.weSentYouAnEmailVerification(email),
                didntReceiveText: AppLocalizations.of(context)!.didntReceiveTheEmail,
                resendText: AppLocalizations.of(context)!.resendEmailVerificationLink,
                onVerifyCode: (code) async {
                  return await BlocProvider.of<SignupCubit>(context).verifyEmailCode(code);
                },
                onResendCode: () async {
                  final success = await BlocProvider.of<SignupCubit>(context).resendEmailCode();
                  if (success && context.mounted) {
                    showStyledSnackbar(
                      context,
                      SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                      AppLocalizations.of(context)!.codeResent,
                    );
                  }
                },
                isLoading: state.flow.isLoading,
              ),
            ),
          ],
        );
      },
    );
  }
}
