//
//  CarPlayProcessor.swift
//  Runner
//
//  Handles CarPlay method channel communication
//

import Foundation
import Flutter
import os.log

class CarPlayProcessor {
    // MARK: - Constants
    private struct Constants {
        static let channelName = "io.e-flux.mobile/auto"

        // Method names
        static let sendLocationsMethod = "sendLocations"
        static let sendFilterDefinitionsMethod = "sendFilterDefinitions"
        static let sendFavouritesMethod = "sendFavourites"
        static let sendUiStringsMethod = "sendUiStrings"
        static let carSystemStateChangedMethod = "carSystemStateChanged"
        static let toggleHighwayModeMethod = "toggleHighwayMode"
        static let toggleCarScreenFilterMethod = "toggleCarScreenFilter"
        static let toggleFavouriteMethod = "toggleFavourite"

        // Error codes
        static let invalidArgumentsError = "INVALID_ARGUMENTS"
        static let invalidArgumentsMessage = "Invalid locations data"
    }

    // MARK: - Properties
    private let methodChannel: FlutterMethodChannel
    private var isCarPlayActive = false

    // MARK: - Initialization
    init(binaryMessenger: FlutterBinaryMessenger) {
        os_log("CarPlayProcessor: Initializing with binary messenger", log: .default, type: .info)

        methodChannel = FlutterMethodChannel(name: Constants.channelName,
                                            binaryMessenger: binaryMessenger)

        os_log("CarPlayProcessor: Method channel created with name: %@", log: .default, type: .info, Constants.channelName)

        methodChannel.setMethodCallHandler { [weak self] call, result in
            os_log("CarPlayProcessor: Received method call: %@", log: .default, type: .info, call.method)

            switch call.method {
            case Constants.sendLocationsMethod:
                os_log("CarPlayProcessor: Handling sendLocations method", log: .default, type: .info)
                self?.handleSendLocations(call: call, result: result)
            case Constants.sendFilterDefinitionsMethod:
                os_log("CarPlayProcessor: Handling sendFilterDefinitions method", log: .default, type: .info)
                self?.handleSendFilterDefinitions(call: call, result: result)
            case Constants.sendFavouritesMethod:
                os_log("CarPlayProcessor: Handling sendFavourites method", log: .default, type: .info)
                self?.handleSendFavourites(call: call, result: result)
            case Constants.sendUiStringsMethod:
                os_log("CarPlayProcessor: Handling sendUiStrings method", log: .default, type: .info)
                self?.handleSendUiStrings(call: call, result: result)
            default:
                os_log("CarPlayProcessor: Method not implemented: %@", log: .default, type: .default, call.method)
                result(FlutterMethodNotImplemented)
            }
        }

        os_log("CarPlayProcessor: Method call handler registered", log: .default, type: .info)
    }

    // MARK: - Public Methods

    /// Notify Flutter that CarPlay connection state has changed
    func notifyCarSystemStateChanged(isActive: Bool) {
        isCarPlayActive = isActive
        let stateDescription = isActive ? "active" : "inactive"
        os_log("CarPlayProcessor: Notifying Flutter that car system state changed to: %@", log: .default, type: .info, stateDescription)

        methodChannel.invokeMethod(Constants.carSystemStateChangedMethod, arguments: isActive) { result in
            if let error = result as? FlutterError {
                os_log("CarPlayProcessor: ERROR - Failed to notify Flutter: %@",
                       log: .default, type: .error, error.message ?? "Unknown error")
            } else {
                os_log("CarPlayProcessor: Successfully notified Flutter of car system state change to: %@",
                       log: .default, type: .info, stateDescription)
            }
        }
    }

    /// Request Flutter to toggle a car screen filter
    func toggleCarScreenFilter(key: String, enabled: Bool) {
        os_log("CarPlayProcessor: Requesting Flutter to toggle filter %@ to %@",
               log: .default, type: .info, key, enabled ? "true" : "false")

        methodChannel.invokeMethod(Constants.toggleCarScreenFilterMethod, arguments: [
            "key": key,
            "enabled": enabled
        ]) { result in
            if let error = result as? FlutterError {
                os_log("CarPlayProcessor: ERROR - Failed to toggle filter: %@",
                       log: .default, type: .error, error.message ?? "Unknown error")
            } else {
                os_log("CarPlayProcessor: Successfully requested filter toggle",
                       log: .default, type: .info)
            }
        }
    }

    /// Request Flutter to toggle a station's favourite status
    func toggleFavourite(locationId: String) {
        os_log("CarPlayProcessor: Requesting Flutter to toggle favourite for %@",
               log: .default, type: .info, locationId)

        methodChannel.invokeMethod(Constants.toggleFavouriteMethod, arguments: [
            "locationId": locationId
        ]) { result in
            if let error = result as? FlutterError {
                os_log("CarPlayProcessor: ERROR - Failed to toggle favourite: %@",
                       log: .default, type: .error, error.message ?? "Unknown error")
            } else {
                // Note: OK ack is immediate; the favourite toggle completes asynchronously on the Flutter side
                os_log("CarPlayProcessor: Favourite toggle request acknowledged",
                       log: .default, type: .info)
            }
        }
    }

    /// Request Flutter to toggle highway mode
    func toggleHighwayMode() {
        os_log("CarPlayProcessor: Requesting Flutter to toggle highway mode", log: .default, type: .info)

        methodChannel.invokeMethod(Constants.toggleHighwayModeMethod, arguments: nil) { result in
            if let error = result as? FlutterError {
                os_log("CarPlayProcessor: ERROR - Failed to toggle highway mode: %@",
                       log: .default, type: .error, error.message ?? "Unknown error")
            } else {
                os_log("CarPlayProcessor: Successfully requested highway mode toggle",
                       log: .default, type: .info)
            }
        }
    }

    // MARK: - Private Method Handlers

    private func handleSendLocations(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Format: { locations: [...], isHighwayModeActive: bool, highwayMode: string }
        guard let data = call.arguments as? [String: Any],
              let locations = data["locations"] as? [[String: Any]] else {
            os_log("CarPlayProcessor: ERROR - Invalid locations data format", log: .default, type: .error)
            result(FlutterError(code: Constants.invalidArgumentsError, message: Constants.invalidArgumentsMessage, details: nil))
            return
        }

        // Parse mode state
        let isHighwayModeActive = data["isHighwayModeActive"] as? Bool ?? false
        let highwayMode = data["highwayMode"] as? String ?? "auto"

        os_log("CarPlayProcessor: Received %d locations from Flutter (highwayModeActive: %@, highwayMode: %@)",
               log: .default, type: .info,
               locations.count,
               isHighwayModeActive ? "true" : "false",
               highwayMode)

        // Convert to Location objects
        var validCount = 0
        var invalidCount = 0

        let locationObjects = locations.compactMap { locationDict -> Evse? in
            guard let lat = locationDict["lat"] as? Double,
                  let lng = locationDict["lng"] as? Double,
                  let locationId = locationDict["locationId"] as? String,
                  let title = locationDict["title"] as? String,
                  let availableCount = locationDict["availableCount"] as? Int,
                  let totalCount = locationDict["totalCount"] as? Int else {
                invalidCount += 1
                os_log("CarPlayProcessor: WARNING - Invalid location data: %@", log: .default, type: .default, String(describing: locationDict))
                return nil
            }
            let chargingCount = locationDict["chargingCount"] as? Int ?? 0

            // Parse connector rows
            let rawConnectorRows = locationDict["connectorRows"] as? [[String: String]] ?? []

            validCount += 1
            return Evse(
                id: locationId,
                latitude: lat,
                longitude: lng,
                availableCount: availableCount,
                chargingCount: chargingCount,
                totalCount: totalCount,
                title: title,
                subtitle: locationDict["subtitle"] as? String ?? "",
                summary: locationDict["summary"] as? String ?? "",
                detailSubtitle: locationDict["detailSubtitle"] as? String ?? "",
                detailSummary: locationDict["detailSummary"] as? String ?? "",
                connectorRows: rawConnectorRows,
                priceText: locationDict["priceText"] as? String ?? "",
                addressText: locationDict["addressText"] as? String ?? "",
                isFavourite: locationDict["isFavourite"] as? Bool ?? false,
                favouriteButtonLabel: locationDict["favouriteButtonLabel"] as? String ?? ""
            )
        }

        os_log("CarPlayProcessor: Parsed %d valid locations, %d invalid", log: .default, type: .info, validCount, invalidCount)

        // Log sample of first few locations
        if !locationObjects.isEmpty {
            let sample = locationObjects.prefix(3).map { "\($0.title) at (\($0.latitude), \($0.longitude))" }.joined(separator: ", ")
            os_log("CarPlayProcessor: Sample locations: %@", log: .default, type: .info, sample)
        }

        // Update mode state first
        EvseManager.shared.updateModeState(isHighwayModeActive: isHighwayModeActive, highwayMode: highwayMode)

        // Send to CarPlay
        EvseManager.shared.updateNearbyEvses(locationObjects)
        os_log("CarPlayProcessor: Updated EvseManager with %d locations", log: .default, type: .info, locationObjects.count)
        result("Locations received and sent to CarPlay")
    }

    private func handleSendUiStrings(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let strings = call.arguments as? [String: String] else {
            os_log("CarPlayProcessor: ERROR - Invalid UI strings data", log: .default, type: .error)
            result(FlutterError(code: Constants.invalidArgumentsError, message: "Invalid UI strings data", details: nil))
            return
        }

        os_log("CarPlayProcessor: Received %d UI strings from Flutter", log: .default, type: .info, strings.count)

        EvseManager.shared.updateUiStrings(strings)
        result("UI strings received")
    }

    private func handleSendFilterDefinitions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let data = call.arguments as? [String: Any],
              let filterList = data["filters"] as? [[String: Any]] else {
            os_log("CarPlayProcessor: ERROR - Invalid filter definitions data", log: .default, type: .error)
            result(FlutterError(code: Constants.invalidArgumentsError, message: "Invalid filter definitions", details: nil))
            return
        }

        let items = filterList.compactMap { dict -> CarScreenFilterItem? in
            guard let key = dict["key"] as? String,
                  let label = dict["label"] as? String,
                  let type = dict["type"] as? String else {
                return nil
            }

            switch type {
            case "singleChoice", "multipleChoice":
                let selectedLabel = dict["selectedLabel"] as? String ?? ""
                let childDicts = dict["children"] as? [[String: Any]] ?? []
                let children = childDicts.compactMap { childDict -> CarScreenFilterChild? in
                    guard let childKey = childDict["key"] as? String,
                          let childLabel = childDict["label"] as? String,
                          let selected = childDict["selected"] as? Bool else {
                        return nil
                    }
                    return CarScreenFilterChild(key: childKey, label: childLabel, selected: selected)
                }
                return .group(CarScreenFilterGroup(
                    key: key, label: label, type: type,
                    selectedLabel: selectedLabel, children: children
                ))
            default: // "toggle"
                let enabled = dict["enabled"] as? Bool ?? false
                return .toggle(CarScreenFilter(key: key, label: label, enabled: enabled))
            }
        }

        os_log("CarPlayProcessor: Received %d filter items from Flutter", log: .default, type: .info, items.count)

        EvseManager.shared.updateFilterItems(items)
        result("Filter definitions received")
    }

    private func handleSendFavourites(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let data = call.arguments as? [String: Any],
              let favourites = data["favourites"] as? [[String: Any]] else {
            os_log("CarPlayProcessor: ERROR - Invalid favourites data", log: .default, type: .error)
            result(FlutterError(code: Constants.invalidArgumentsError, message: "Invalid favourites data", details: nil))
            return
        }

        let evses = favourites.compactMap { dict -> Evse? in
            guard let lat = dict["lat"] as? Double,
                  let lng = dict["lng"] as? Double,
                  let locationId = dict["locationId"] as? String,
                  let title = dict["title"] as? String,
                  let availableCount = dict["availableCount"] as? Int,
                  let totalCount = dict["totalCount"] as? Int else {
                return nil
            }
            let rawConnectorRows = dict["connectorRows"] as? [[String: String]] ?? []
            return Evse(
                id: locationId,
                latitude: lat,
                longitude: lng,
                availableCount: availableCount,
                chargingCount: dict["chargingCount"] as? Int ?? 0,
                totalCount: totalCount,
                title: title,
                subtitle: dict["subtitle"] as? String ?? "",
                summary: dict["summary"] as? String ?? "",
                detailSubtitle: dict["detailSubtitle"] as? String ?? "",
                detailSummary: dict["detailSummary"] as? String ?? "",
                connectorRows: rawConnectorRows,
                priceText: dict["priceText"] as? String ?? "",
                addressText: dict["addressText"] as? String ?? "",
                isFavourite: dict["isFavourite"] as? Bool ?? true,
                favouriteButtonLabel: dict["favouriteButtonLabel"] as? String ?? ""
            )
        }

        os_log("CarPlayProcessor: Received %d favourites from Flutter", log: .default, type: .info, evses.count)
        EvseManager.shared.updateFavourites(evses)
        result("Favourites received")
    }
}
