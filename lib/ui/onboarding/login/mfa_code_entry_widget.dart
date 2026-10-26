import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_code_entry_card.dart';

import 'cubit/auth_cubit.dart';

/// Six-digit code entry for every decision-engine step that verifies a code:
/// pending TOTP / SMS, the email-verification step-up, the enrolment email
/// proof, and SMS enrolment confirmation. The pin, countdown and error
/// mechanics live in [MfaCodeEntryCard]; this wrapper derives the copy,
/// resend wiring and footer links from the active [TwoFactorAuth] member.
class MfaCodeEntryWidget extends StatelessWidget {
  const MfaCodeEntryWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuth twoFactorAuth;

  bool get _isSmsStep => twoFactorAuth is TwoFactorAuthPendingSms || twoFactorAuth is TwoFactorAuthEnrolSms;

  int? get _stateSendWait => switch (twoFactorAuth) {
        TwoFactorAuthPendingSms(:final nextSendAfterSeconds) ||
        TwoFactorAuthEnrolSms(:final nextSendAfterSeconds) ||
        TwoFactorAuthVerifyEmail(:final nextSendAfterSeconds) ||
        TwoFactorAuthEnrolEmailProof(:final nextSendAfterSeconds) =>
          nextSendAfterSeconds,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final headerText = switch (twoFactorAuth) {
      TwoFactorAuthPendingTotp() => l10n.enterTheSecurityCodeGenerated,
      TwoFactorAuthPendingSms(:final hint) || TwoFactorAuthEnrolSms(:final hint) =>
        '${l10n.weSentACodeToPhone(hint ?? '')}\n\n${l10n.enterThe6DigitCodeBelow}',
      TwoFactorAuthVerifyEmail(:final email) =>
        '${l10n.weSentACodeToEmail(email)}\n\n${l10n.enterThe6DigitCodeBelow}',
      TwoFactorAuthEnrolEmailProof(:final email) =>
        '${l10n.confirmYourEmailFirst} ${l10n.weSentACodeToEmail(email)}\n\n${l10n.enterThe6DigitCodeBelow}',
      _ => '',
    };

    final canResend = switch (twoFactorAuth) {
      TwoFactorAuthPendingTotp() => false,
      _ => true,
    };

    final canSwitchMethod = switch (twoFactorAuth) {
      TwoFactorAuthPendingTotp(:final challenge) ||
      TwoFactorAuthPendingSms(:final challenge) =>
        challenge.methods
                .usableOnMobile(passkeySupported: BlocProvider.of<AuthCubit>(context).passkeySupported)
                .length >
            1,
      _ => false,
    };

    final canUseRecoveryCode = switch (twoFactorAuth) {
      TwoFactorAuthPendingTotp(:final challenge) ||
      TwoFactorAuthPendingSms(:final challenge) =>
        challenge.canUseRecoveryCode == true,
      _ => false,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const SizedBox(height: 20),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return MfaCodeEntryCard(
                header: headerText,
                nextSendAfterSeconds: _stateSendWait,
                isLoading: state.flow.isLoading,
                smsAutofill: _isSmsStep,
                crossAxisAlignment: CrossAxisAlignment.center,
                onSubmit: (code) => _submitCode(context, code),
                onResend: canResend ? () => _resendCode(context) : null,
                footer: [
                  if (canSwitchMethod)
                    _footerLink(
                      context,
                      text: '',
                      linkText: l10n.useDifferentVerificationMethod,
                      onTap: () => BlocProvider.of<AuthCubit>(context).backToMfaMethodPicker(),
                    ),
                  if (canUseRecoveryCode)
                    _footerLink(
                      context,
                      text: '${l10n.isThisAuthMethodNotWorking} ',
                      linkText: l10n.useRecoveryCode,
                      onTap: () => BlocProvider.of<AuthCubit>(context).useRecoveryCode(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    );
  }

  Widget _footerLink(BuildContext context,
      {required String text, required String linkText, required VoidCallback onTap}) {
    return Text.rich(TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
      TextSpan(text: text),
      TextSpan(
        text: linkText,
        style: TextStyle(color: RMColors.rmPrimaryColor),
        recognizer: TapGestureRecognizer()..onTap = onTap,
      ),
    ]));
  }

  Future<void> _resendCode(BuildContext context) async {
    final cubit = BlocProvider.of<AuthCubit>(context);
    switch (twoFactorAuth) {
      case TwoFactorAuthPendingSms():
        await cubit.resendPendingSmsCode();
      case TwoFactorAuthEnrolSms():
        await cubit.resendEnrolmentSmsCode();
      case TwoFactorAuthVerifyEmail():
        await cubit.resendVerifyEmailCode();
      case TwoFactorAuthEnrolEmailProof():
        await cubit.resendEnrolmentEmailProof();
      default:
        return;
    }
  }

  Future<TwoFactorAuthResult> _submitCode(BuildContext context, String code) async {
    final cubit = BlocProvider.of<AuthCubit>(context);
    final result = switch (twoFactorAuth) {
      TwoFactorAuthEnrolEmailProof() => await cubit.verifyEnrolmentEmailProof(code),
      TwoFactorAuthEnrolSms() => await cubit.verifyEnrolmentCode(code),
      _ => await cubit.verifyPendingMfaCode(code),
    };

    if (context.mounted && cubit.state.isLoggedIn) {
      Navigator.of(context).pop();
    }
    return result;
  }
}
