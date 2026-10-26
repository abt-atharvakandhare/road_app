import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/authenticator_app_links.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

/// The authenticator-enrolment walkthrough: download links, QR / manual
/// secret, and the confirming code entry. Presentation-only — the hosting
/// flow supplies [onSubmitCode] (login-time enrolment activates via the
/// `enrolId` handle, the signup step via the in-session endpoints) and
/// reacts to its own cubit for navigation; a wrong code retries inline here.
class TotpSetupCard extends StatefulWidget {
  const TotpSetupCard({
    super.key,
    required this.otpauthUri,
    required this.secret,
    required this.isLoading,
    required this.onSubmitCode,
  });

  final String otpauthUri;
  final String secret;
  final bool isLoading;

  /// Verifies the entered code; the result drives the inline error state.
  final Future<TwoFactorAuthResult> Function(String code) onSubmitCode;

  @override
  State<StatefulWidget> createState() => _TotpSetupCardState();
}

class _TotpSetupCardState extends State<TotpSetupCard> {
  String _enteredCode = '';
  bool _codeWasWrong = false;
  final TextEditingController _pinEntryController = TextEditingController();
  final FocusNode _pinEntryFocusNode = FocusNode();
  bool _haveSubmittedCode = false;

  @override
  void initState() {
    super.initState();
    _pinEntryFocusNode.addListener(() {
      if (_codeWasWrong && _pinEntryFocusNode.hasFocus) {
        setState(() {
          _codeWasWrong = false;
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.oneDownloadAnAuthenticatorApp, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        AuthenticatorAppLinks(style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Text(l10n.twoScanTheQrCode, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 206, maxHeight: 206),
            child: QrImageView(data: widget.otpauthUri),
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.cantScanTheCode, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SelectableText(widget.secret,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: widget.secret)),
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.threeEnterTheCode, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
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
                  _enteredCode = value;
                });
                if (value.length == 6 && !_haveSubmittedCode) {
                  _submitCode();
                }
              },
              onSubmit: (value) {
                _submitCode();
              },
            )),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _codeWasWrong
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l10n.codeEnteredIsIncorrect,
                      style: Theme.of(context).inputDecorationTheme.errorStyle))
              : const SizedBox(),
        ),
        const SizedBox(height: 24),
        RMTextButton(
            isLoading: widget.isLoading,
            onPressed: _enteredCode.length != 6
                ? null
                : () {
                    _submitCode();
                  },
            text: l10n.verify),
      ],
    );
  }

  void _submitCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_haveSubmittedCode) return;
    _haveSubmittedCode = true;

    final result = await widget.onSubmitCode(_enteredCode);
    if (!mounted) return;
    if (result == TwoFactorAuthResult.wrongCode) {
      setState(() {
        _codeWasWrong = true;
        _haveSubmittedCode = false;
      });
    } else {
      _haveSubmittedCode = false;
    }
  }
}
