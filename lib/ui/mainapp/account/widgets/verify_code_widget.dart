import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyCodeWidget extends StatefulWidget {
  const VerifyCodeWidget({
    super.key,
    this.title,
    required this.message,
    required this.onVerifyCode,
    required this.onResendCode,
    required this.isLoading,
    this.didntReceiveText,
    this.resendText,
  });

  final String? title;
  final String message;
  final Future<bool> Function(String code) onVerifyCode;
  final VoidCallback onResendCode;
  final bool isLoading;
  final String? didntReceiveText;
  final String? resendText;

  @override
  State<VerifyCodeWidget> createState() => _VerifyCodeWidgetState();
}

class _VerifyCodeWidgetState extends State<VerifyCodeWidget> with CodeAutoFill {
  String _enteredOtp = '';
  bool _codeWasWrong = false;
  final TextEditingController _pinEntryController = TextEditingController();
  final FocusNode _pinEntryFocusNode = FocusNode();
  bool _haveSubmittedCode = false;

  @override
  void initState() {
    super.initState();
    // Start listening for SMS codes on Android
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startSmsListener();
      });
    }
  }

  @override
  void dispose() {
    _pinEntryController.dispose();
    _pinEntryFocusNode.dispose();
    // Stop listening for SMS codes
    if (Platform.isAndroid) {
      try {
        cancel();
      } catch (e) {
        // Ignore errors during disposal
      }
    }
    super.dispose();
  }

  @override
  void codeUpdated() {
    // This method is called when SMS auto-detection receives a code
    if (mounted && code != null && code!.length == 6 && !_haveSubmittedCode) {
      setState(() {
        _enteredOtp = code!;
        _pinEntryController.text = code!;
      });
      // Automatically verify the code
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_haveSubmittedCode) {
          checkVerificationCode(context, code!);
        }
      });
    }
  }

  void _startSmsListener() {
    try {
      listenForCode();
    } catch (e) {
      // SMS listening failed, but continue with manual entry
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
          child: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildVerifyCodeContents(context),
      ))),
    );
  }

  Widget _buildVerifyCodeContents(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.title ?? AppLocalizations.of(context)!.enterCode),
      const SizedBox(height: 24),
      Text(widget.message, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 10),
      Text(AppLocalizations.of(context)!.enterThe6DigitCodeBelow, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 24),
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
              strokeColorBuilder: _codeWasWrong
                  ? const FixedColorBuilder(RMColors.errorRed)
                  : PinListenColorBuilder(RMColors.rmPrimaryColor, RMColors.separatorDarkGrey),
              bgColorBuilder: const FixedColorBuilder(Colors.white),
              strokeWidth: 1,
            ),
            onChanged: (value) {
              setState(() {
                _enteredOtp = value;
                if (value.length == 6 && !_haveSubmittedCode) {
                  checkVerificationCode(context, value);
                }
              });
            },
            onSubmit: (value) {
              checkVerificationCode(context, value);
            },
          )),
      if (_codeWasWrong) ...[
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.codeEnteredIsIncorrect,
            style: Theme.of(context).inputDecorationTheme.errorStyle),
      ],
      const SizedBox(height: 24),
      RMTextButton(
        isLoading: widget.isLoading,
        onPressed: _enteredOtp.length != 6
            ? null
            : () {
                checkVerificationCode(context, _enteredOtp);
              },
        text: AppLocalizations.of(context)!.verify,
      ),
      const SizedBox(height: 8),
      RMSeparator(),
      const SizedBox(height: 8),
      RichText(
          text: TextSpan(children: [
        TextSpan(
          text: AppLocalizations.of(context)!.didntReceiveTheCode,
          style: const TextStyle(color: RMColors.rmBlackText),
        ),
        TextSpan(
          text: ' ${AppLocalizations.of(context)!.resendVerificationCode}',
          style: TextStyle(color: RMColors.rmPrimaryColor),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              widget.onResendCode();
            },
        ),
      ])),
    ]);
  }

  void checkVerificationCode(BuildContext context, String code) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _haveSubmittedCode = true;
    final codeAccepted = await widget.onVerifyCode(code);

    if (!codeAccepted) {
      setState(() {
        _codeWasWrong = true;
      });
    }
  }
}
