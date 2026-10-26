import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_cubit.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/debug_controls_widget.dart';
import 'package:road_mobile/data/model/account/account_details_model.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/link_launcher.dart';
import 'package:road_mobile/ui/utils/widgets/rm_destructive_confirmation_sheet.dart';
import 'package:road_mobile/ui/utils/widgets/rm_loader.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';

import '../../../services/intercom/intercom_utils.dart';
import 'subscreens/billing_address/billing_address_screen.dart';
import 'subscreens/notifications/notifications_settings_screen.dart';
import 'subscreens/profile/profile_screen.dart';
import 'subscreens/security/security_screen.dart';
import 'widgets/account_user_details_widget.dart';
import 'widgets/account_verify_prompt_banner.dart';

class AccountRootScreen extends StatefulWidget {
  const AccountRootScreen({super.key});

  @override
  State<AccountRootScreen> createState() => _AccountRootScreenState();
}

class _AccountRootScreenState extends State<AccountRootScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (result) => _navigatorKey.currentState!.pop(result),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) {
            return _AccountRootScreen();
          });
        },
      ),
    );
  }
}

class _AccountRootScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
      }, builder: (context, state) {
        final profile = switch (state) {
          LoggedIn(:final profile) => profile,
          _ => null,
        };
        final token = switch (state) {
          LoggedIn(:final token) => token,
          _ => null,
        };

        final isLoggedIn = profile != null && token != null;
        final accountDetails = switch (state) {
          LoggedIn(:final profile) => profile,
          _ => null,
        };

        final showNeedToVerifyEmail =
            accountDetails != null && accountDetails.emailVerificationEnabled && !accountDetails.isEmailVerified;
        final showNeedToVerifyPhone = accountDetails != null &&
            accountDetails.mobileNumberVerificationEnabled &&
            !accountDetails.isMobileNumberVerified;

        String? verifyText = showNeedToVerifyEmail && showNeedToVerifyPhone
            ? AppLocalizations.of(context)!.pleaseVerifyYourPhoneNumberAndEmail
            : showNeedToVerifyEmail
                ? AppLocalizations.of(context)!.verifyYourEmailNow
                : showNeedToVerifyPhone
                    ? AppLocalizations.of(context)!.verifyYourPhoneNumberNow
                    : null;

        return RMLoader(
          isLoading: state.flow.isLoading,
          child: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.account, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    if (isLoggedIn) ...[
                      AccountUserDetailsWidget(name: profile.name, email: profile.email),
                      if (verifyText != null) ...[
                        const SizedBox(height: 8),
                        AccountVerifyPromptBanner(
                            text: verifyText,
                            onTap: () {
                              ProfileScreen.pushAsModal(context);
                            })
                      ]
                    ] else ...[
                      const SignupNowWidget(
                          motivation: SignupNowMotivation.viewProfile, style: SignupNowStyle.extendedContainer),
                    ],
                    ..._buildProfileWidgets(context, profile, token),
                  ],
                ),
              ),
            ),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
        );
      }),
    );
  }

  List<Widget> _buildProfileWidgets(BuildContext context, AccountDetailsModel? profile, String? token) {
    final String version = getIt<PackageInfo>().version;
    final String buildNumber = getIt<PackageInfo>().buildNumber;

    final isLoggedIn = profile != null && token != null;

    return [
      if (isLoggedIn) ...[
        const SizedBox(height: 35),
        Text(F.appBrandName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 14),
        AccountLinkWidget(
            text: AppLocalizations.of(context)!.dashboard,
            leftIcon: 'assets/icons/profile_dashboard.svg',
            onPressed: () {
              getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.dashboard);
              launchProviderUri(context, BlocProvider.of<AuthCubit>(context).state.customDomain);
            }),
      ],

      if (isLoggedIn) ...[
        const RMSeparator(),
        const SizedBox(height: 35),
        Text(AppLocalizations.of(context)!.personalSettings, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 14),
        AccountLinkWidget(
            text: AppLocalizations.of(context)!.notifications,
            leftIcon: 'assets/icons/profile_notifications.svg',
            rightIcon: 'assets/icons/arrow_disclosure_right.svg',
            onPressed: () async {
              NotificationsSettingsScreen.pushAsModal(context);
            }),
        const RMSeparator(),
        AccountLinkWidget(
            text: AppLocalizations.of(context)!.profile,
            leftIcon: 'assets/icons/profile_profile.svg',
            rightIcon: 'assets/icons/arrow_disclosure_right.svg',
            onPressed: () async {
              ProfileScreen.pushAsModal(context);
            }),
        const RMSeparator(),
        AccountLinkWidget(
            text: AppLocalizations.of(context)!.passwordAndAuthentication,
            leftIcon: 'assets/icons/profile_password.svg',
            rightIcon: 'assets/icons/arrow_disclosure_right.svg',
            onPressed: () async {
              SecurityScreen.pushAsModal(context);
            }),
        const RMSeparator(),
        const SizedBox(height: 35),

        // Account settings
        Text(AppLocalizations.of(context)!.accountSettings, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 14),
        AccountLinkWidget(
            text: AppLocalizations.of(context)!.billingAddress,
            leftIcon: 'assets/icons/profile_billing_address.svg',
            rightIcon: 'assets/icons/arrow_disclosure_right.svg',
            onPressed: () async {
              BillingAddressScreen.pushAsModal(context);
            }),
        const RMSeparator(),
      ],

      const SizedBox(height: 35),
      Text(AppLocalizations.of(context)!.support, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 14),
      AccountLinkWidget(
          text: AppLocalizations.of(context)!.helpAndSupport,
          leftIcon: 'assets/icons/profile_help.svg',
          onPressed: () {
            getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.help);
            _handleHelpAndSupportPressed(context);
          }),
      const RMSeparator(),

      if (isLoggedIn) ...[
        if (F.appFlavor == Flavor.eflux) ...[
          AccountLinkWidget(
              text: AppLocalizations.of(context)!.cancelSubscription,
              leftIcon: 'assets/icons/profile_cancel_subscription.svg',
              rightIcon: 'assets/icons/arrow_disclosure_right.svg',
              onPressed: () {
                launchProviderUri(context, Uri.parse('https://www.e-flux.io/forms/cancel-subscription#card'));
              }),
          const RMSeparator(),
        ],
        AccountLinkWidget(
            text: AppLocalizations.of(context)!.removeAccount,
            leftIcon: 'assets/icons/profile_remove_account.svg',
            rightIcon: 'assets/icons/arrow_disclosure_right.svg',
            onPressed: () async {
              final confirmed = await RMDestructiveConfirmationSheet.show(
                context: context,
                title: AppLocalizations.of(context)!.removeAccount,
                message: AppLocalizations.of(context)!.areYouSureYouWantToRemoveYourAccount,
                confirmationButtonText: AppLocalizations.of(context)!.yesRemoveAccount,
                cancelButtonText: AppLocalizations.of(context)!.cancel,
                warningText: AppLocalizations.of(context)!.thisActionIsPermanent,
              );

              if (context.mounted && confirmed) {
                final didDelete = await BlocProvider.of<AuthCubit>(context).deleteAccount();
                if (context.mounted && didDelete) {
                  showStyledSnackbar(
                    context,
                    SvgPicture.asset('assets/icons/profile_remove_account.svg',
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    AppLocalizations.of(context)!.accountRemovalIsPending,
                  );
                }
              }
            }),
        const RMSeparator(),
      ],
      //
      //  About
      //
      const SizedBox(height: 35),
      Text(AppLocalizations.of(context)!.about, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 14),
      AccountLinkWidget(
          text: AppLocalizations.of(context)!.aboutUs,
          leftIcon: 'assets/icons/profile_about_us.svg',
          onPressed: () {
            launchProviderUri(context, BlocProvider.of<AuthCubit>(context).state.aboutUsUrl);
          }),
      const RMSeparator(),
      AccountLinkWidget(
          text: AppLocalizations.of(context)!.termsOfServiceOneLine,
          leftIcon: 'assets/icons/profile_terms_of_service.svg',
          onPressed: () {
            launchProviderUri(context, BlocProvider.of<AuthCubit>(context).state.tosUrl);
          }),
      const RMSeparator(),
      AccountLinkWidget(
          text: AppLocalizations.of(context)!.privacyStatementOneLine,
          leftIcon: 'assets/icons/profile_privacy_statement.svg',
          onPressed: () {
            launchProviderUri(context, BlocProvider.of<AuthCubit>(context).state.privacyUrl);
          }),
      const RMSeparator(),
      RMInkwellButton(
          padding: const EdgeInsets.symmetric(vertical: 12),
          onPressed: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 18, child: SvgPicture.asset('assets/icons/profile_app_version.svg')),
                  const SizedBox(width: 12),
                  Text('${AppLocalizations.of(context)!.appVersion}: $version ($buildNumber)',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          )),
      const RMSeparator(),
      const SizedBox(height: 35),
      if (isLoggedIn) ...[
        RMInkwellButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            icon: const SizedBox(),
            onPressed: () {
              BlocProvider.of<AuthCubit>(context).logout();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 18, child: SvgPicture.asset('assets/icons/profile_logout.svg')),
                    const SizedBox(width: 12),
                    Text(AppLocalizations.of(context)!.logout,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RMColors.errorRed)),
                  ],
                ),
              ],
            )),
        const SizedBox(height: 35),
      ],
      BlocProvider.value(
        value: getIt<DebugControlsCubit>(), // DebugControlsCubit is @singleton
        child: const DebugControlsWidget(),
      ),
    ];
  }

  Future<void> _handleHelpAndSupportPressed(BuildContext context) async {
    // On Android staging, messenger cannot be shown
    if (Platform.isAndroid && getIt<Stage>().target == StageTarget.staging) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Intercom Not Available'),
          content: const Text(
              'For technical reasons, it is not possible to open Intercom on Android while using the staging platform. Please use iOS to test Intercom on staging.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    final didLaunchIntercom = await IntercomUtils.showIntercomMessenger();
    if (!didLaunchIntercom && context.mounted) {
      launchProviderUri(context, BlocProvider.of<AuthCubit>(context).state.csuiSupportUrl);
    }
  }
}
