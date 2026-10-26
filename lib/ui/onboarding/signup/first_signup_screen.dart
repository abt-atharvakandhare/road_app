import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:road_mobile/data/model/signup/signup_screen_data.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/login_screen.dart';
import 'package:road_mobile/ui/onboarding/signup/widgets/checkbox_link_form_field.dart';
import 'package:road_mobile/ui/onboarding/signup/widgets/verification_step_indicator.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/data_validation.dart';
import 'package:road_mobile/ui/utils/widgets/rm_country_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'cubit/signup_cubit.dart';
import '../../utils/widgets/required_rich_text.dart';

class FirstSignupScreen extends StatefulWidget {
  const FirstSignupScreen({super.key});

  @override
  State<FirstSignupScreen> createState() => _FirstSignupScreenState();
}

class _FirstSignupScreenState extends State<FirstSignupScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  Country residenceCountry = Country.tryParse('NL')!;
  Country phoneCountry = Country.tryParse('NL')!;
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  bool acceptTos = false;
  bool acceptProcessData = false;
  bool iWantToReceiveNews = false;
  bool isPasswordValid = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _buildFirstScreen(context);
  }

  @override
  void initState() {
    super.initState();

    final locationState = BlocProvider.of<LocationBloc>(context).state;
    switch (locationState) {
      case LocationProvided(:final userLocation):
        BlocProvider.of<SignupCubit>(context).provideUserLocation(userLocation).then((country) {
          if (country != null) {
            setState(() {
              residenceCountry = country;
              phoneCountry = country;
            });
          }
        });
        break;
      default:
        break;
    }
  }

  Widget _buildFirstScreen(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        switch (state) {
          case CreateAccount(:final supportedCountries):
            return SingleChildScrollView(
              child: SafeArea(
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              VerificationStepIndicator(
                                currentStep: state.currentStep,
                                totalSteps: state.totalSteps,
                                stepTitle: AppLocalizations.of(context)!.createAccount,
                              ),
                              const SizedBox(height: 10),
                              Text(AppLocalizations.of(context)!.createYourFreeAccount),
                              const SizedBox(height: 24),
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
                                          key: const Key('first_name_field'),
                                          controller: firstNameController,
                                          autofillHints: const [AutofillHints.givenName],
                                          style: Theme.of(context).textTheme.labelMedium,
                                          textCapitalization: TextCapitalization.sentences,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) => value?.isEmpty != false
                                              ? AppLocalizations.of(context)!.firstNameRequired
                                              : null,
                                          decoration: InputDecoration(
                                            errorMaxLines: 2,
                                          ),
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
                                          key: const Key('last_name_field'),
                                          controller: lastNameController,
                                          autofillHints: const [AutofillHints.familyName],
                                          style: Theme.of(context).textTheme.labelMedium,
                                          textCapitalization: TextCapitalization.sentences,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) => value?.isEmpty != false
                                              ? AppLocalizations.of(context)!.lastNameRequired
                                              : null,
                                          decoration: InputDecoration(
                                            errorMaxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              RequiredRichText.requiredString(
                                  text: AppLocalizations.of(context)!.country,
                                  style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              RMCountryPickerWidget(
                                country: residenceCountry,
                                onSelect: (newCountry) {
                                  // Only allow selection of supported countries
                                  if (supportedCountries.contains(newCountry.countryCode)) {
                                    setState(() {
                                      residenceCountry = newCountry;
                                    });
                                  }
                                },
                                supportedCountries: supportedCountries,
                              ),
                              const SizedBox(height: 20),
                              RequiredRichText.requiredString(
                                  text: AppLocalizations.of(context)!.phoneNumber,
                                  style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RMCountryPickerWidget(
                                    country: phoneCountry,
                                    shortVersion: true,
                                    onSelect: (newCountry) {
                                      // Only allow selection of supported countries
                                      if (supportedCountries.contains(newCountry.countryCode)) {
                                        setState(() {
                                          phoneCountry = newCountry;
                                        });
                                      }
                                    },
                                    supportedCountries: supportedCountries,
                                  ),
                                  const SizedBox(width: 23),
                                  Flexible(
                                    child: TextFormField(
                                      key: const Key('phone_field'),
                                      controller: phoneNumberController,
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
                                          isoCode = IsoCode.fromJson(phoneCountry.countryCode);
                                          // ignore: empty_catches
                                        } catch (e) {}
                                        final number = PhoneNumber.parse(value, destinationCountry: isoCode);
                                        if (!number.isValid()) {
                                          return AppLocalizations.of(context)!.invalidPhoneNumber;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        errorMaxLines: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              RequiredRichText.requiredString(
                                  text: AppLocalizations.of(context)!.eMail,
                                  style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              TextFormField(
                                key: const Key('email_field'),
                                controller: emailController,
                                autofillHints: const [AutofillHints.email, AutofillHints.newUsername],
                                style: Theme.of(context).textTheme.labelMedium,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value?.isEmpty != false) return AppLocalizations.of(context)!.emailRequired;
                                  if (!EmailValidator.validate(value!)) {
                                    return AppLocalizations.of(context)!.pleaseEnterAValidEmailAddress;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              RequiredRichText.requiredString(
                                  text: AppLocalizations.of(context)!.password,
                                  style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              TextFormField(
                                key: const Key('password_field'),
                                controller: passwordController,
                                autofillHints: const [AutofillHints.newPassword],
                                style: Theme.of(context).textTheme.labelMedium,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                obscureText: hidePassword,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        icon: SvgPicture.asset(hidePassword
                                            ? 'assets/icons/password_show.svg'
                                            : 'assets/icons/password_hide.svg'),
                                        onPressed: () {
                                          setState(() {
                                            hidePassword = !hidePassword;
                                          });
                                        }),
                                    errorMaxLines: 3),
                                validator: (value) {
                                  return !DataValidation.validatePassword(value)
                                      ? AppLocalizations.of(context)!.passwordMustContain
                                      : null;
                                },
                              ),
                              if (isPasswordValid)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                                  child: Text(AppLocalizations.of(context)!.passwordMustContain,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: isPasswordValid ? RMColors.searchTextGrey : RMColors.errorRed)),
                                ),
                            ])),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 24),
                          child: Column(
                            children: [
                              CheckboxLinkFormField(
                                plainText: '${AppLocalizations.of(context)!.iAcceptThe} ',
                                linkText: AppLocalizations.of(context)!.termsOfService,
                                linkUrl: BlocProvider.of<AuthCubit>(context).state.tosUrl,
                                isRequired: true,
                                value: acceptTos,
                                onChanged: (value) => setState(() => acceptTos = value!),
                                validator: (value) =>
                                    value != true ? AppLocalizations.of(context)!.acceptTermsAndConditions : null,
                              ),
                              CheckboxLinkFormField(
                                  plainText: AppLocalizations.of(context)!
                                      .iUnderstandThat
                                      .replaceAll('--brandname--', F.appBrandName),
                                  linkText: ' ${AppLocalizations.of(context)!.privacyStatement}',
                                  linkUrl: BlocProvider.of<AuthCubit>(context).state.privacyUrl,
                                  isRequired: true,
                                  value: acceptProcessData,
                                  onChanged: (value) => setState(() => acceptProcessData = value!),
                                  validator: (value) =>
                                      value != true ? AppLocalizations.of(context)!.acceptPrivacyStatement : null),
                              CheckboxLinkFormField(
                                  plainText: '${AppLocalizations.of(context)!.iWantToReceive} ',
                                  linkText: AppLocalizations.of(context)!.privacyStatement,
                                  linkUrl: BlocProvider.of<AuthCubit>(context).state.privacyUrl,
                                  isRequired: false,
                                  value: iWantToReceiveNews,
                                  onChanged: (value) => setState(() => iWantToReceiveNews = value!)),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: RMTextButton(
                              isLoading: state.flow.isLoading,
                              onPressed: () {
                                setState(() {
                                  isPasswordValid = DataValidation.validatePassword(passwordController.text);
                                });
                                if (_formKey.currentState!.validate() && isPasswordValid) {
                                  BlocProvider.of<SignupCubit>(context).signup(context, currentData);
                                }
                              },
                              text: AppLocalizations.of(context)!.createAccount),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.alreadyHaveAnAccount,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await LoginScreen.pushAsModal(context);
                            },
                            child: Text(AppLocalizations.of(context)!.login)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          case OfferAddPayment():
          case OfferMfaSetup():
          case SignupCompleted():
          case VerifyPhone():
          case VerifyEmail():
            return const SizedBox();
        }
      },
    );
  }

  SignupScreenData get currentData {
    return SignupScreenData(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      phoneNumber: phoneNumberController.text,
      email: emailController.text,
      password: passwordController.text,
      residenceCountry: residenceCountry,
      phoneCountry: phoneCountry,
      acceptTos: acceptTos,
      acceptProcessData: acceptProcessData,
      iWantToReceiveNews: iWantToReceiveNews,
    );
  }
}
