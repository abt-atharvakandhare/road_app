import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'cubit/auth_cubit.dart';

/// Verify the sign-in with a passkey. The OS ceremony is auto-started once on
/// arrival; afterwards every attempt is user-initiated via the button (each
/// attempt re-arms — ceremony ids are single-use). A dismissed OS sheet is
/// silent per §5.1b; a device without the credential swaps in dead-end copy
/// when no other factor absorbed the fallback.
class MfaPasskeyWidget extends StatefulWidget {
  const MfaPasskeyWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthPendingPasskey twoFactorAuth;

  @override
  State<StatefulWidget> createState() => _MfaPasskeyWidgetState();
}

class _MfaPasskeyWidgetState extends State<MfaPasskeyWidget> {
  @override
  void initState() {
    super.initState();
    if (!widget.twoFactorAuth.noCredential) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _verify();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<AuthCubit>(context);
    final canSwitchMethod = widget.twoFactorAuth.challenge.methods
            .usableOnMobile(passkeySupported: cubit.passkeySupported)
            .length >
        1;
    final canUseRecoveryCode = widget.twoFactorAuth.challenge.canUseRecoveryCode == true;

    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(l10n.mfaPasskeyTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            widget.twoFactorAuth.noCredential ? l10n.mfaPasskeyNoCredential : l10n.mfaPasskeyExplanation,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          RMTextButton(
            isLoading: state.flow.isLoading,
            onPressed: () {
              _verify();
            },
            text: l10n.mfaPasskeyButton,
          ),
          if (canSwitchMethod || canUseRecoveryCode) ...[
            const SizedBox(height: 30),
            const RMSeparator(),
            const SizedBox(height: 12),
          ],
          if (canSwitchMethod) ...[
            _footerLink(
              context,
              text: '',
              linkText: l10n.useDifferentVerificationMethod,
              onTap: () => BlocProvider.of<AuthCubit>(context).backToMfaMethodPicker(),
            ),
            const SizedBox(height: 16),
          ],
          if (canUseRecoveryCode)
            _footerLink(
              context,
              text: '${l10n.isThisAuthMethodNotWorking} ',
              linkText: l10n.useRecoveryCode,
              onTap: () => BlocProvider.of<AuthCubit>(context).useRecoveryCode(),
            ),
        ],
      );
    });
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

  void _verify() async {
    final cubit = BlocProvider.of<AuthCubit>(context);
    await cubit.verifyWithPasskey();
    if (mounted && cubit.state.isLoggedIn) {
      Navigator.of(context).pop();
    }
  }
}
