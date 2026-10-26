import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/step_up/run_with_step_up.dart';
import 'package:road_mobile/ui/utils/widgets/required_rich_text.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_country_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/account_verify_prompt_banner.dart';
import '../../widgets/verified_element_widget.dart';
import '../../widgets/verify_code_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static void pushAsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  Country _phoneCountry = Country.tryParse('NL')!;
  bool _havePopulatedData = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final authState = BlocProvider.of<AuthCubit>(context).state;
    switch (authState) {
      case LoggedIn(:final profile):
        _firstNameController.text = profile.firstName ?? '';
        _lastNameController.text = profile.lastName ?? '';
        _emailController.text = profile.email;
        _phoneNumberController.text = profile.phoneNo ?? '';
        _phoneCountry = Country.tryParse(profile.phoneCountryCode ?? 'NL')!;
        _havePopulatedData = true;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
          if (!_havePopulatedData) {}
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              _buildProfileItems(context, state),
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

  Widget _buildProfileItems(BuildContext context, AuthState state) {
    final accountDetails = switch (state) {
      LoggedIn(:final profile) => profile,
      _ => null,
    };
    final showEmailVerified =
        accountDetails != null && accountDetails.emailVerificationEnabled && accountDetails.isEmailVerified;
    final showNeedToVerifyEmail =
        accountDetails != null && accountDetails.emailVerificationEnabled && !accountDetails.isEmailVerified;
    final showPhoneVerified = accountDetails != null &&
        accountDetails.mobileNumberVerificationEnabled &&
        accountDetails.isMobileNumberVerified;
    final showNeedToVerifyPhone = accountDetails != null &&
        accountDetails.mobileNumberVerificationEnabled &&
        !accountDetails.isMobileNumberVerified;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.profile, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              AppLocalizations.of(context)!.manageYourPersonalContactInformation,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RequiredRichText.requiredString(
                              text: AppLocalizations.of(context)!.firstName,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _firstNameController,
                            autofillHints: const [AutofillHints.givenName],
                            style: Theme.of(context).textTheme.labelMedium,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value?.isEmpty != false ? AppLocalizations.of(context)!.firstNameRequired : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 23),
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RequiredRichText.requiredString(
                              text: AppLocalizations.of(context)!.lastName,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _lastNameController,
                            autofillHints: const [AutofillHints.familyName],
                            style: Theme.of(context).textTheme.labelMedium,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value?.isEmpty != false ? AppLocalizations.of(context)!.lastNameRequired : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.eMail, style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    if (showEmailVerified) VerifiedElementWidget(),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  enabled: false,
                  decoration: InputDecoration(
                    disabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: RMColors.separatorDarkGrey, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    fillColor: RMColors.separatorDarkGrey.withValues(alpha: 0.3),
                  ),
                  style: Theme.of(context).textTheme.labelMedium,
                  focusNode: null,
                ),
                const SizedBox(height: 8),
                if (showNeedToVerifyEmail)
                  AccountVerifyPromptBanner(
                    text: AppLocalizations.of(context)!.verifyYourEmailNow,
                    onTap: _showVerifyEmailModal,
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    RequiredRichText.requiredString(
                        text: AppLocalizations.of(context)!.phoneNumber, style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    if (showPhoneVerified) VerifiedElementWidget(),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RMCountryPickerWidget(
                      country: _phoneCountry,
                      shortVersion: true,
                      onSelect: (newCountry) {
                        setState(() {
                          _phoneCountry = newCountry;
                        });
                      },
                    ),
                    const SizedBox(width: 23),
                    Flexible(
                      child: TextFormField(
                        controller: _phoneNumberController,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        style: Theme.of(context).textTheme.labelMedium,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.phoneNumberRequired;
                          }
                          IsoCode? isoCode;
                          try {
                            isoCode = IsoCode.fromJson(_phoneCountry.countryCode);
                            // ignore: empty_catches
                          } catch (e) {}
                          final number = PhoneNumber.parse(value, destinationCountry: isoCode);
                          if (!number.isValid()) {
                            return AppLocalizations.of(context)!.invalidPhoneNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (showNeedToVerifyPhone)
                  AccountVerifyPromptBanner(
                    text: AppLocalizations.of(context)!.verifyYourPhoneNumberNow,
                    onTap: _showVerifyPhoneNumberModal,
                  ),
                const SizedBox(height: 32),
                RMTextButton(
                    isLoading: state.flow.isLoading,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final success = await _saveProfile(context);

                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                        showStyledSnackbar(
                          context,
                          SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                          AppLocalizations.of(context)!.profileSuccessfullyUpdated,
                        );
                      }
                    },
                    text: AppLocalizations.of(context)!.updateProfile),
              ]),
            )
          ],
        ),
      ),
    );
  }

  /// Saves the profile, sending the phone fields only when the user changed
  /// them — a phone change puts the PATCH behind the MFA step-up gate, so
  /// that path runs through [runWithStepUp]. Backing out of the step-up
  /// sheet abandons the save silently: nothing was written, and the user
  /// declined on purpose.
  Future<bool> _saveProfile(BuildContext context) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    final profile = switch (authCubit.state) {
      LoggedIn(:final profile) => profile,
      _ => null,
    };
    final phoneChanged = profile == null ||
        (profile.phoneNo ?? '') != _phoneNumberController.text ||
        (profile.phoneCountryCode ?? '') != _phoneCountry.countryCode;

    try {
      return await runWithStepUp(
          context,
          () => authCubit.updateProfile(
                _firstNameController.text,
                _lastNameController.text,
                phoneCountryCode: phoneChanged ? _phoneCountry.countryCode : null,
                phoneNumber: phoneChanged ? _phoneNumberController.text : null,
              ));
    } on RMApiError {
      return false;
    }
  }

  void _showVerifyEmailModal() {
    BlocProvider.of<AuthCubit>(context).requestVerifyEmailAddress();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (sheetContext) => BlocBuilder<AuthCubit, AuthState>(
        builder: (authContext, state) {
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: RMColors.rmPrimaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: VerifyCodeWidget(
              message: AppLocalizations.of(authContext)!.weSentYouAnEmailVerification(_emailController.text),
              didntReceiveText: AppLocalizations.of(authContext)!.didntReceiveTheEmail,
              resendText: AppLocalizations.of(authContext)!.resendEmailVerificationLink,
              onVerifyCode: (code) async {
                final success = await BlocProvider.of<AuthCubit>(authContext).confirmEmailAddress(code);
                if (success && authContext.mounted) {
                  showStyledSnackbar(
                    authContext,
                    SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                    AppLocalizations.of(authContext)!.emailAddressSuccessfullyVerified,
                  );

                  Navigator.of(authContext).pop();
                }

                return success;
              },
              onResendCode: () async {
                final success = await BlocProvider.of<AuthCubit>(authContext).requestVerifyEmailAddress();
                if (success && authContext.mounted) {
                  showStyledSnackbar(
                    authContext,
                    SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                    AppLocalizations.of(authContext)!.codeResent,
                  );
                }
              },
              isLoading: state.flow.isLoading,
            ),
          );
        },
      ),
    );
  }

  void _showVerifyPhoneNumberModal() {
    BlocProvider.of<AuthCubit>(context).requestMobileNumberVerification();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (sheetContext) => BlocBuilder<AuthCubit, AuthState>(
        builder: (authContext, state) {
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: RMColors.rmPrimaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: VerifyCodeWidget(
              message: AppLocalizations.of(authContext)!
                  .weSentYouAndSmsFullNumber('+${_phoneCountry.phoneCode} ${_phoneNumberController.text}'),
              onVerifyCode: (code) async {
                final success = await BlocProvider.of<AuthCubit>(authContext).confirmMobileNumber(code);
                if (success && authContext.mounted) {
                  showStyledSnackbar(
                    authContext,
                    SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                    AppLocalizations.of(authContext)!.phoneNumberSuccessfullyVerified,
                  );

                  Navigator.of(authContext).pop();
                }

                return success;
              },
              onResendCode: () async {
                final success = await BlocProvider.of<AuthCubit>(authContext).requestMobileNumberVerification();
                if (success && authContext.mounted) {
                  showStyledSnackbar(
                    authContext,
                    SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                    AppLocalizations.of(authContext)!.codeResent,
                  );
                }
              },
              isLoading: state.flow.isLoading,
            ),
          );
        },
      ),
    );
  }
}
