import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/main_signup_screen.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_secondary_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_web_view.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cubit/auth_cubit.dart';

class LoginEmailPasswordWidget extends StatefulWidget {
  const LoginEmailPasswordWidget({
    super.key,
    required this.isModal,
  });

  final bool isModal;

  @override
  State<StatefulWidget> createState() => _LoginEmailPasswordWidgetState();
}

class _LoginEmailPasswordWidgetState extends State<LoginEmailPasswordWidget> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool hidePassword = true;

  /// True while a passwordless passkey sign-in is running, so the two login
  /// buttons don't share one spinner (each spins only for its own action).
  bool _passkeyInFlight = false;

  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = BlocProvider.of<AuthCubit>(context);
    // Web-parity conditional UI: park a passwordless ceremony so the OS can
    // offer a passkey over the email field (iOS; a no-op elsewhere). Silent
    // until the user picks one, so this never disturbs the form.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startConditionalPasskeyLogin();
    });
  }

  @override
  void dispose() {
    // End the parked ceremony so it can't linger past this form and contend
    // with a later one (e.g. the post-password MFA passkey step).
    _authCubit.cancelConditionalPasskeyLogin();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startConditionalPasskeyLogin() async {
    final didLogIn = await _authCubit.startConditionalPasskeyLogin();
    if (didLogIn && mounted && widget.isModal) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: AutofillGroup(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.login)),
            const SizedBox(height: 8),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${F.appBrandName} ${AppLocalizations.of(context)!.account}',
                  style: Theme.of(context).textTheme.bodySmall,
                )),
            const SizedBox(height: 20),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.eMail, style: Theme.of(context).textTheme.titleSmall)),
            const SizedBox(height: 10),
            TextField(
                style: Theme.of(context).textTheme.labelMedium,
                // `username` first: it drives the iOS content type, which is
                // what both password autofill and the parked conditional
                // passkey ceremony attach their suggestions to.
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                controller: _usernameController),
            const SizedBox(height: 20),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.password, style: Theme.of(context).textTheme.titleSmall)),
            const SizedBox(height: 10),
            TextField(
                style: Theme.of(context).textTheme.labelMedium,
                autofillHints: const [AutofillHints.password],
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => login(context),
                obscureText: hidePassword,
                controller: _passwordController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        icon: SvgPicture.asset(
                            hidePassword ? 'assets/icons/password_show.svg' : 'assets/icons/password_hide.svg'),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        }))),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.forgotPassword);
                      final forgotPasswordLocation = BlocProvider.of<AuthCubit>(context).state.forgotPasswordUrl;
                      final String title = AppLocalizations.of(context)!.forgotPassword;

                      if (forgotPasswordLocation == null) {
                        getIt<ModalInfoDialogs>().showErrorDialog(context, RMApiError(cause: 'No forgot password URL'));
                        return;
                      }

                      RMWebView.pushAsModal(context, forgotPasswordLocation, title);
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(AppLocalizations.of(context)!.forgotPassword,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: RMColors.rmPrimaryColor))),
                    ))),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state.flow.isLoading;
                return Column(
                  children: [
                    RMTextButton(
                        isLoading: isLoading && !_passkeyInFlight,
                        onPressed: isLoading
                            ? null
                            : () {
                                getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.login);
                                login(context);
                              },
                        text: AppLocalizations.of(context)!.login),
                    if (BlocProvider.of<AuthCubit>(context).passkeySupported) ...[
                      const SizedBox(height: 12),
                      RMSecondaryTextButton(
                        onPressed: isLoading ? null : () => loginWithPasskey(context),
                        child: isLoading && _passkeyInFlight
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: RMColors.rmPrimaryColor))
                            : Text(AppLocalizations.of(context)!.signInWithAPasskey),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Text(AppLocalizations.of(context)!.dontHaveAnAccount, style: Theme.of(context).textTheme.titleSmall),
            TextButton(
                onPressed: () async {
                  getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.signup);
                  final signupUri = F.signupLink;
                  if (signupUri != null) {
                    launchUrl(signupUri, mode: LaunchMode.externalApplication);
                    return;
                  } else {
                    Navigator.of(context).pop();
                    await MainSignupScreen.pushAsModal(context);
                  }
                },
                child: Text('${AppLocalizations.of(context)!.signup} →')),
          ],
        ),
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    );
  }

  void loginWithPasskey(BuildContext context) async {
    getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.passkeyLogin);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _passkeyInFlight = true);
    final didLogIn = await BlocProvider.of<AuthCubit>(context).loginWithPasskey();
    if (!mounted) return;
    setState(() => _passkeyInFlight = false);
    if (didLogIn && context.mounted && widget.isModal) {
      Navigator.of(context).pop();
    }
  }

  void login(BuildContext context) async {
    if (_usernameController.text == 'debugcontrols' && _passwordController.text == 'enabled') {
      getIt<DebugControlsCubit>().setDebugControlsEnabled(true);
      getIt<ModalInfoDialogs>().showTextDialog(context, 'Debug controls are enabled', title: 'Success 🧌');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final didLogIn =
        await BlocProvider.of<AuthCubit>(context).performLogin(_usernameController.text, _passwordController.text);
    if (didLogIn && context.mounted && widget.isModal) {
      Navigator.of(context).pop();
    }
  }
}
