import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:collection/collection.dart';
import 'package:road_mobile/data/model/cards/authorize_tokenization_model.dart';
import 'package:road_mobile/data/model/cards/available_payment_methods_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/add_address_screen.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_repo.dart';
import 'package:road_mobile/data/model/account/account_details_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/services/environment/config.dart';

part 'add_credit_card_state.dart';
part 'add_credit_card_cubit.freezed.dart';

@injectable
class AddCreditCardCubit extends Cubit<AddCreditCardState> {
  AddCreditCardCubit(this._repo) : super(const AddCreditCardState.initial());

  final AddCreditCardRepository _repo;

  final _paymentChannel = const MethodChannel('io.e-flux.mobile/payments');

  /// Returns true for success, false for failure, null for cancelled.
  ///
  /// The Flow SDK renders a combined UI with every method the payment session enables
  /// (card form + Google Pay / Apple Pay button as applicable), so a single entry
  /// point here is enough — no client-side payment method picker required.
  Future<bool> startAddPaymentMethodFlow(
    BuildContext context,
    String sourceWidget, {
    int? currentStep,
    int? totalSteps,
  }) async {
    // Re-entry guard. Without this, rapid taps run two concurrent flows whose
    // setMethodCallHandler calls clobber each other and whose finallys clear
    // each other's handler, leaving the native Flow SDK presentation with a
    // broken close button.
    if (state is AddingCard && state.flow.isLoading) {
      return false;
    }

    // Resolve the localised pay-button label + active language while we have a
    // valid context, to pass down to the native Checkout Flow SDK. The SDK's
    // button otherwise reads "Pay", which is misleading — we're storing a card.
    final payButtonLabel = AppLocalizations.of(context)!.saveCard;
    final localeCode = Localizations.localeOf(context).languageCode;

    var profile = switch (BlocProvider.of<AuthCubit>(context).state) {
      LoggedIn(profile: final profile, token: _, flow: _) => profile,
      _ => null,
    };

    if (profile == null) {
      emit(AddCreditCardState.addingCard(flow: UIFlow.error(RMApiError(cause: 'Missing account details.'))));
      return false;
    }

    if (!profile.canAddCreditCard) {
      log('User cannot add credit card, bailing with add CC flow.');
      return false;
    }

    final countryString = profile.countryCode;
    if (countryString == null) {
      emit(AddCreditCardState.addingCard(flow: UIFlow.error(RMApiError(cause: 'Missing country code.'))));
      return false;
    }

    final country = Country.tryParse(countryString);
    if (country == null) {
      emit(AddCreditCardState.addingCard(flow: UIFlow.error(RMApiError(cause: 'Invalid country code.'))));
      return false;
    }

    if (profile.isMissingAddressDetails) {
      final added = await AddAddressScreen.pushFullScreen(
        context,
        isSignupFlow: sourceWidget == 'signup',
        currentStep: currentStep,
        totalSteps: totalSteps,
      );
      if (!added) {
        return false;
      }

      if (isClosed || !context.mounted) {
        return false;
      }

      final updatedAccountDetails = switch (BlocProvider.of<AuthCubit>(context).state) {
        LoggedIn(profile: final accountDetails, token: _, flow: _) => accountDetails,
        _ => null,
      };

      if (updatedAccountDetails == null) {
        emit(AddCreditCardState.addingCard(
            flow: UIFlow.error(RMApiError(cause: 'Missing account details after update.'))));
        return false;
      }

      profile = updatedAccountDetails;
    }

    return _addCard(profile, sourceWidget, payButtonLabel, localeCode);
  }

  Future<bool> _addCard(
    AccountDetailsModel? accountDetails,
    final String sourceWidget,
    final String payButtonLabel,
    final String localeCode,
  ) async {
    if (accountDetails == null) {
      emit(AddCreditCardState.addingCard(flow: UIFlow.error(RMApiError(cause: 'Missing account details.'))));
      return false;
    }

    final billingCurrency = accountDetails.billingCurrency;
    final countryCode = accountDetails.countryCode;
    if (billingCurrency == null || billingCurrency.isEmpty) {
      emit(AddCreditCardState.addingCard(flow: UIFlow.error(RMApiError(cause: 'Missing billing currency.'))));
      return false;
    }
    if (countryCode == null || countryCode.isEmpty) {
      emit(AddCreditCardState.addingCard(flow: UIFlow.error(RMApiError(cause: 'Missing country code.'))));
      return false;
    }

    emit(const AddCreditCardState.addingCard(flow: UIFlow.loading()));

    try {
      // 1. Get available payment methods (with IDs). Used to match the tokenised
      //    method against one of the account's configured PayBridge payment-method IDs.
      final availableMethods = await _repo.getAvailablePaymentMethods();
      if (isClosed) return false;
      if (availableMethods.data.isEmpty) {
        emit(state.copyWith(
            flow: UIFlow.error(RMApiError(cause: 'No payment methods available for your account.'))));
        return false;
      }

      // 2. Create a payment session
      final paymentSession = await _repo.createPaymentSession();
      if (isClosed) return false;

      // 3. Install handler for reverse native→Dart call.
      //    Native fires this from handleSubmit with the type (card/googlepay/applepay)
      //    and scheme of whatever the user actually picked in the Flow SDK UI.
      String? matchedPaymentMethodId;
      _paymentChannel.setMethodCallHandler((call) async {
        if (call.method != 'authorizeTokenization') return null;
        final args = (call.arguments as Map).cast<String, dynamic>();
        final sessionData = args['sessionData'] as String;
        final scheme = (args['scheme'] as String?)?.toLowerCase();
        final type = (args['type'] as String?)?.toLowerCase();

        matchedPaymentMethodId = _resolvePaymentMethodId(availableMethods, type: type, scheme: scheme);
        if (matchedPaymentMethodId == null) {
          return {'actionData': null};
        }

        final authResponse = await _repo.authorizeTokenization(
          paymentMethodId: matchedPaymentMethodId!,
          currencyCode: billingCurrency,
          sessionId: paymentSession['id']!,
          sessionData: sessionData,
        );

        // Normalise the BE response into the `actionData` shape the native side
        // passes to the SDK. Per-platform status handling lives in
        // [normaliseTokenizationResult].
        final normalised = normaliseTokenizationResult(authResponse.action, type, isIOS: Platform.isIOS);
        return {'actionData': json.encode(normalised)};
      });

      // 4. Invoke native Flow SDK
      final accountDetailsMap = accountDetails.toMapForCreditCard();
      accountDetailsMap['environment'] = getIt<Stage>().target.name;
      accountDetailsMap['primaryColorRed'] = (RMColors.rmPrimaryColor.r * 255.0).round().clamp(0, 255).toString();
      accountDetailsMap['primaryColorGreen'] = (RMColors.rmPrimaryColor.g * 255.0).round().clamp(0, 255).toString();
      accountDetailsMap['primaryColorBlue'] = (RMColors.rmPrimaryColor.b * 255.0).round().clamp(0, 255).toString();
      accountDetailsMap['primaryColorValue'] = RMColors.rmPrimaryColor.toARGB32().toString();
      accountDetailsMap['apiKey'] = getIt<Stage>().target == StageTarget.staging
          ? Config.checkoutSandboxPublicKey
          : Config.checkoutProductionPublicKey;
      accountDetailsMap['paymentSessionId'] = paymentSession['id']!;
      accountDetailsMap['paymentSessionSecret'] = paymentSession['paymentSessionSecret']!;
      // Native maps localeCode → the SDK's locale and overrides the pay button's
      // label (otherwise "Pay") with this localised string under that locale.
      accountDetailsMap['payButtonLabel'] = payButtonLabel;
      accountDetailsMap['localeCode'] = localeCode;

      // Apple Pay needs a merchant identifier. Pass both so iOS native can pick based on env.
      final isProduction = getIt<Stage>().target != StageTarget.staging;
      final applePayMerchantId =
          isProduction ? F.productionApplePayMerchantId : F.stagingApplePayMerchantId;
      if (applePayMerchantId != null) {
        accountDetailsMap['applePayMerchantId'] = applePayMerchantId;
      }

      final String? result;
      try {
        result = await _paymentChannel.invokeMethod<String>('addPaymentCard', accountDetailsMap);
      } finally {
        _paymentChannel.setMethodCallHandler(null);
      }

      if (isClosed) return false;

      if (result == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Platform failed on addPaymentCard.'))));
        log('Platform returned null on addPaymentCard');
        return false;
      }

      if (result == 'CANCELLED') {
        emit(state.copyWith(flow: const UIFlow.established()));
        return false;
      }

      if (result.startsWith('ERROR:')) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: result))));
        return false;
      }

      // 5. Native returns "SUCCESS:<paymentId>" after SDK has completed (incl. 3DS).
      //    For wallets the SDK hands back the paymentId formatted as "<id>:<type>"
      //    (e.g. "pay_abc:applepay"); the BE wants just the payment id, so strip
      //    anything after the first colon. Checkout payment ids are colon-free.
      if (!result.startsWith('SUCCESS:')) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Unexpected native result: $result'))));
        return false;
      }
      final paymentProviderReference = result.substring('SUCCESS:'.length).split(':').first;

      if (matchedPaymentMethodId == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Missing payment method ID after tokenization.'))));
        return false;
      }

      // 6. Store the tokenization result
      await _repo.storeTokenization(
        paymentMethodId: matchedPaymentMethodId!,
        currencyCode: billingCurrency,
        countryCode: countryCode,
        paymentProviderReference: paymentProviderReference,
      );

      if (isClosed) return false;
      // TODO(DRI-643): PayBridge is eventually consistent — the newly added card may
      // not appear in the payment instruments list for a short time after store-tokenization
      // returns. Consider optimistic UI: use the StoreTokenizationDataModel response
      // (id, paymentMethod, displayIdentifier, expiresAt) to show the card immediately.
      emit(AddCreditCardState.cardAdded(sourceWidget: sourceWidget));
      return true;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Picks the right `paymentMethodId` for the tokenisation result coming back
  /// from the Flow SDK. The SDK's [type] tells us card vs wallet; for wallets it
  /// maps directly. For cards, [scheme] (visa/mastercard/…) picks the right entry.
  String? _resolvePaymentMethodId(
    AvailablePaymentMethodsResponseModel availableMethods, {
    required String? type,
    required String? scheme,
  }) {
    // SDK reports wallet types as `googlepay` / `applepay`; BE stores them
    // as `google-pay` / `apple-pay`.
    const typeToBeMethod = {
      'googlepay': 'google-pay',
      'applepay': 'apple-pay',
    };
    final beMethod = typeToBeMethod[type];
    if (beMethod != null) {
      return availableMethods.data.firstWhereOrNull((m) => m.paymentMethod == beMethod)?.id;
    }
    // Cards — match by scheme, falling back to the first card method on offer.
    final matched = scheme != null && scheme.isNotEmpty ? availableMethods.methodForScheme(scheme) : null;
    if (matched == null) {
      log('No payment method matches scheme "$scheme" (type "$type"); '
          'falling back to first card method "${availableMethods.firstCardMethod?.paymentMethod}". '
          'The card may be stored under the wrong scheme.');
    }
    return matched?.id ?? availableMethods.firstCardMethod?.id;
  }

  /// Maps the BE's authorize-tokenization [action] into the `actionData` map the
  /// native layer forwards to the Checkout SDK's `handleSubmit` result.
  ///
  /// The success status differs by platform because the two Checkout SDKs use
  /// different vocabularies: iOS's Flow SDK expects "Authorized", while Android's
  /// Components SDK only accepts the BE's canonical "Approved" / "Action Required"
  /// / "Declined" and throws on "Authorized" ("unknown payment status"). [isIOS]
  /// selects the dialect.
  ///
  /// - `authorized`: terminal success carrying no status string, so we synthesise
  ///   one (iOS → "Authorized", Android → "Approved").
  /// - `paymentSessionAction`: passes the BE's `actionData` through; on iOS only,
  ///   remaps an "Approved" status to "Authorized" for the SDK state machine.
  /// - anything else (redirect/undefined): passed through untouched.
  @visibleForTesting
  static Map<String, dynamic> normaliseTokenizationResult(
    AuthorizeTokenizationAction? action,
    String? type, {
    required bool isIOS,
  }) {
    switch (action?.actionCase) {
      case ActionCase.authorized:
        return {
          'id': action?.value?.paymentProviderReference ?? '',
          'status': isIOS ? 'Authorized' : 'Approved',
          'type': type ?? 'card',
        };
      case ActionCase.paymentSessionAction:
        final normalised = Map<String, dynamic>.from(action!.value!.actionDataMap);
        if (isIOS && (normalised['status'] as String?)?.toLowerCase() == 'approved') {
          normalised['status'] = 'Authorized';
        }
        return normalised;
      default:
        return action?.value?.actionDataMap ?? {};
    }
  }
}
