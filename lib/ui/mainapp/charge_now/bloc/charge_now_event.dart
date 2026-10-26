part of 'charge_now_bloc.dart';

@freezed
sealed class ChargeNowEvent with _$ChargeNowEvent {
  // Perform a check to see if the car is charging. If so, start an API polling timer and keep the app up to date.
  const factory ChargeNowEvent.checkChargingStatus() = CheckChargingStatus;

  // Send a location to try to automatically identify the charging station.
  const factory ChargeNowEvent.receivedLocation(UserLocation? location, List<String> partyIds) = ReceivedLocation;

  // Move to a list of charging stations within 250 meters.
  const factory ChargeNowEvent.showMoreChargingStationsTapped(
      UserLocation? location, bool directFromInitialScreen, List<String> partyIds) = ShowMoreChargingStationsTapped;

  // Move to manual charging station ID input screen.
  const factory ChargeNowEvent.manualEvseIdInputTapped() = ManualEvseIdInputTapped;

  // Move to QR code scanner screen.
  const factory ChargeNowEvent.scanQrCodeTapped() = ScanQrCodeTapped;

  // Submit and search for a manual charging station ID.
  const factory ChargeNowEvent.manualEvseIdSubmitted(
    String evseId,
    List<String> partyIds,
    UserLocation? userLocation,
  ) = ManualEvseIdSubmitted;

  // Invalid QR code scanned.
  const factory ChargeNowEvent.invalidQrCode(String errorMessage) = InvalidQrCode;

  // Select a tickbox in "is this you" screen.
  const factory ChargeNowEvent.selectChargingStation(ChargingConnector? connector) = SelectChargingStation;

  // Switch to card confirmation screen.
  const factory ChargeNowEvent.chargingStationSelected(StartChargingLocationMetadata location) =
      ChargingStationSelected;

  // After adding a new card, reload the list of payment cards.
  const factory ChargeNowEvent.reloadPaymentCards() = ReloadPaymentCards;

  // Highlight payment card within the "Payment method" screen.
  const factory ChargeNowEvent.selectNewPaymentCard(UnifiedPaymentCard newCard) = SelectNewPaymentCard;

  // Start the actual charging process.
  const factory ChargeNowEvent.startCharging(StartChargingLocationMetadata startChargingMetadata,
      UnifiedPaymentCard paymentCard, PreauthLimitsModel preauthLimits) = StartCharging;

  // Abort the attempt to start charging.
  const factory ChargeNowEvent.cancelStartCharge(ChargingSessionModel chargingSession) = CancelCharging;

  const factory ChargeNowEvent.stopCharging(ChargingSessionModel chargingSession) = StopCharging;

  // Go back one screen.
  const factory ChargeNowEvent.backButtonTapped() = BackButtonTapped;

  // The modal charge now screen has been dismissed by the user.
  const factory ChargeNowEvent.modalFlowDismissed() = ModalFlowDismissed;

  // Directly jump to the "select payment card" screen from the map.
  const factory ChargeNowEvent.chargingStationSelectedFromMap(
      MapLocationV2 location,
      map_locations_response_model.Evse evse,
      map_locations_response_model.Connector connector) = ChargingStationSelectedFromMap;

  // The user has logged out.
  const factory ChargeNowEvent.loggedOut() = ChargingLoggedOut;
}
