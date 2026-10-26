import 'package:flutter/widgets.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/model/mfa_error_code.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/step_up/step_up_sheet.dart';

/// Presents a step-up challenge; resolves true when a factor was verified.
typedef StepUpPrompt = Future<bool?> Function(BuildContext context);

/// Runs [action]; when it fails with `MFA_STEP_UP_REQUIRED`, presents the
/// step-up sheet and — after a successful verification — re-runs [action]
/// exactly once. Backing out of the sheet rethrows the original error, so
/// the call site decides how a declined step-up surfaces.
///
/// This seam lives at the cubit/action level deliberately: a dio interceptor
/// has no BuildContext to present the sheet from, and [ApiService]'s own
/// retry loop would interleave with a dio-level replay.
Future<T> runWithStepUp<T>(
  BuildContext context,
  Future<T> Function() action, {
  StepUpPrompt prompt = showStepUpSheet,
}) async {
  try {
    return await action();
  } on RMApiError catch (e) {
    if (MfaErrorCode.fromError(e) != MfaErrorCode.stepUpRequired || !context.mounted) {
      rethrow;
    }
    final verified = await prompt(context);
    if (verified != true) {
      rethrow;
    }
    return await action();
  }
}

/// [runWithStepUp] for cubit mutations: an unmet step-up demand — the sheet
/// declined, or the demand re-raised on the retry — resolves to null; nothing
/// was written, and the user backed out on purpose. Everything else is
/// surfaced by the cubit itself, so any other escaping error is a cubit leak
/// and propagates.
Future<T?> runWithStepUpOrNull<T>(
  BuildContext context,
  Future<T> Function() action, {
  StepUpPrompt prompt = showStepUpSheet,
}) async {
  try {
    return await runWithStepUp(context, action, prompt: prompt);
  } on RMApiError catch (e) {
    if (MfaErrorCode.fromError(e) != MfaErrorCode.stepUpRequired) {
      rethrow;
    }
    return null;
  }
}

/// [runWithStepUpOrNull] for the code-entry submissions, whose result drives
/// the card's inline error state.
Future<TwoFactorAuthResult> runWithStepUpVerify(
  BuildContext context,
  Future<TwoFactorAuthResult> Function() action, {
  StepUpPrompt prompt = showStepUpSheet,
}) async {
  return await runWithStepUpOrNull(context, action, prompt: prompt) ?? TwoFactorAuthResult.error;
}
