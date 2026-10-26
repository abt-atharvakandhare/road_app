import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/verify_code_widget.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/widgets/verification_step_indicator.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';

class VerifyPhoneScreen extends StatelessWidget {
  const VerifyPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        if (state is! VerifyPhone) {
          return const SizedBox();
        }

        final phoneNumber = state.phoneNumber;
        final currentStep = state.currentStep;
        final totalSteps = state.totalSteps;

        return Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: VerificationStepIndicator(
                currentStep: currentStep,
                totalSteps: totalSteps,
                stepTitle: AppLocalizations.of(context)!.verifyPhoneStepTitle,
              ),
            ),

            // Verification widget
            Expanded(
              child: VerifyCodeWidget(
                title: AppLocalizations.of(context)!.verifyYourPhoneNumberNow,
                message: AppLocalizations.of(context)!.weSentYouAndSmsFullNumber(phoneNumber),
                onVerifyCode: (code) async {
                  return await BlocProvider.of<SignupCubit>(context).verifyPhoneCode(code);
                },
                onResendCode: () async {
                  final success = await BlocProvider.of<SignupCubit>(context).resendPhoneCode();
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
