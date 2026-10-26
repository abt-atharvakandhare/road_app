part of 'charge_now_bloc.dart';

enum ChargeStationSelectionSource { manual, qrCode, nearbySearch }

@freezed
sealed class ChargeNowState with _$ChargeNowState {
  /// The first screen in the flow.
  const factory ChargeNowState.chargeFlowInitialScreen({@Default(UIFlow.established()) UIFlow flow}) = ConnectYourCar;

  /// Showing a list of charging stations nearby.
  const factory ChargeNowState.location(
    UserLocation? userLocation,
    List<RemoteSessionAvailableModel> evseLocations, {
    @Default(UIFlow.established()) UIFlow flow,
  }) = Location;

  /// Flow from main screen
  const factory ChargeNowState.isThisYou(
    StartChargingLocationMetadata evseLocation, {
    @Default(UIFlow.established()) UIFlow flow,
  }) = IsThisYou;

  /// When the user taps "show more charging stations".
  /// [loadingEvseId] tracks which station is currently loading (if any).
  const factory ChargeNowState.selectYourChargeStation(
    List<StartChargingLocationMetadata> evseLocations,
    bool directFromInitialScreen, {
    @Default(ChargeStationSelectionSource.manual) ChargeStationSelectionSource source,
    @Default(UIFlow.established()) UIFlow flow,
    String? loadingEvseId,
  }) = SelectYourChargeStation;

  /// When the user taps "enter manual EVSE ID".
  const factory ChargeNowState.manualEvseIdInput({@Default(UIFlow.established()) UIFlow flow}) = ManualEvseIdInput;

  /// When the user taps "scan QR code".
  const factory ChargeNowState.scanningQrCode({@Default(UIFlow.established()) UIFlow flow}) = ScanningQrCode;

  /// Station is selected, users can select their payment method from list of available methods.
  const factory ChargeNowState.startChargingSession(
    StartChargingLocationMetadata chargingStartMetadata,
    UnifiedPaymentCards cards,
    UnifiedPaymentCard? selectedCard,
    PreauthLimitsModel preAuthLimits, {
    @Default(UIFlow.established()) UIFlow flow,
  }) = StartChargingSession;

  /// Charge session is actually starting.
  const factory ChargeNowState.chargeSessionStarting(
    ChargingSessionModel session,
    UnifiedPaymentCard? card,
    DateTime attemptedStartTime, {
    @Default(UIFlow.established()) UIFlow flow,
  }) = ChargeSessionStarting;

  /// Car is charging.
  const factory ChargeNowState.carIsCharging(
    ChargingSessionModel session,
    UnifiedPaymentCard? card,
    CurrentChargingValues? currentChargingValues, {
    @Default(UIFlow.established()) UIFlow flow,
  }) = CarIsCharging;

  /// Charge session is stopping. We consider this the end of the session so the user is not blocked waiting
  /// for BE to finalize the session.
  const factory ChargeNowState.chargeSessionStopping(
    ChargingSessionModel session,
    UnifiedPaymentCard? card, {
    @Default(UIFlow.established()) UIFlow flow,
  }) = ChargeSessionStopping;

  /// Charge session has ended.
  const factory ChargeNowState.chargeSessionEnded(
    ChargingSessionModel session,
    UnifiedPaymentCard? card, {
    @Default(UIFlow.established()) UIFlow flow,
  }) = ChargeSessionEnded;
}
