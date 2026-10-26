import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/cards/authorize_tokenization_model.dart';
import 'package:road_mobile/data/model/cards/available_payment_methods_model.dart';
import 'package:road_mobile/data/model/cards/store_tokenization_model.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

@lazySingleton
class AddCreditCardRepository {
  final ApiService _apiService;

  AddCreditCardRepository(this._apiService);

  Future<AvailablePaymentMethodsResponseModel> getAvailablePaymentMethods() async {
    final response = await _apiService.get(
      '/1/accounts/self/available-payment-methods?context=individual.msp_remote_sessions',
    );
    return AvailablePaymentMethodsResponseModel.fromJson(response.data);
  }

  Future<Map<String, String>> createPaymentSession() async {
    final response = await _apiService.post(
      '/1/accounts/self/authorize-payment-session',
      data: {
        'redirectUrl': 'https://success.payment.complete/',
      },
    );
    final data = response.data['data'];
    final sessionData = data['sessionData'];
    // Normalize: parse to Map then re-encode as compact JSON
    final sessionMap = sessionData is String
        ? json.decode(sessionData) as Map<String, dynamic>
        : sessionData as Map<String, dynamic>;
    final sessionSecret = sessionMap['payment_session_secret'] as String?;
    if (sessionSecret == null) {
      throw RMApiError(cause: 'Payment session response missing payment_session_secret.');
    }
    return {
      'id': data['id'] as String,
      'paymentSessionSecret': sessionSecret,
      'sessionData': json.encode(sessionMap),
    };
  }

  Future<StoreTokenizationDataModel> storeTokenization({
    required String paymentMethodId,
    required String currencyCode,
    required String countryCode,
    required String paymentProviderReference,
  }) async {
    final response = await _apiService.post(
      '/1/accounts/self/store-tokenization',
      data: {
        'paymentMethodId': paymentMethodId,
        'currencyCode': currencyCode,
        'countryCode': countryCode,
        'tokenizationData': {
          'case': 'card',
          'value': {
            'paymentProviderReference': paymentProviderReference,
          },
        },
      },
    );
    return StoreTokenizationResponseModel.fromJson(response.data).data;
  }

  Future<AuthorizeTokenizationDataModel> authorizeTokenization({
    required String paymentMethodId,
    required String currencyCode,
    required String sessionId,
    required String sessionData,
  }) async {
    final response = await _apiService.post(
      '/1/accounts/self/authorize-tokenization',
      data: {
        'paymentMethodId': paymentMethodId,
        'currencyCode': currencyCode,
        'tokenizationData': {
          'case': 'paymentSession',
          'value': {
            'id': sessionId,
            'sessionData': sessionData,
          },
        },
      },
    );
    return AuthorizeTokenizationResponseModel.fromJson(response.data).data;
  }
}
