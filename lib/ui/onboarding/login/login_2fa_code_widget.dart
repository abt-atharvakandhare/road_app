import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import 'cubit/auth_cubit.dart';

class Login2FaCodeWidget extends StatefulWidget {
  const Login2FaCodeWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuth twoFactorAuth;

  @override
  State<StatefulWidget> createState() => _Login2FaCodeWidgetState();
}

class _Login2FaCodeWidgetState extends State<Login2FaCodeWidget> {
  String _enteredOtp = '';
  bool _twoFaCodeWasWrong = false;
  final TextEditingController _pinEntryController = TextEditingController();
  final FocusNode _pinEntryFocusNode = FocusNode();
  bool _haveSubmittedCode = false;

  @override
  initState() {
    super.initState();
    _pinEntryFocusNode.addListener(() {
      if (_twoFaCodeWasWrong && _pinEntryFocusNode.hasFocus) {
        setState(() {
          _twoFaCodeWasWrong = false;
          _pinEntryController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _pinEntryController.dispose();
    _pinEntryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? headerText;
    String? footerText;
    String? footerLinkText;

    switch (widget.twoFactorAuth) {
      case TwoFactorAuthOtp():
        headerText = AppLocalizations.of(context)!.enterTheSecurityCodeGenerated;
      case TwoFactorAuthSms(:final mfaPhoneNumber):
        headerText =
            '${AppLocalizations.of(context)!.weSentYouAnSms.replaceAll('--phonenumber--', mfaPhoneNumber)}\n\n${AppLocalizations.of(context)!.enterThe6DigitCodeBelow}';
        footerText = AppLocalizations.of(context)!.didntReceiveTheCode;
        footerLinkText = AppLocalizations.of(context)!.resendVerificationCode;
      case TwoFactorAuthUseBackupCode():
      default:
        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.enterCode)),
          const SizedBox(height: 8),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(headerText ?? '', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 20),
          Theme(
              data: Theme.of(context).copyWith(
                  inputDecorationTheme:
                      Theme.of(context).inputDecorationTheme.copyWith(fillColor: RMColors.rmPrimaryBackground)),
              child: PinInputTextField(
                controller: _pinEntryController,
                focusNode: _pinEntryFocusNode,
                pinLength: 6,
                keyboardType: TextInputType.number,
                decoration: BoxLooseDecoration(
                  strokeColorBuilder: _twoFaCodeWasWrong
                      ? const FixedColorBuilder(RMColors.errorRed)
                      : PinListenColorBuilder(RMColors.rmPrimaryColor, RMColors.separatorDarkGrey),
                  bgColorBuilder: const FixedColorBuilder(Colors.white),
                  strokeWidth: 1,
                ),
                autoFocus: true,
                onChanged: (value) {
                  setState(() {
                    _enteredOtp = value;
                    if (value.length == 6 && !_haveSubmittedCode) {
                      verify2FaCode(context);
                    }
                  });
                },
                onSubmit: (value) {
                  verify2FaCode(context);
                },
              )),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _twoFaCodeWasWrong
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(AppLocalizations.of(context)!.codeEnteredIsIncorrect,
                        style: Theme.of(context).inputDecorationTheme.errorStyle))
                : const SizedBox(),
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return RMTextButton(
                  isLoading: state.flow.isLoading,
                  onPressed: _enteredOtp.length != 6
                      ? null
                      : () {
                          verify2FaCode(context);
                        },
                  text: AppLocalizations.of(context)!.verify);
            },
          ),
          const SizedBox(height: 30),
          const RMSeparator(),
          const SizedBox(height: 12),
          if (widget.twoFactorAuth case TwoFactorAuthSms(:final mfaToken)) ...[
            Text.rich(TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
              TextSpan(text: '$footerText '),
              TextSpan(
                text: footerLinkText,
                style: TextStyle(color: RMColors.rmPrimaryColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    BlocProvider.of<AuthCubit>(context).resend2FaCode(mfaToken);
                  },
              ),
            ])),
            const SizedBox(height: 32),
          ],
          Text.rich(TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
            TextSpan(text: '* ${AppLocalizations.of(context)!.isThisAuthMethodNotWorking} '),
            TextSpan(
              text: AppLocalizations.of(context)!.useYourBackupCodes,
              style: TextStyle(color: RMColors.rmPrimaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  BlocProvider.of<AuthCubit>(context).useBackupCode();
                },
            ),
          ])),
        ],
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    );
  }

  void verify2FaCode(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _haveSubmittedCode = true;

    final mfaToken = switch (widget.twoFactorAuth) {
      TwoFactorAuthOtp(:final mfaToken) => mfaToken,
      TwoFactorAuthSms(:final mfaToken) => mfaToken,
      TwoFactorAuthUseBackupCode(:final mfaToken) => mfaToken,
      _ => null,
    };
    if (mfaToken == null) {
      return;
    }

    final twoFaResult = await BlocProvider.of<AuthCubit>(context).verify2FaCode(
        mfaToken: mfaToken,
        email: widget.twoFactorAuth.email,
        providerModel: widget.twoFactorAuth.providerModel,
        code: _enteredOtp);
    if (twoFaResult == TwoFactorAuthResult.success) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } else if (twoFaResult == TwoFactorAuthResult.wrongCode) {
      setState(() {
        _twoFaCodeWasWrong = true;
      });
    }
  }
}
