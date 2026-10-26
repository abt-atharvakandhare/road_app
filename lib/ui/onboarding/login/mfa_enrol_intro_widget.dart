import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'cubit/auth_cubit.dart';

/// Login-time enrolment interstitial: the Provider wants a sign-in factor.
/// Continuing sends the email-proof code; Skip only exists under Encourage.
class MfaEnrolIntroWidget extends StatelessWidget {
  const MfaEnrolIntroWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthEnrolIntro twoFactorAuth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSkip = twoFactorAuth.enrolment.mode == MfaMode.encourage;

    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(l10n.secureYourAccount, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            canSkip ? l10n.mfaEnrolExplanationEncourage : l10n.mfaEnrolExplanationEnforce,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          RMTextButton(
            isLoading: state.flow.isLoading,
            onPressed: () {
              BlocProvider.of<AuthCubit>(context).continueEnrolment();
            },
            text: l10n.continueStr,
          ),
          if (canSkip) ...[
            const SizedBox(height: 20),
            Center(
              child: Text.rich(TextSpan(
                text: l10n.skipForNow,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: RMColors.rmPrimaryColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _skip(context);
                  },
              )),
            ),
          ],
        ],
      );
    });
  }

  void _skip(BuildContext context) async {
    final didLogIn = await BlocProvider.of<AuthCubit>(context).skipEnrolment();
    if (didLogIn && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
