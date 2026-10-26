import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/widgets/totp_setup_card.dart';

import 'cubit/auth_cubit.dart';

/// Login-time authenticator enrolment: scan the QR (or copy the secret),
/// then confirm with a generated code — which activates the factor and
/// completes the sign-in.
class MfaEnrolTotpWidget extends StatelessWidget {
  const MfaEnrolTotpWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthEnrolTotp twoFactorAuth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totp = twoFactorAuth.totp;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(l10n.appAuthentication, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return TotpSetupCard(
                otpauthUri: totp.otpauthUri,
                secret: totp.secret,
                isLoading: state.flow.isLoading,
                onSubmitCode: (code) => _submitCode(context, code),
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

  Future<TwoFactorAuthResult> _submitCode(BuildContext context, String code) async {
    final cubit = BlocProvider.of<AuthCubit>(context);
    final result = await cubit.verifyEnrolmentCode(code);
    if (context.mounted && cubit.state.isLoggedIn) {
      Navigator.of(context).pop();
    }
    return result;
  }
}
