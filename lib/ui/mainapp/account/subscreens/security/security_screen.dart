import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/password/password_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/security/cubit/security_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/step_up/run_with_step_up.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_code_entry_card.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_option_row.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_sub_flow.dart';
import 'package:road_mobile/ui/utils/widgets/rm_destructive_confirmation_sheet.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_secondary_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';
import 'package:road_mobile/ui/utils/widgets/totp_setup_card.dart';
import 'package:share_plus/share_plus.dart';

/// Settings "Password & Authentication": manage the ways of signing in —
/// password, sign-in factors (TOTP/SMS), backup codes and the recovery
/// email — at parity with web's "How you sign in". Every mutation runs
/// through [runWithStepUp]; the factor listing refreshes after each change.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  static void pushAsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<SecurityCubit>(),
          child: const SecurityScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SecurityCubit, MfaEnrolmentState>(
      listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
      },
      builder: (context, state) {
        final cubit = BlocProvider.of<SecurityCubit>(context);
        // The plaintext backup codes exist exactly once — leaving that step
        // is gated on the acknowledgement, not a back gesture.
        final backBlocked = state is MfaSetupRecoveryCodes;
        final onList = state is MfaSetupMethodList;
        return PopScope(
          canPop: onList,
          onPopInvokedWithResult: (didPop, _) {
            // System back mid-sub-flow returns to the factor list, matching
            // the app bar's back button.
            if (!didPop && !backBlocked) cubit.backToList();
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: !backBlocked,
              leading: onList || backBlocked ? null : BackButton(onPressed: cubit.backToList),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStep(context, state),
                  ),
                ),
                Column(
                  children: [
                    const Spacer(),
                    BottomLoadingWidget(isLoading: state is MfaSetupMethodList && state.flow.isLoading),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, MfaEnrolmentState state) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<SecurityCubit>(context);

    return switch (state) {
      MfaSetupMethodList(:final factors) => _FactorList(factors: factors),
      MfaSetupEmailProof(:final nextSendAfterSeconds) => MfaSubFlow(
          child: MfaCodeEntryCard(
            header: _emailProofHeader(context),
            nextSendAfterSeconds: nextSendAfterSeconds,
            isLoading: state.flow.isLoading,
            onSubmit: (code) => runWithStepUpVerify(context, () => cubit.verifyEmailProofCode(code)),
            onResend: cubit.resendEmailProof,
          ),
        ),
      MfaSetupTotp(:final totp) => MfaSubFlow(
          title: l10n.appAuthentication,
          child: TotpSetupCard(
            otpauthUri: totp.otpauthUri,
            secret: totp.secret,
            isLoading: state.flow.isLoading,
            onSubmitCode: (code) => runWithStepUpVerify(context, () => cubit.activateTotpCode(code)),
          ),
        ),
      MfaSetupSmsVerify(:final hint, :final nextSendAfterSeconds) => MfaSubFlow(
          child: MfaCodeEntryCard(
            header: '${l10n.weSentACodeToPhone(hint ?? '')}\n\n${l10n.enterThe6DigitCodeBelow}',
            nextSendAfterSeconds: nextSendAfterSeconds,
            isLoading: state.flow.isLoading,
            onSubmit: (code) => runWithStepUpVerify(context, () => cubit.verifySmsCode(code)),
            onResend: () => runWithStepUpOrNull(context, cubit.resendSmsCode),
          ),
        ),
      MfaSetupRecoveryCodes(:final codes) => _RecoveryCodesStep(codes: codes),
      MfaSetupRecoveryEmailEntry() => _RecoveryEmailEntryStep(isLoading: state.flow.isLoading),
      MfaSetupRecoveryEmailVerify(:final email, :final nextSendAfterSeconds) => MfaSubFlow(
          title: l10n.mfaRecoveryEmailTitle,
          child: MfaCodeEntryCard(
            header: '${l10n.weSentACodeToEmail(email)}\n\n${l10n.enterThe6DigitCodeBelow}',
            nextSendAfterSeconds: nextSendAfterSeconds,
            isLoading: state.flow.isLoading,
            onSubmit: (code) => runWithStepUpVerify(context, () => cubit.verifyRecoveryEmailCode(code)),
            onResend: () => runWithStepUpOrNull(context, cubit.resendRecoveryEmailCode),
          ),
        ),
    };
  }

  /// The email-proof gate names the address the code went to. The send
  /// response carries no hint, so the address is read off the session.
  String _emailProofHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = BlocProvider.of<AuthCubit>(context).state.accountEmail;
    return [
      l10n.confirmYourEmailFirst,
      if (email != null) l10n.weSentACodeToEmail(email),
      l10n.enterThe6DigitCodeBelow,
    ].join('\n\n');
  }
}

/// The shared destructive-confirm removal flow. The stronger warning is shown
/// when removing the only active sign-in factor — allowed even then; the user
/// re-enrols at next login.
Future<void> _confirmAndRemoveFactor(BuildContext context,
    {required String title, required MfaFactorModel factor, required MfaFactorsModel listing}) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = BlocProvider.of<SecurityCubit>(context);
  final confirmed = await RMDestructiveConfirmationSheet.show(
    context: context,
    title: title,
    message: l10n.mfaRemoveMethodConfirm(title),
    confirmationButtonText: l10n.remove,
    cancelButtonText: l10n.cancel,
    warningText: listing.isOnlyActiveLoginFactor(factor) ? l10n.mfaRemoveOnlyFactorWarning : null,
  );
  if (!context.mounted || !confirmed) return;
  await runWithStepUpOrNull(context, () => cubit.removeFactor(factor.id));
}

class _FactorList extends StatelessWidget {
  const _FactorList({required this.factors});

  final MfaFactorsModel? factors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listing = factors;

    if (listing == null) {
      return const Center(
          child: Padding(padding: EdgeInsets.only(top: 80), child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.passwordAndAuthentication, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(l10n.securityScreenIntro, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        MfaOptionRow(
          title: l10n.password,
          caption: l10n.updateYourPassword,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => PasswordScreen.pushAsModal(context),
        ),
        const SizedBox(height: 12),
        _loginFactorRow(context, listing, MfaMethod.totp, l10n.mfaSetupAuthenticatorTitle),
        const SizedBox(height: 12),
        _loginFactorRow(context, listing, MfaMethod.sms, l10n.mfaSetupSmsTitle),
        const SizedBox(height: 12),
        _passkeysRow(context, listing),
        const SizedBox(height: 12),
        _backupCodesRow(context, listing),
        const SizedBox(height: 12),
        _recoveryEmailRow(context, listing),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _loginFactorRow(BuildContext context, MfaFactorsModel listing, MfaMethod method, String title) {
    final l10n = AppLocalizations.of(context)!;
    final active = listing.activeFactorOf(method);

    if (active != null) {
      final caption = switch (method) {
        MfaMethod.totp when active.createdAt != null =>
          l10n.mfaActivatedOn(DateFormat.yMMMd().format(active.createdAt!.toLocal())),
        MfaMethod.sms when active.hint != null => active.hint!,
        _ => l10n.mfaSetupEnabled,
      };
      return MfaOptionRow(
        title: title,
        caption: caption,
        trailing: MfaRowActionButton(
          text: l10n.remove,
          destructive: true,
          onPressed: () => _confirmAndRemoveFactor(context, title: title, factor: active, listing: listing),
        ),
      );
    }
    if (listing.isDisabledByPolicy(method)) {
      return MfaOptionRow(title: title, caption: l10n.mfaNotAvailableByPolicy, enabled: false);
    }
    return MfaOptionRow(
      title: title,
      caption: l10n.mfaSetupNotSetUp,
      trailing: MfaRowActionButton(
        text: l10n.mfaSetupSetUp,
        onPressed: () =>
            runWithStepUpOrNull(context, () => BlocProvider.of<SecurityCubit>(context).setUpMethod(method)),
      ),
    );
  }

  /// Passkeys are the one multi-enrolment factor type, so the row opens a
  /// manage sheet rather than acting inline. Adding needs both provider
  /// policy and a capable device; existing passkeys (possibly created on
  /// web) always list for rename/removal.
  Widget _passkeysRow(BuildContext context, MfaFactorsModel listing) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<SecurityCubit>(context);
    final passkeys = listing.activeFactorsOf(MfaMethod.passkey);

    if (passkeys.isNotEmpty) {
      return MfaOptionRow(
        title: l10n.mfaPasskeysTitle,
        caption: l10n.mfaPasskeysCount(passkeys.length),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showPasskeysSheet(context),
      );
    }
    if (listing.isDisabledByPolicy(MfaMethod.passkey)) {
      return MfaOptionRow(title: l10n.mfaPasskeysTitle, caption: l10n.mfaNotAvailableByPolicy, enabled: false);
    }
    if (!cubit.passkeySupported) {
      return MfaOptionRow(
          title: l10n.mfaPasskeysTitle, caption: l10n.mfaPasskeysUnsupportedDevice, enabled: false);
    }
    return MfaOptionRow(
      title: l10n.mfaPasskeysTitle,
      caption: l10n.mfaSetupNotSetUp,
      trailing: MfaRowActionButton(
        text: l10n.mfaSetupSetUp,
        onPressed: () => runWithStepUpOrNull(context, () => cubit.setUpMethod(MfaMethod.passkey)),
      ),
    );
  }

  void _showPasskeysSheet(BuildContext context) {
    final cubit = BlocProvider.of<SecurityCubit>(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: const _PasskeysSheet(),
      ),
    );
  }

  Widget _backupCodesRow(BuildContext context, MfaFactorsModel listing) {
    final l10n = AppLocalizations.of(context)!;
    final active = listing.activeFactorOf(MfaMethod.recoveryCode);

    if (active != null) {
      return MfaOptionRow(
        title: l10n.mfaBackupCodesTitle,
        caption: active.remainingCodes != null ? l10n.mfaCodesLeft(active.remainingCodes!) : l10n.mfaSetupEnabled,
        trailing: MfaRowActionButton(
          text: l10n.mfaRegenerateCodes,
          onPressed: () => _confirmAndRegenerate(context),
        ),
      );
    }
    return MfaOptionRow(
      title: l10n.mfaBackupCodesTitle,
      caption: l10n.mfaSetupNotSetUp,
      trailing: MfaRowActionButton(
        text: l10n.mfaGenerateCodes,
        onPressed: () => runWithStepUpOrNull(context, BlocProvider.of<SecurityCubit>(context).generateRecoveryCodes),
      ),
    );
  }

  Widget _recoveryEmailRow(BuildContext context, MfaFactorsModel listing) {
    final l10n = AppLocalizations.of(context)!;
    final active = listing.activeFactorOf(MfaMethod.recoveryEmail);

    if (active != null) {
      return MfaOptionRow(
        title: l10n.mfaRecoveryEmailTitle,
        caption: active.hint ?? l10n.mfaSetupEnabled,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showRecoveryEmailManageSheet(context, active, listing),
      );
    }
    return MfaOptionRow(
      title: l10n.mfaRecoveryEmailTitle,
      caption: l10n.mfaSetupNotSetUp,
      trailing: MfaRowActionButton(
        text: l10n.mfaSetupSetUp,
        onPressed: BlocProvider.of<SecurityCubit>(context).startRecoveryEmail,
      ),
    );
  }

  /// Regenerating kills the old set immediately — confirmed first.
  Future<void> _confirmAndRegenerate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<SecurityCubit>(context);
    final confirmed = await RMDestructiveConfirmationSheet.show(
      context: context,
      title: l10n.mfaBackupCodesTitle,
      message: l10n.mfaRegenerateCodesWarning,
      confirmationButtonText: l10n.mfaRegenerateCodes,
      cancelButtonText: l10n.cancel,
    );
    if (!context.mounted || !confirmed) return;
    await runWithStepUpOrNull(context, cubit.generateRecoveryCodes);
  }

  void _showRecoveryEmailManageSheet(BuildContext context, MfaFactorModel factor, MfaFactorsModel listing) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<SecurityCubit>(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.mfaRecoveryEmailTitle, style: Theme.of(sheetContext).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(factor.hint ?? '', style: Theme.of(sheetContext).textTheme.bodySmall),
              const SizedBox(height: 24),
              RMTextButton(
                isLoading: false,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  cubit.startRecoveryEmail();
                },
                text: l10n.change,
              ),
              const SizedBox(height: 12),
              RMSecondaryTextButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await _confirmAndRemoveFactor(context,
                      title: l10n.mfaRecoveryEmailTitle, factor: factor, listing: listing);
                },
                child: Text(l10n.remove),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Manages the enrolled passkeys: each lists for rename/removal, and a new
/// one can be added when policy permits and the device is capable. Mutations
/// run while the sheet is up, so it carries its own error listener (the
/// screen's dialog no-ops when its route isn't current); a sub-flow state
/// (e.g. the email proof after the last factor was removed) pops the sheet so
/// the screen behind can take over.
class _PasskeysSheet extends StatelessWidget {
  const _PasskeysSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<SecurityCubit>(context);

    return BlocConsumer<SecurityCubit, MfaEnrolmentState>(
      listener: (context, state) {
        if (state is! MfaSetupMethodList) {
          Navigator.of(context).pop();
          return;
        }
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
      },
      builder: (context, state) {
        final listing = state is MfaSetupMethodList ? state.factors : null;
        final passkeys = listing?.activeFactorsOf(MfaMethod.passkey) ?? const <MfaFactorModel>[];
        final permitted = listing?.permittedMethods.contains(MfaMethod.passkey) ?? false;
        final canAdd = permitted && cubit.passkeySupported;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.mfaPasskeysTitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(permitted ? l10n.mfaPasskeysIntro : l10n.mfaPasskeysDisallowed,
                    style: Theme.of(context).textTheme.bodySmall),
                if (permitted && !cubit.passkeySupported) ...[
                  const SizedBox(height: 8),
                  Text(l10n.mfaPasskeysUnsupportedDevice, style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final passkey in passkeys)
                          if (listing != null) _PasskeyTile(passkey: passkey, listing: listing),
                      ],
                    ),
                  ),
                ),
                if (canAdd) ...[
                  const SizedBox(height: 12),
                  RMTextButton(
                    isLoading: state.flow.isLoading,
                    onPressed: () => runWithStepUpOrNull(context, () => cubit.setUpMethod(MfaMethod.passkey)),
                    text: l10n.mfaAddPasskey,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One enrolled passkey: label (or fallback), provider hint and dates, with
/// Rename and Remove.
class _PasskeyTile extends StatelessWidget {
  const _PasskeyTile({required this.passkey, required this.listing});

  final MfaFactorModel passkey;
  final MfaFactorsModel listing;

  String get _title => passkey.label?.isNotEmpty == true ? passkey.label! : '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _title.isNotEmpty ? _title : l10n.passkeyAuthentication;
    final details = [
      // The provider hint, unless it's already shown as the label.
      if (passkey.hint != null && passkey.hint != passkey.label) passkey.hint!,
      if (passkey.createdAt != null)
        l10n.mfaPasskeyAddedOn(DateFormat.yMMMd().format(passkey.createdAt!.toLocal())),
      if (passkey.lastUsedAt != null)
        l10n.mfaPasskeyLastUsedOn(DateFormat.yMMMd().format(passkey.lastUsedAt!.toLocal())),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: RMColors.containerBorderGrey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(details.join('\n'), style: Theme.of(context).textTheme.bodySmall),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MfaRowActionButton(text: l10n.rename, onPressed: () => _showRenameDialog(context)),
              MfaRowActionButton(
                text: l10n.remove,
                destructive: true,
                onPressed: () =>
                    _confirmAndRemoveFactor(context, title: title, factor: passkey, listing: listing),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<SecurityCubit>(context);
    final controller = TextEditingController(text: passkey.label ?? '');
    final label = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.mfaPasskeyRenameTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mfaPasskeyNameHelp, style: Theme.of(dialogContext).textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 100,
              style: Theme.of(dialogContext).textTheme.labelMedium,
              decoration: InputDecoration(hintText: l10n.mfaPasskeyNamePlaceholder),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: Text(l10n.save)),
        ],
      ),
    );
    final trimmed = label?.trim() ?? '';
    controller.dispose();
    if (!context.mounted || trimmed.isEmpty || trimmed == passkey.label) return;
    await runWithStepUpOrNull(context, () => cubit.renameFactor(passkey.id, trimmed));
  }
}

/// The freshly minted backup codes: monospace grid, copy + share, and the
/// acknowledgement checkbox gating the way out.
class _RecoveryCodesStep extends StatefulWidget {
  const _RecoveryCodesStep({required this.codes});

  final List<String> codes;

  @override
  State<_RecoveryCodesStep> createState() => _RecoveryCodesStepState();
}

class _RecoveryCodesStepState extends State<_RecoveryCodesStep> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final codeStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: const ['Menlo', 'Courier'],
          fontWeight: FontWeight.bold,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(l10n.saveRecoveryCodes, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(l10n.recoveryCodesCanBeUsed, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(l10n.putTheseInASafeSpot, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: RMColors.containerBorderGrey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              for (final code in widget.codes)
                SizedBox(
                  width: 120,
                  child: Text(code, style: codeStyle),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: RMSecondaryTextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.codes.join('\n')));
                  if (context.mounted) {
                    showStyledSnackbar(context, SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                        l10n.copiedToClipboard);
                  }
                },
                child: Text(l10n.copyCodes),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RMSecondaryTextButton(
                onPressed: () => SharePlus.instance.share(ShareParams(text: widget.codes.join('\n'))),
                child: Text(l10n.shareCodes),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _acknowledged,
          onChanged: (value) => setState(() => _acknowledged = value ?? false),
          title: Text(l10n.iSavedMyBackupCodes, style: Theme.of(context).textTheme.bodySmall),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        RMTextButton(
          isLoading: false,
          onPressed: _acknowledged ? BlocProvider.of<SecurityCubit>(context).backToList : null,
          text: l10n.done,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Address entry for a new recovery email; the code entry follows.
class _RecoveryEmailEntryStep extends StatefulWidget {
  const _RecoveryEmailEntryStep({required this.isLoading});

  final bool isLoading;

  @override
  State<_RecoveryEmailEntryStep> createState() => _RecoveryEmailEntryStepState();
}

class _RecoveryEmailEntryStepState extends State<_RecoveryEmailEntryStep> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = BlocProvider.of<SecurityCubit>(context);

    return MfaSubFlow(
      title: l10n.mfaAddRecoveryEmail,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mfaRecoveryEmailExplanation, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            Text(l10n.eMail, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              style: Theme.of(context).textTheme.labelMedium,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value?.isEmpty != false) return l10n.emailRequired;
                if (!EmailValidator.validate(value!)) return l10n.pleaseEnterAValidEmailAddress;
                return null;
              },
            ),
            const SizedBox(height: 24),
            RMTextButton(
              isLoading: widget.isLoading,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  runWithStepUpOrNull(context, () => cubit.submitRecoveryEmail(_emailController.text.trim()));
                }
              },
              text: l10n.sendCode,
            ),
          ],
        ),
      ),
    );
  }
}
