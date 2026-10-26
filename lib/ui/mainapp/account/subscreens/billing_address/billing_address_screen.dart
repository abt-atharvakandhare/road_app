import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/billing_address_update_widget.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BillingAddressScreen extends StatefulWidget {
  const BillingAddressScreen({super.key});

  static void pushAsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BillingAddressScreen(),
      ),
    );
  }

  @override
  State<BillingAddressScreen> createState() => _BillingAddressScreenState();
}

class _BillingAddressScreenState extends State<BillingAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              _buildBillingAddressItems(context, state),
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

  Widget _buildBillingAddressItems(BuildContext context, AuthState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.billingAddress, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.provideYourBillingDetails, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            Column(children: [
              BillingAddressUpdateWidget(
                  buttonText: AppLocalizations.of(context)!.updateBillingInformation,
                  didUpdateAddress: () {
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                      showStyledSnackbar(
                        context,
                        SvgPicture.asset('assets/icons/snackbar_success_tick.svg'),
                        AppLocalizations.of(context)!.billingAddressSuccessfullyUpdated,
                      );
                    }
                  })
            ])
          ],
        ),
      ),
    );
  }
}
