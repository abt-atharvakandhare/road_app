import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/model/mfa_wait_format.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:sms_autofill/sms_autofill.dart';

/// Six-digit code entry with resend countdown, exhausted-code and guess-limit
/// handling. Shared between the login-time MFA steps, the signup "Secure
/// Sign-in" step and the step-up sheet; the host owns everything around it
/// (back links, titles above the card, extra [footer] links) and reports the
/// verify outcome through [onSubmit]'s result.
class MfaCodeEntryCard extends StatefulWidget {
  const MfaCodeEntryCard({
    super.key,
    required this.header,
    required this.nextSendAfterSeconds,
    required this.isLoading,
    required this.onSubmit,
    this.onResend,
    this.smsAutofill = false,
    this.footer = const [],
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String header;
  final int? nextSendAfterSeconds;
  final bool isLoading;
  final Future<TwoFactorAuthResult> Function(String code) onSubmit;

  /// Null hides the resend affordance entirely — for factors where no code is
  /// ever sent (an authenticator app generates its own).
  final Future<void> Function()? onResend;

  /// Whether the code arrives by SMS: enables the Android SMS Retriever
  /// listener, which fills the pin and submits when the text lands. Leave
  /// false for TOTP and email codes.
  final bool smsAutofill;

  /// Host-owned links rendered under the resend affordance (e.g. login's
  /// switch-method and recovery-code links), 16px apart. The separator
  /// section appears when there is a resend affordance or a footer.
  final List<Widget> footer;

  /// Alignment of the card's shrink-wrapping children (error and countdown
  /// texts, footer links); the title and header stay left-aligned.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<StatefulWidget> createState() => _MfaCodeEntryCardState();
}

class _MfaCodeEntryCardState extends State<MfaCodeEntryCard> with CodeAutoFill {
  String _enteredCode = '';
  bool _codeWasWrong = false;
  bool _codeExhausted = false;
  bool _haveSubmittedCode = false;
  int _resendWaitSeconds = 0;
  int _verifyWaitSeconds = 0;
  Timer? _waitTimer;
  final TextEditingController _pinEntryController = TextEditingController();
  final FocusNode _pinEntryFocusNode = FocusNode();

  bool get _smsListenerActive => widget.smsAutofill && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _seedResendWait();
    _pinEntryFocusNode.addListener(() {
      if (_codeWasWrong && _pinEntryFocusNode.hasFocus) {
        setState(() {
          _codeWasWrong = false;
          _pinEntryController.clear();
        });
      }
    });
    if (_smsListenerActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          listenForCode();
        } catch (e) {
          // SMS listening failed, but continue with manual entry
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MfaCodeEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A changed wait means a send (or a refused, wait-carrying resend)
    // happened — re-seed the countdown and retire the stale-code message.
    if (widget.nextSendAfterSeconds != oldWidget.nextSendAfterSeconds) {
      _codeExhausted = false;
      _seedResendWait();
    }
  }

  void _seedResendWait() {
    final wait = widget.nextSendAfterSeconds;
    if (wait != null && wait > 0) {
      _resendWaitSeconds = wait;
      _ensureTicking();
    }
  }

  void _ensureTicking() {
    _waitTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_resendWaitSeconds > 0) _resendWaitSeconds--;
        if (_verifyWaitSeconds > 0) _verifyWaitSeconds--;
        if (_resendWaitSeconds == 0 && _verifyWaitSeconds == 0) {
          _waitTimer?.cancel();
          _waitTimer = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _pinEntryController.dispose();
    _pinEntryFocusNode.dispose();
    if (_smsListenerActive) {
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
    final autofilled = code;
    if (mounted && autofilled != null && autofilled.length == 6 && !_haveSubmittedCode) {
      setState(() {
        _enteredCode = autofilled;
        _pinEntryController.text = autofilled;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_haveSubmittedCode) {
          _submitCode();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final footerItems = <Widget>[
      if (widget.onResend != null)
        if (_resendWaitSeconds > 0)
          // Muted so it reads as a disabled control, not a link.
          Text(l10n.mfaResendWaitCountdown(formatWaitSeconds(_resendWaitSeconds)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: RMColors.searchTextGrey))
        else
          Text.rich(TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
            TextSpan(text: '${l10n.didntReceiveTheCode} '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: _resend,
                child: Text(l10n.resendVerificationCode,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: RMColors.rmPrimaryColor)),
              ),
            ),
          ])),
      ...widget.footer,
    ];

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.enterCode, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(height: 8),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.header, style: Theme.of(context).textTheme.bodySmall)),
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
                strokeColorBuilder: _codeWasWrong
                    ? const FixedColorBuilder(RMColors.errorRed)
                    : PinListenColorBuilder(RMColors.rmPrimaryColor, RMColors.separatorDarkGrey),
                bgColorBuilder: const FixedColorBuilder(Colors.white),
                strokeWidth: 1,
              ),
              autoFocus: true,
              onChanged: (value) {
                setState(() {
                  _enteredCode = value;
                  _codeWasWrong = false;
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
          child: switch ((_verifyWaitSeconds, _codeExhausted, _codeWasWrong)) {
            (> 0, _, _) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.mfaTooManyAttemptsWait(formatWaitSeconds(_verifyWaitSeconds)),
                    style: Theme.of(context).inputDecorationTheme.errorStyle)),
            (_, true, _) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.mfaCodeExhausted,
                    style: Theme.of(context).inputDecorationTheme.errorStyle)),
            (_, _, true) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.codeEnteredIsIncorrect,
                    style: Theme.of(context).inputDecorationTheme.errorStyle)),
            _ => const SizedBox(),
          },
        ),
        const SizedBox(height: 24),
        RMTextButton(
            isLoading: widget.isLoading,
            onPressed: _enteredCode.length != 6 || _verifyWaitSeconds > 0
                ? null
                : () {
                    _submitCode();
                  },
            text: l10n.verify),
        if (footerItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          const RMSeparator(),
          const SizedBox(height: 12),
          for (final (index, item) in footerItems.indexed) ...[
            if (index > 0) const SizedBox(height: 16),
            item,
          ],
        ],
      ],
    );
  }

  void _resend() async {
    await widget.onResend?.call();
    if (mounted) {
      setState(() {
        _codeExhausted = false;
        _seedResendWait();
      });
    }
  }

  void _submitCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_haveSubmittedCode) return;
    _haveSubmittedCode = true;

    final result = await widget.onSubmit(_enteredCode);
    if (!mounted) return;
    _haveSubmittedCode = false;
    if (result == TwoFactorAuthResult.wrongCode) {
      setState(() {
        _codeWasWrong = true;
      });
    } else if (result == TwoFactorAuthResult.codeExhausted) {
      setState(() {
        _codeExhausted = true;
        _pinEntryController.clear();
        _enteredCode = '';
      });
    } else if (result case TwoFactorAuthRateLimited(:final retryAfterSeconds)) {
      setState(() {
        _verifyWaitSeconds = retryAfterSeconds;
        _ensureTicking();
      });
    }
  }
}
