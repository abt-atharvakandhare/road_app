import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'cubit/auth_cubit.dart';
import 'model/mfa_wait_format.dart';

/// Lost-factor fallback: free-text entry for a single-use recovery code.
class MfaRecoveryCodeWidget extends StatefulWidget {
  const MfaRecoveryCodeWidget({super.key, required this.twoFactorAuth});

  final TwoFactorAuthPendingRecoveryCode twoFactorAuth;

  @override
  State<StatefulWidget> createState() => _MfaRecoveryCodeWidgetState();
}

class _MfaRecoveryCodeWidgetState extends State<MfaRecoveryCodeWidget> {
  String _enteredCode = '';
  bool _codeWasWrong = false;
  // Recovery codes are single-use — a double submission would burn a second
  // code, so gate while a verify is in flight.
  bool _haveSubmittedCode = false;

  /// Guess-limit lockout: recovery guessing is bounded per user, and the
  /// budget may already be spent by earlier factor attempts.
  int _verifyWaitSeconds = 0;
  Timer? _waitTimer;

  final TextEditingController _codeController = TextEditingController();

  void _startVerifyWait(int seconds) {
    _verifyWaitSeconds = seconds;
    _waitTimer?.cancel();
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_verifyWaitSeconds > 0) _verifyWaitSeconds--;
        if (_verifyWaitSeconds == 0) {
          _waitTimer?.cancel();
          _waitTimer = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(l10n.useRecoveryCode, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.enterRecoveryCodeBelow, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          TextField(
            controller: _codeController,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.recoveryCode,
              errorText: _verifyWaitSeconds > 0
                  ? l10n.mfaTooManyAttemptsWait(formatWaitSeconds(_verifyWaitSeconds))
                  : _codeWasWrong
                      ? l10n.codeEnteredIsIncorrect
                      : null,
              fillColor: RMColors.rmPrimaryBackground,
            ),
            onChanged: (value) {
              setState(() {
                _enteredCode = value.trim();
                _codeWasWrong = false;
              });
            },
            onSubmitted: (value) {
              _submitCode(context);
            },
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return RMTextButton(
                  isLoading: state.flow.isLoading,
                  onPressed: _enteredCode.length < 6 || _verifyWaitSeconds > 0
                      ? null
                      : () {
                          _submitCode(context);
                        },
                  text: l10n.verify);
            },
          ),
        ],
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    );
  }

  void _submitCode(BuildContext context) async {
    if (_haveSubmittedCode) return;
    _haveSubmittedCode = true;

    FocusManager.instance.primaryFocus?.unfocus();
    final cubit = BlocProvider.of<AuthCubit>(context);
    final result = await cubit.verifyPendingMfaCode(_enteredCode);
    if (!context.mounted) return;
    if (cubit.state.isLoggedIn) {
      Navigator.of(context).pop();
    } else if (result == TwoFactorAuthResult.wrongCode) {
      setState(() {
        _codeWasWrong = true;
        _haveSubmittedCode = false;
      });
    } else if (result case TwoFactorAuthRateLimited(:final retryAfterSeconds)) {
      setState(() {
        _haveSubmittedCode = false;
        _startVerifyWait(retryAfterSeconds);
      });
    } else {
      _haveSubmittedCode = false;
    }
  }
}
