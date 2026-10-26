import 'package:equatable/equatable.dart';
import 'package:road_mobile/data/model/locations/locations_response_model.dart';
import 'package:road_mobile/data/model/locations/remote_sessions_available_model.dart';

/// Encapsulating object for each individual connector
class ChargingConnector extends Equatable {
  const ChargingConnector({
    required this.evse,
    required this.connector,
  });

  final RemoteSessionAvailableModel evse;
  final Connector connector;

  @override
  List<Object?> get props => [evse, connector];

  String get displayString => evse.id;
}
