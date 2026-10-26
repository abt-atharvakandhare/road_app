import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/billing_address_update_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_loader.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/onboarding/signup/widgets/verification_step_indicator.dart';

class AddAddressScreen extends StatefulWidget {
  static Future<bool> pushFullScreen(BuildContext context,
      {bool isSignupFlow = false, int? currentStep, int? totalSteps}) async {
    return await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) => BlocProvider.value(
              value: BlocProvider.of<AuthCubit>(context),
              child: AddAddressScreen(
                isSignupFlow: isSignupFlow,
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
            )));
  }

  final bool isSignupFlow;
  final int? currentStep;
  final int? totalSteps;

  const AddAddressScreen({
    super.key,
    this.isSignupFlow = false,
    this.currentStep,
    this.totalSteps,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
      if (state.flow.isError) {
        getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
      }
    }, builder: (context, state) {
      return RMLoader(
        isLoading: state.flow.isLoading,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
          body: _buildBody(context, state),
        ),
      );
    });
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.isSignupFlow && widget.currentStep != null && widget.totalSteps != null) ...[
              VerificationStepIndicator(
                currentStep: widget.currentStep!,
                totalSteps: widget.totalSteps!,
                stepTitle: AppLocalizations.of(context)!.paymentMethod,
              ),
              const SizedBox(height: 20),
            ],
            Text(AppLocalizations.of(context)!.addCreditOrDebitCard),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.byAddingAPaymentMethod.replaceAll('--brandname--', F.appBrandName),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.youWillAddYourPaymentDetails,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.supportedMethods, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                SvgPicture.asset('assets/icons/credit_card_visa_medium.svg'),
                const SizedBox(width: 10),
                SvgPicture.asset('assets/icons/credit_card_mastercard_medium.svg'),
              ],
            ),
            const SizedBox(height: 20),
            const RMSeparator(),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.billingAddress, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 20),
            BillingAddressUpdateWidget(didUpdateAddress: () {
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            }),
            const SizedBox(height: 24),
            Center(
              child: Text(AppLocalizations.of(context)!.wantToAddYourCreditOrDebitCardLater,
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            Center(
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(AppLocalizations.of(context)!.skipThisStep))),
          ]),
        ),
      ),
    );
  }
}
