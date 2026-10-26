import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';

import 'required_rich_text.dart';
import 'rm_country_widget.dart';
import 'rm_text_button.dart';

class BillingAddressUpdateWidget extends StatefulWidget {
  const BillingAddressUpdateWidget({this.buttonText, required this.didUpdateAddress, super.key});

  final String? buttonText;
  final VoidCallback didUpdateAddress;

  @override
  State<BillingAddressUpdateWidget> createState() => _BillingAddressUpdateWidgetState();
}

class _BillingAddressUpdateWidgetState extends State<BillingAddressUpdateWidget> {
  TextEditingController streetController = TextEditingController();
  TextEditingController houseNumberController = TextEditingController();
  TextEditingController postCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  late String countryCode = 'nl';

  bool apiInvalidPostcode = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final authCubit = BlocProvider.of<AuthCubit>(context);
    switch (authCubit.state) {
      case LoggedIn(:final profile):
        streetController.text = profile.address ?? '';
        houseNumberController.text = profile.addressLine2 ?? '';
        postCodeController.text = profile.postalCode ?? '';
        cityController.text = profile.city ?? '';
        countryCode = profile.countryCode ?? 'nl';
      case _:
        break;
    }
  }

  @override
  void dispose() {
    streetController.dispose();
    houseNumberController.dispose();
    postCodeController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RequiredRichText.requiredString(
              text: AppLocalizations.of(context)!.country, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          RMCountryPickerWidget(
            country: Country.parse(countryCode),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RequiredRichText.requiredString(
                        text: AppLocalizations.of(context)!.street, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: streetController,
                      autofillHints: const [AutofillHints.streetAddressLine1],
                      style: Theme.of(context).textTheme.labelMedium,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value?.isEmpty != false ? AppLocalizations.of(context)!.streetIsRequired : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 23),
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RequiredRichText.requiredString(
                        text: AppLocalizations.of(context)!.houseNumberShort,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: houseNumberController,
                      autofillHints: const [AutofillHints.streetAddressLine2],
                      style: Theme.of(context).textTheme.labelMedium,
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(errorMaxLines: 2),
                      validator: (value) =>
                          value?.isEmpty != false ? AppLocalizations.of(context)!.houseNumberIsRequired : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RequiredRichText.requiredString(
                        text: AppLocalizations.of(context)!.cityTown, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    TextFormField(
                        controller: cityController,
                        autofillHints: const [AutofillHints.addressCity],
                        style: Theme.of(context).textTheme.labelMedium,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            value?.isEmpty != false ? AppLocalizations.of(context)!.cityIsRequired : null),
                  ],
                ),
              ),
              const SizedBox(width: 23),
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RequiredRichText.requiredString(
                        text: AppLocalizations.of(context)!.postCode, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: postCodeController,
                      autofillHints: const [AutofillHints.postalCode],
                      style: Theme.of(context).textTheme.labelMedium,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(errorMaxLines: 2),
                      onChanged: (value) => {apiInvalidPostcode = false},
                      validator: (value) {
                        if (value == null || value.isEmpty != false) {
                          return AppLocalizations.of(context)!.postCodeIsRequired;
                        }
                        if (apiInvalidPostcode) {
                          return AppLocalizations.of(context)!.postCodeIsInvalid;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return RMTextButton(
                  isLoading: state.flow.isLoading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final updateResponse = await BlocProvider.of<AuthCubit>(context).updateAddressDetails(
                        address: streetController.text,
                        addressLine2: houseNumberController.text,
                        postalCode: postCodeController.text,
                        city: cityController.text,
                        countryCode: countryCode);

                    if (updateResponse != null) {
                      if (updateResponse == UpdateBillingDetailsError.invalidPostcode) {
                        apiInvalidPostcode = true;
                        _formKey.currentState!.validate();
                      }
                    } else {
                      widget.didUpdateAddress();
                    }
                  },
                  text: widget.buttonText ?? AppLocalizations.of(context)!.continueStr);
            },
          ),
        ]),
      ),
    );
  }
}
