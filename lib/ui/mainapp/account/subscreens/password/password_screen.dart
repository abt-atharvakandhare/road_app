import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/widgets/required_rich_text.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/data_validation.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/step_up/run_with_step_up.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';

import 'cubit/password_cubit.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  static void pushAsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<PasswordCubit>(),
          child: const PasswordScreen(),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordValid = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<PasswordCubit, PasswordState>(
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              _buildPasswordItems(context, state),
              Column(
                children: [
                  const Spacer(),
                  BottomLoadingWidget(isLoading: state.flow.isLoading),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPasswordItems(BuildContext context, PasswordState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._buildPasswordWidgetItems(context, state),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPasswordWidgetItems(BuildContext context, PasswordState state) {
    return [
      Text(AppLocalizations.of(context)!.password, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 8),
      Text(AppLocalizations.of(context)!.updateYourPassword, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 24),
      RequiredRichText.requiredString(
          text: AppLocalizations.of(context)!.currentPassword, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 10),
      TextFormField(
        style: Theme.of(context).textTheme.labelMedium,
        autofillHints: const [AutofillHints.password],
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        obscureText: _hideCurrentPassword,
        controller: _currentPasswordController,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                icon: SvgPicture.asset(
                    _hideCurrentPassword ? 'assets/icons/password_show.svg' : 'assets/icons/password_hide.svg'),
                onPressed: () {
                  setState(() {
                    _hideCurrentPassword = !_hideCurrentPassword;
                  });
                })),
        validator: (value) {
          if (value?.isEmpty != false) return AppLocalizations.of(context)!.passwordIsRequired;
          return null;
        },
      ),
      const SizedBox(height: 20),
      RequiredRichText.requiredString(
          text: AppLocalizations.of(context)!.newPassword, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 10),
      TextFormField(
        style: Theme.of(context).textTheme.labelMedium,
        autofillHints: const [AutofillHints.newPassword],
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        obscureText: _hideNewPassword,
        controller: _newPasswordController,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                icon: SvgPicture.asset(
                    _hideNewPassword ? 'assets/icons/password_show.svg' : 'assets/icons/password_hide.svg'),
                onPressed: () {
                  setState(() {
                    _hideNewPassword = !_hideNewPassword;
                  });
                }),
            errorMaxLines: 2),
        validator: (value) {
          return !DataValidation.validatePassword(value) ? AppLocalizations.of(context)!.passwordMustContain : null;
        },
      ),
      if (isPasswordValid)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Text(AppLocalizations.of(context)!.passwordMustContain,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: isPasswordValid ? RMColors.searchTextGrey : RMColors.errorRed)),
        ),
      const SizedBox(height: 20),
      RMTextButton(
          isLoading: state.flow.isLoading,
          onPressed: () async {
            setState(() {
              isPasswordValid = DataValidation.validatePassword(_newPasswordController.text);
            });
            if (_formKey.currentState!.validate() && isPasswordValid) {
              final success = await _changePassword(context);

              if (success && context.mounted) {
                Navigator.of(context).pop();
                showStyledSnackbar(
                  context,
                  SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                  AppLocalizations.of(context)!.passwordSuccessfullyUpdated,
                );
              }
            }
          },
          text: AppLocalizations.of(context)!.updatePassword)
    ];
  }

  /// Changing the password is step-up-gated; the save runs through
  /// [runWithStepUp]. Backing out of the step-up sheet abandons the change
  /// silently: nothing was written, and the user declined on purpose.
  Future<bool> _changePassword(BuildContext context) async {
    final cubit = BlocProvider.of<PasswordCubit>(context);
    try {
      return await runWithStepUp(
          context,
          () => cubit.changePassword(
                _currentPasswordController.text,
                _newPasswordController.text,
              ));
    } on RMApiError {
      return false;
    }
  }
}
