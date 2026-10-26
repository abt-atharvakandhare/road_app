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

/// Shown when the user can verify with more than one factor type.
class MfaMethodPickerWidget extends StatefulWidget {
  const MfaMethodPickerWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthMethodPicker twoFactorAuth;

  @override
  State<MfaMethodPickerWidget> createState() => _MfaMethodPickerWidgetState();
}

class _MfaMethodPickerWidgetState extends State<MfaMethodPickerWidget> {
  /// The method whose selection is in flight — only its button spins; the
  /// others are merely disabled.
  MfaMethod? _pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final twoFactorAuth = widget.twoFactorAuth;
    final usable = twoFactorAuth.challenge.methods
        .usableOnMobile(passkeySupported: BlocProvider.of<AuthCubit>(context).passkeySupported);
    final preferred = twoFactorAuth.challenge.preferred;
    final ordered = [
      ...usable.where((method) => method == preferred),
      ...usable.where((method) => method != preferred),
    ];

    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(l10n.chooseVerificationMethod, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.howWouldYouLikeToVerify, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          for (final method in ordered) ...[
            RMTextButton(
              isLoading: state.flow.isLoading && method == _pending,
              onPressed: state.flow.isLoading
                  ? null
                  : () async {
                      setState(() => _pending = method);
                      await BlocProvider.of<AuthCubit>(context).selectMfaMethod(method);
                      if (mounted) setState(() => _pending = null);
                    },
              text: switch (method) {
                MfaMethod.totp => l10n.appAuthentication,
                MfaMethod.sms => l10n.smsAuthentication,
                MfaMethod.passkey => l10n.passkeyAuthentication,
                _ => '',
              },
            ),
            const SizedBox(height: 12),
          ],
          if (twoFactorAuth.challenge.canUseRecoveryCode == true) ...[
            const SizedBox(height: 18),
            const RMSeparator(),
            const SizedBox(height: 12),
            Text.rich(TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
              TextSpan(text: '${l10n.isThisAuthMethodNotWorking} '),
              TextSpan(
                text: l10n.useRecoveryCode,
                style: TextStyle(color: RMColors.rmPrimaryColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    BlocProvider.of<AuthCubit>(context).useRecoveryCode();
                  },
              ),
            ])),
          ],
        ],
      );
    });
  }
}
