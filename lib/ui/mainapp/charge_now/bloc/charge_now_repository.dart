import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/cards/account_payment_instruments_model.dart';
import 'package:road_mobile/data/model/cards/cards_response_model.dart';
import 'package:road_mobile/data/model/cards/charging_authorizations_model.dart';
import 'package:road_mobile/data/model/cards/preauth_limits_model.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/data/model/cards/verify_and_store_response_model.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/data/model/charging/charging_start_data_model.dart';
import 'package:road_mobile/data/model/charging/current_charging_values_model.dart';
import 'package:road_mobile/data/model/charging/start_remote_session_response_model.dart';
import 'package:road_mobile/data/model/locations/locations_response_model.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/model/user/user_profile.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';

@lazySingleton
class ChargeNowRepository {
  final ApiService _apiService;

  ChargeNowRepository(this._apiService);

  Future<List<StartChargingLocationMetadata>> getAvailableChargingLocations({
    required UserLocation eventLocation,
    required List<String> partyIds,
  }) async {
    final data = {
      'nearestTo': {
        'lat': eventLocation.latitude,
        'lng': eventLocation.longitude,
      },
      'capabilities': ['REMOTE_START_STOP_CAPABLE'],
      'status': ['AVAILABLE'],
      'partyIds': partyIds,
      'restrictToProvider': F.restrictMapCallsToProvider,
      'limit': 1,
    };

    final response = await _apiService.post('/1/map/locations', data: data);
    final locationsResponse = MapLocationsResponseModel.fromJson(response.data);
    final allMetadata = StartChargingLocationMetadata.fromLocationsResponse(locationsResponse);
    // Filter to only return available EVSEs (location may have multiple EVSEs)
    return allMetadata.where((m) => m.status == ChargingPortAvailability.available).toList();
  }

  /// searchId - A text field that matches on ID, OCPI/Eclearing IDs, EVSE IDs and Name
  Future<LocationsResponseModel> getChargingLocationsWithSearchId(String searchPhrase, List<String> partyIds) async {
    // ToDo - when this call has includeUserSpecialTariffs, use only this call, not an additional call
    Map data = {'searchPhrase': searchPhrase, 'partyIds': partyIds, 'hydrate': true};

    final apiResponse = await _apiService.post('/2/locations/msp/search/fast', data: data);
    return await LocationsResponseModel.computeFromJson(apiResponse.data);
  }

  Future<MapLocationsResponseModel> getChargingLocationsDetails(List<String> locationIds) async {
    Map data = {'ids': locationIds, 'includeUserSpecialTariffs': true};

    final apiResponse = await _apiService.post('/1/map/locations', data: data);
    return MapLocationsResponseModel.fromJson(apiResponse.data);
  }

  Future<StartRemoteSessionResponseModel> startRemoteSession({required StartChargingParameters params}) async {
    final paramsJson = params.toJson();
    final response = await _apiService.post('/1/remote-sessions/msp', data: paramsJson);
    return StartRemoteSessionResponseModel.fromJson(response.data);
  }

  // PayBridge-backed listing. IDs returned here are the PayBridge payment-instrument
  // IDs that the charge-start / remote-session flow needs. The legacy
  // `/1/users/me/payment-instruments` endpoint returns IDs from a legacy view that
  // PayBridge doesn't recognise, causing "Token for PayBridge payment instrument
  // ... could not be found" when trying to charge.
  Future<PaymentInstrumentsResponseModel> _getMyCreditCards() async {
    final response = await _apiService.get('/1/accounts/self/account-payment-instruments');
    final accountResponse = AccountPaymentInstrumentsResponseModel.fromJson(response.data);
    return accountResponse.toPaymentInstrumentsResponse();
  }

  // Old method - still referenced from wallet screen.
  Future<List<RfidCardModel>> _getMyRfidCardsWithActiveToken() async {
    final profileFuture = _apiService.get('/1/users/me');
    final cardsFuture = _apiService.get('/1/cards/mine');
    final profileResponse = await profileFuture;
    final cardsResponse = await cardsFuture;
    final profile = ProfileResponseModel.fromJson(profileResponse.data);
    final cards = RfidCardsResponseModel.fromJson(cardsResponse.data);
    return cards.cardsWithActiveToken(profile.data.id) ?? [];
  }

  Future<UnifiedPaymentCards> getMyPaymentCards(
    bool getRfidCards,
    bool getCreditCards,
  ) async {
    Future<List<RfidCardModel>>? rfidCardsFuture;
    if (getRfidCards) {
      rfidCardsFuture = _getMyRfidCardsWithActiveToken();
    }

    PaymentInstrumentsResponseModel? paymentCards;
    if (getCreditCards) {
      paymentCards = (await _getMyCreditCards()).removingAdhocTokens;
    }

    List<RfidCardModel>? rfidCards;
    if (rfidCardsFuture != null) {
      rfidCards = await rfidCardsFuture;
    }

    final unifiedCards = UnifiedPaymentCards(
      rfidCards: rfidCards,
      creditCards: paymentCards?.data,
    );
    return unifiedCards;
  }

  Future<PreauthLimitsResponseModel> getPreAuthLimits(String locationId, String evseUid, String connectorId) async {
    final response = await _apiService.get('/1/remote-sessions/msp/preauth-limits/$locationId/$evseUid/$connectorId');
    return PreauthLimitsResponseModel.fromJson(response.data);
  }

  Future<ChargingSessionsResponseModel> listRemoteSessions() async {
    final response = await _apiService.get('/1/remote-sessions/msp/mine');
    return ChargingSessionsResponseModel.fromJson(response.data);
  }

  Future<void> stopRemoteSession(String remoteSessionId) async {
    await _apiService.post('/1/remote-sessions/msp/$remoteSessionId/stop', data: {});
  }

  Future<bool> cancelRemoteSession(String remoteSessionId) async {
    final response = await _apiService.post('/1/remote-sessions/msp/$remoteSessionId/cancel', data: {});
    final cancelResponse = SimpleSuccessResponseDataModel.fromJson(response.data);
    return cancelResponse.success;
  }

  Future<CurrentChargingValues?> getCurrentChargingValues(String remoteSessionId) async {
    try {
      final response = await _apiService.get('/1/active-sessions/current-charging-values/$remoteSessionId');
      log('Charging values response: $response');
      final currentChargingValuesResponse = CurrentChargingValuesResponseModel.fromJson(response.data);
      return currentChargingValuesResponse.data;
    } catch (e) {
      // This call can fail if BE does not have the charging data.
      return null;
    }
  }

  /// Registers a live activity with the backend for push updates.
  /// Returns true if registration was successful.
  Future<bool> registerLiveActivity({
    required String activeSessionId,
    required String apnToken,
    required String liveActivityId,
    required String providerSlug,
  }) async {
    log('┌─────────────────────────────────────────────────────────────');
    log('│ 🔗 REGISTERING LIVE ACTIVITY WITH BACKEND');
    log('├─────────────────────────────────────────────────────────────');
    log('│ Session ID: $activeSessionId');
    log('│ Activity ID: $liveActivityId');
    log('│ Provider Slug: $providerSlug');
    log('│ APN Token: ${apnToken.substring(0, 20)}...');
    log('└─────────────────────────────────────────────────────────────');

    try {
      final data = {
        'activeSessionId': activeSessionId,
        'apnToken': apnToken,
        'liveActivityId': liveActivityId,
        'providerSlug': providerSlug,
      };
      await _apiService.post('/1/mobile/register-live-activity', data: data);
      log('✅ Live activity registered successfully with backend');
      return true;
    } catch (e) {
      log('❌ Failed to register live activity with backend: $e');
      return false;
    }
  }
}
