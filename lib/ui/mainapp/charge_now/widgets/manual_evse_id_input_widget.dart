import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../bloc/charge_now_bloc.dart';

class ManualEvseIdInputWidget extends StatefulWidget {
  const ManualEvseIdInputWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ManualEvseIdInputWidgetState();
}

class _ManualEvseIdInputWidgetState extends State<ManualEvseIdInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.manualStationInput, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.findTheStickerEnterTheDigits,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.stationId, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            TextField(
              style: Theme.of(context).textTheme.labelMedium,
              keyboardType: TextInputType.number,
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                hintText: '1234567',
              ),
              onChanged: (value) => setState(() {}),
              onTap: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.example, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'NL*EFL*EV', style: Theme.of(context).textTheme.bodySmall),
              TextSpan(
                  text: '1234567', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
              TextSpan(text: ' → input ', style: Theme.of(context).textTheme.bodySmall),
              TextSpan(
                  text: '1234567', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(height: 10),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'EV', style: Theme.of(context).textTheme.bodySmall),
              TextSpan(
                  text: '1234567', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
              TextSpan(text: ' → input ', style: Theme.of(context).textTheme.bodySmall),
              TextSpan(
                  text: '1234567', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(height: 30),
            BlocBuilder<ChargeNowBloc, ChargeNowState>(
              builder: (context, state) {
                final isLoading = state.flow.isLoading;
                return RMTextButton(
                    isLoading: isLoading,
                    onPressed: _controller.text.length < 7
                        ? null
                        : () {
                            final partyIds = BlocProvider.of<AuthCubit>(context).state.remoteSessionEnabledPartyIds;
                            final userLocation = BlocProvider.of<LocationBloc>(context).state.lastKnownLocation;
                            BlocProvider.of<ChargeNowBloc>(context)
                                .add(ChargeNowEvent.manualEvseIdSubmitted(_controller.text, partyIds, userLocation));
                          },
                    text: AppLocalizations.of(context)!.continueStr);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
