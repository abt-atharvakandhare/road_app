import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_mfa_setup_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/step_up/run_with_step_up.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_code_entry_card.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_option_row.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_sub_flow.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/totp_setup_card.dart';

/// The signup "Secure Sign-in" step (spec §19): a row per permitted factor
/// with set-up sub-flows, mirroring web's `twoFactorSetup`. Leaving the step
/// (Continue / Skip) is the hosting [SignupCubit]'s transition.
class MfaSetupWidget extends StatelessWidget {
  const MfaSetupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignupMfaSetupCubit>(),
      child: BlocConsumer<SignupMfaSetupCubit, SignupMfaSetupState>(
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: switch (state) {
                MfaSetupMethodList(:final factors) => _MethodList(factors: factors),
                MfaSetupEmailProof(:final nextSendAfterSeconds) => MfaSubFlow(
                    onBack: () => BlocProvider.of<SignupMfaSetupCubit>(context).backToList(),
                    child: MfaCodeEntryCard(
                      header: _emailProofHeader(context),
                      nextSendAfterSeconds: nextSendAfterSeconds,
                      isLoading: state.flow.isLoading,
                      onSubmit: (code) => runWithStepUpVerify(context,
                          () => BlocProvider.of<SignupMfaSetupCubit>(context).verifyEmailProofCode(code)),
                      onResend: () => BlocProvider.of<SignupMfaSetupCubit>(context).resendEmailProof(),
                    ),
                  ),
                MfaSetupTotp(:final totp) => MfaSubFlow(
                    onBack: () => BlocProvider.of<SignupMfaSetupCubit>(context).backToList(),
                    title: AppLocalizations.of(context)!.appAuthentication,
                    child: TotpSetupCard(
                      otpauthUri: totp.otpauthUri,
                      secret: totp.secret,
                      isLoading: state.flow.isLoading,
                      onSubmitCode: (code) => runWithStepUpVerify(context,
                          () => BlocProvider.of<SignupMfaSetupCubit>(context).activateTotpCode(code)),
                    ),
                  ),
                MfaSetupSmsVerify(:final hint, :final nextSendAfterSeconds) => MfaSubFlow(
                    onBack: () => BlocProvider.of<SignupMfaSetupCubit>(context).backToList(),
                    child: MfaCodeEntryCard(
                      header: _smsHeader(context, hint),
                      nextSendAfterSeconds: nextSendAfterSeconds,
                      isLoading: state.flow.isLoading,
                      smsAutofill: true,
                      onSubmit: (code) => runWithStepUpVerify(context,
                          () => BlocProvider.of<SignupMfaSetupCubit>(context).verifySmsCode(code)),
                      onResend: () => runWithStepUpOrNull(context,
                          () => BlocProvider.of<SignupMfaSetupCubit>(context).resendSmsCode()),
                    ),
                  ),
                // Settings-only states of the shared enrolment machine; the
                // signup cubit never emits them.
                MfaSetupRecoveryCodes() ||
                MfaSetupRecoveryEmailEntry() ||
                MfaSetupRecoveryEmailVerify() =>
                  const SizedBox.shrink(),
              },
            ),
          );
        },
      ),
    );
  }

  static String _emailProofHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = BlocProvider.of<SignupCubit>(context).signupEmail;
    return [
      l10n.confirmYourEmailFirst,
      if (email != null) l10n.weSentACodeToEmail(email),
      l10n.enterThe6DigitCodeBelow,
    ].join('\n\n');
  }

  static String _smsHeader(BuildContext context, String? hint) {
    final l10n = AppLocalizations.of(context)!;
    return '${l10n.weSentACodeToPhone(hint ?? '')}\n\n${l10n.enterThe6DigitCodeBelow}';
  }
}

class _MethodList extends StatelessWidget {
  const _MethodList({required this.factors});

  final MfaFactorsModel? factors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final available = factors;

    if (available == null) {
      return const Center(
          child: Padding(padding: EdgeInsets.only(top: 80), child: CircularProgressIndicator()));
    }

    final offered = available.permittedMethods.usableOnMobile(
        passkeySupported: BlocProvider.of<SignupMfaSetupCubit>(context).passkeySupported);
    final hasFactor = available.hasActiveLoginFactor;

    MfaFactorModel? activeOf(MfaMethod method) => available.factors
        .where((f) => f.type == method && f.status == MfaFactorStatus.active)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.secureYourAccount, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(l10n.mfaSetupIntro, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        for (final method in offered) ...[
          _MethodRow(method: method, active: activeOf(method)),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        const RMSeparator(),
        const SizedBox(height: 20),
        RMTextButton(
          isLoading: false,
          onPressed: () {
            BlocProvider.of<SignupCubit>(context).completeMfaSetup(skipped: !hasFactor);
          },
          text: hasFactor ? l10n.continueStr : l10n.skipForNow,
        ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({required this.method, required this.active});

  final MfaMethod method;
  final MfaFactorModel? active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final title = switch (method) {
      MfaMethod.totp => l10n.mfaSetupAuthenticatorTitle,
      MfaMethod.sms => l10n.mfaSetupSmsTitle,
      MfaMethod.passkey => l10n.passkeyAuthentication,
      _ => '',
    };
    final enrolled = active != null;
    final caption = enrolled ? (active?.hint ?? l10n.mfaSetupEnabled) : l10n.mfaSetupNotSetUp;

    // The auto-enrolled SMS factor is shown, not managed — management (and
    // removal) is the settings surface's job.
    final canSetUp = !enrolled;

    return MfaOptionRow(
      title: title,
      caption: caption,
      trailing: canSetUp
          ? MfaRowActionButton(
              text: l10n.mfaSetupSetUp,
              onPressed: () => runWithStepUpOrNull(
                  context, () => BlocProvider.of<SignupMfaSetupCubit>(context).setUpMethod(method)),
            )
          : Icon(Icons.check_circle, color: RMColors.rmGreen),
    );
  }
}
