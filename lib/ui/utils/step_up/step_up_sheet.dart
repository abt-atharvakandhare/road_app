import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/step_up/step_up_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_code_entry_card.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

/// Presents the step-up sheet and resolves to true when a factor was
/// verified, false/null when the user backed out.
Future<bool?> showStepUpSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    builder: (sheetContext) => BlocProvider(
      create: (_) => getIt<StepUpCubit>(),
      child: const StepUpSheet(),
    ),
  );
}

/// The step-up challenge sheet (spec §13). Error dialogs are listened for in
/// here — inside the sheet's own route — because
/// [ModalInfoDialogs.showErrorDialog] no-ops when its context's route isn't
/// the current one.
class StepUpSheet extends StatelessWidget {
  const StepUpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: RMColors.rmPrimaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: BlocConsumer<StepUpCubit, StepUpState>(
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                left: 24, right: 24, top: 24, bottom: 24 + MediaQuery.of(context).viewInsets.bottom),
            child: switch (state) {
              StepUpMethodPick(:final factors, :final flow) => (factors == null || flow.isLoading)
                  ? const Center(
                      child:
                          Padding(padding: EdgeInsets.symmetric(vertical: 60), child: CircularProgressIndicator()))
                  : _MethodPicker(factors: factors),
              StepUpCodeEntry() => _CodeEntry(state: state),
              StepUpPasskey() => _PasskeyStep(state: state),
              StepUpDeadEnd() => const _DeadEnd(),
            },
          );
        },
      ),
    );
  }
}

class _MethodPicker extends StatelessWidget {
  const _MethodPicker({required this.factors});

  final List<MfaFactorModel> factors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.stepUpTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(l10n.stepUpPickMethodIntro, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        for (final factor in factors) ...[
          _FactorRow(factor: factor),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor});

  final MfaFactorModel factor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final title = switch (factor.type) {
      MfaMethod.totp => l10n.mfaSetupAuthenticatorTitle,
      MfaMethod.sms => l10n.mfaSetupSmsTitle,
      MfaMethod.passkey => l10n.passkeyAuthentication,
      _ => '',
    };

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: RMColors.containerBorderGrey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: factor.hint != null ? Text(factor.hint!, style: Theme.of(context).textTheme.bodySmall) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => BlocProvider.of<StepUpCubit>(context).pickMethod(factor.type),
      ),
    );
  }
}

class _CodeEntry extends StatelessWidget {
  const _CodeEntry({required this.state});

  final StepUpCodeEntry state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final header = switch (state.method) {
      MfaMethod.sms => '${l10n.weSentACodeToPhone(state.hint ?? '')}\n\n${l10n.enterThe6DigitCodeBelow}',
      _ => l10n.stepUpAuthenticatorPrompt,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.canPickAnother) ...[
          TextButton.icon(
            onPressed: () => BlocProvider.of<StepUpCubit>(context).backToPicker(),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l10n.mfaSetupBack),
          ),
          const SizedBox(height: 8),
        ],
        MfaCodeEntryCard(
          header: header,
          nextSendAfterSeconds: state.nextSendAfterSeconds,
          isLoading: state.flow.isLoading,
          smsAutofill: state.method == MfaMethod.sms,
          onSubmit: (code) async {
            final result = await BlocProvider.of<StepUpCubit>(context).verifyCode(code);
            if (result == TwoFactorAuthResult.success && context.mounted) {
              Navigator.of(context).pop(true);
            }
            return result;
          },
          onResend: state.method == MfaMethod.sms
              ? () => BlocProvider.of<StepUpCubit>(context).resendCode()
              : null,
        ),
      ],
    );
  }
}

/// The passkey step. The OS ceremony is auto-started once on arrival;
/// afterwards every attempt is user-initiated via the button (each attempt
/// re-arms — ceremony ids are single-use). Success pops the sheet with true
/// so the gated request retries.
class _PasskeyStep extends StatefulWidget {
  const _PasskeyStep({required this.state});

  final StepUpPasskey state;

  @override
  State<_PasskeyStep> createState() => _PasskeyStepState();
}

class _PasskeyStepState extends State<_PasskeyStep> {
  @override
  void initState() {
    super.initState();
    if (!widget.state.noCredential) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _verify();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.state.canPickAnother) ...[
          TextButton.icon(
            onPressed: () => BlocProvider.of<StepUpCubit>(context).backToPicker(),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l10n.mfaSetupBack),
          ),
          const SizedBox(height: 8),
        ],
        Text(l10n.stepUpTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          widget.state.noCredential ? l10n.stepUpPasskeyNoCredential : l10n.stepUpPasskeyPrompt,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        RMTextButton(
          isLoading: widget.state.flow.isLoading,
          onPressed: () {
            _verify();
          },
          text: l10n.mfaPasskeyButton,
        ),
      ],
    );
  }

  void _verify() async {
    final result = await BlocProvider.of<StepUpCubit>(context).verifyPasskey();
    if (result == TwoFactorAuthResult.success && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _DeadEnd extends StatelessWidget {
  const _DeadEnd();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.stepUpTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(l10n.stepUpPasskeyOnly, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        RMTextButton(
          isLoading: false,
          onPressed: () => Navigator.of(context).pop(false),
          text: l10n.close,
        ),
      ],
    );
  }
}
