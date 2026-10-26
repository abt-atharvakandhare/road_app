import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'cubit/auth_cubit.dart';

/// Pick which factor type to enrol (shown when more than one is permitted).
class MfaEnrolMethodPickerWidget extends StatefulWidget {
  const MfaEnrolMethodPickerWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthEnrolMethodPicker twoFactorAuth;

  @override
  State<MfaEnrolMethodPickerWidget> createState() => _MfaEnrolMethodPickerWidgetState();
}

class _MfaEnrolMethodPickerWidgetState extends State<MfaEnrolMethodPickerWidget> {
  /// The method whose enrolment is in flight — only its button spins; the
  /// others are merely disabled.
  MfaMethod? _pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final twoFactorAuth = widget.twoFactorAuth;
    final usable = twoFactorAuth.enrolment.permittedMethods
        .usableOnMobile(passkeySupported: BlocProvider.of<AuthCubit>(context).passkeySupported);
    final canSkip = twoFactorAuth.enrolment.mode == MfaMode.encourage;

    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(l10n.secureYourAccount, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.chooseEnrolmentMethod, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          for (final method in usable) ...[
            RMTextButton(
              isLoading: state.flow.isLoading && method == _pending,
              onPressed: state.flow.isLoading
                  ? null
                  : () {
                      setState(() => _pending = method);
                      _choose(context, method);
                    },
              text: switch (method) {
                MfaMethod.totp => l10n.appAuthentication,
                MfaMethod.sms => l10n.smsAuthentication,
                MfaMethod.passkey => l10n.passkeyAuthentication,
                _ => '',
              },
            ),
            const SizedBox(height: 6),
            Text(
              switch (method) {
                MfaMethod.totp => l10n.securityCodesGeneratedByApp,
                MfaMethod.sms => l10n.securityCodesSentViaSms,
                MfaMethod.passkey => l10n.passkeySignInWithDevice,
                _ => '',
              },
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          if (canSkip) ...[
            const SizedBox(height: 8),
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

  void _choose(BuildContext context, MfaMethod method) async {
    final cubit = BlocProvider.of<AuthCubit>(context);
    // SMS enrolment can complete the sign-in immediately when the account
    // phone is already verified.
    await cubit.chooseEnrolMethod(method);
    // Clear the pending marker so a later loading phase started elsewhere
    // (e.g. "Skip for now" after an error) doesn't re-spin this button.
    if (mounted) setState(() => _pending = null);
    if (context.mounted && cubit.state.isLoggedIn) {
      Navigator.of(context).pop();
    }
  }

  void _skip(BuildContext context) async {
    final didLogIn = await BlocProvider.of<AuthCubit>(context).skipEnrolment();
    if (didLogIn && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
