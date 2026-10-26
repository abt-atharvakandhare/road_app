import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/link_launcher.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import 'cubit/auth_cubit.dart';

class LoginUseBackupCodeWidget extends StatefulWidget {
  const LoginUseBackupCodeWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthUseBackupCode twoFactorAuth;

  @override
  State<StatefulWidget> createState() => _LoginUseBackupCodeWidgetState();
}

class _LoginUseBackupCodeWidgetState extends State<LoginUseBackupCodeWidget> {
  String _enteredBackupCode = '';
  bool _twoFaCodeWasWrong = false;
  final TextEditingController _pinEntryController = TextEditingController();
  final FocusNode _pinEntryFocusNode = FocusNode();

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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.useYourBackupCodes)),
          const SizedBox(height: 8),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.pleaseEnterBackupCode,
                  style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 20),
          TextField(
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            autocorrect: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.grey),
              hintText: AppLocalizations.of(context)!.backupVerificationCode,
            ),
            onChanged: (value) {
              setState(() {
                if (_twoFaCodeWasWrong) {
                  _twoFaCodeWasWrong = false;
                }
                _enteredBackupCode = value;
              });
            },
            onSubmitted: (value) => verify2FaCode(context),
          ),
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
                  onPressed: _enteredBackupCode.length < 6
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
          Text.rich(TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
            TextSpan(
              text:
                  '${AppLocalizations.of(context)!.dontHaveYourBackupCodes}\n\n${AppLocalizations.of(context)!.contactSupportAt} ',
            ),
            TextSpan(
              text: 'support@road.io',
              style: TextStyle(color: RMColors.rmPrimaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final url = Uri.tryParse('mailto:support@road.io?subject=Backup%20codes%20issue');
                  launchProviderUri(context, url);
                },
            ),
            TextSpan(
              text: ' ${AppLocalizations.of(context)!.toStartAManualVerificationProcess}',
              style: Theme.of(context).textTheme.bodySmall,
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
    final twoFaResult = await BlocProvider.of<AuthCubit>(context).verify2FaCode(
        mfaToken: widget.twoFactorAuth.mfaToken,
        email: widget.twoFactorAuth.email,
        providerModel: widget.twoFactorAuth.providerModel,
        code: _enteredBackupCode);
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
