import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'cubit/auth_cubit.dart';

/// Login-time enrolment: create a passkey to finish the sign-in. The OS
/// ceremony is auto-started once on arrival; afterwards every attempt is
/// user-initiated via the button (each attempt re-begins — creation
/// challenges are single-use). A dismissed OS sheet is silent; a device that
/// already holds a passkey for the account swaps in explanatory copy.
class MfaEnrolPasskeyWidget extends StatefulWidget {
  const MfaEnrolPasskeyWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthEnrolPasskey twoFactorAuth;

  @override
  State<StatefulWidget> createState() => _MfaEnrolPasskeyWidgetState();
}

class _MfaEnrolPasskeyWidgetState extends State<MfaEnrolPasskeyWidget> {
  @override
  void initState() {
    super.initState();
    if (!widget.twoFactorAuth.deviceHasPasskey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _enrol();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<AuthCubit>(context);
    final canSwitchMethod = widget.twoFactorAuth.enrolment.permittedMethods
            .usableOnMobile(passkeySupported: cubit.passkeySupported)
            .length >
        1;
    final canSkip = widget.twoFactorAuth.enrolment.mode == MfaMode.encourage;

    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(l10n.mfaEnrolPasskeyTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            widget.twoFactorAuth.deviceHasPasskey
                ? l10n.mfaPasskeyAlreadyOnDevice
                : l10n.mfaEnrolPasskeyExplanation,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          RMTextButton(
            isLoading: state.flow.isLoading,
            onPressed: () {
              _enrol();
            },
            text: l10n.mfaEnrolPasskeyButton,
          ),
          if (canSwitchMethod) ...[
            const SizedBox(height: 20),
            Center(
              child: _link(
                context,
                text: l10n.useDifferentVerificationMethod,
                onTap: () => BlocProvider.of<AuthCubit>(context).backToEnrolMethodPicker(),
              ),
            ),
          ],
          if (canSkip) ...[
            const SizedBox(height: 20),
            Center(
              child: _link(
                context,
                text: l10n.skipForNow,
                onTap: () {
                  _skip(context);
                },
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _link(BuildContext context, {required String text, required VoidCallback onTap}) {
    return Text.rich(TextSpan(
      text: text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: RMColors.rmPrimaryColor),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    ));
  }

  void _enrol() async {
    final cubit = BlocProvider.of<AuthCubit>(context);
    await cubit.enrolWithPasskey();
    if (mounted && cubit.state.isLoggedIn) {
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
