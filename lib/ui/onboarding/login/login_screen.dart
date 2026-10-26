import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/login_email_password_widget.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';

import 'login_2fa_code_widget.dart';
import 'login_use_backup_code_widget.dart';
import 'mfa_code_entry_widget.dart';
import 'mfa_enrol_intro_widget.dart';
import 'mfa_enrol_method_picker_widget.dart';
import 'mfa_enrol_passkey_widget.dart';
import 'mfa_enrol_totp_widget.dart';
import 'mfa_method_picker_widget.dart';
import 'mfa_passkey_widget.dart';
import 'mfa_recovery_code_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.isModal});

  static Future<void> pushAsModal(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: ((routeContext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: BlocProvider.of<AuthCubit>(context)),
              BlocProvider.value(value: BlocProvider.of<LocationBloc>(context)),
            ],
            child: LoginScreen(isModal: true),
          );
        }),
        fullscreenDialog: true));
  }

  final bool isModal;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
      if (state.flow.isError) {
        getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
      }
    }, builder: (context, state) {
      return Scaffold(
        backgroundColor: RMColors.rmPrimaryBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: switch (state) {
            LoggedOut(:final twoFactorAuth) => switch (twoFactorAuth) {
                TwoFactorAuthUseBackupCode() => IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).backFromBackupCode();
                    },
                  ),
                TwoFactorAuthPendingRecoveryCode() => IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).backFromRecoveryCode();
                    },
                  ),
                TwoFactorAuthPendingTotp(:final challenge) ||
                TwoFactorAuthPendingSms(:final challenge) ||
                TwoFactorAuthPendingPasskey(:final challenge)
                    when challenge.methods
                            .usableOnMobile(
                                passkeySupported: BlocProvider.of<AuthCubit>(context).passkeySupported)
                            .length >
                        1 =>
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).backToMfaMethodPicker();
                    },
                  ),
                _ => null,
              },
            _ => null,
          },
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                BlocProvider.of<AuthCubit>(context).loginScreenClosedByUser();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    switch (state) {
                      LoggedOut(:final twoFactorAuth) => switch (twoFactorAuth) {
                          TwoFactorAuthUseBackupCode backup => LoginUseBackupCodeWidget(twoFactorAuth: backup),
                          TwoFactorAuthOtp() || TwoFactorAuthSms() => Login2FaCodeWidget(twoFactorAuth: twoFactorAuth!),
                          TwoFactorAuthMethodPicker picker => MfaMethodPickerWidget(twoFactorAuth: picker),
                          TwoFactorAuthPendingPasskey passkey => MfaPasskeyWidget(twoFactorAuth: passkey),
                          TwoFactorAuthPendingRecoveryCode recovery => MfaRecoveryCodeWidget(twoFactorAuth: recovery),
                          TwoFactorAuthPendingTotp() ||
                          TwoFactorAuthPendingSms() ||
                          TwoFactorAuthVerifyEmail() ||
                          TwoFactorAuthEnrolEmailProof() ||
                          TwoFactorAuthEnrolSms() =>
                            MfaCodeEntryWidget(twoFactorAuth: twoFactorAuth!),
                          TwoFactorAuthEnrolIntro intro => MfaEnrolIntroWidget(twoFactorAuth: intro),
                          TwoFactorAuthEnrolMethodPicker enrolPicker =>
                            MfaEnrolMethodPickerWidget(twoFactorAuth: enrolPicker),
                          TwoFactorAuthEnrolTotp enrolTotp => MfaEnrolTotpWidget(twoFactorAuth: enrolTotp),
                          TwoFactorAuthEnrolPasskey enrolPasskey =>
                            MfaEnrolPasskeyWidget(twoFactorAuth: enrolPasskey),
                          _ => LoginEmailPasswordWidget(isModal: isModal),
                        },
                      _ => const SizedBox(),
                    }
                  ]),
                ),
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
              }),
        ),
      );
    });
  }
}
