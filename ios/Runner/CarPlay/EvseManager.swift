//
//  EvseManager.swift
//  Runner
//
//  Created by Mohammad Al Kalaleeb on 15/07/2025.
//

import Foundation
import os.log

/// A simple on/off filter toggle received from Flutter
struct CarScreenFilter {
    let key: String
    let label: String
    var enabled: Bool
}

/// A child option within a filter group
struct CarScreenFilterChild {
    let key: String
    let label: String
    let selected: Bool
}

/// A filter group (singleChoice or multipleChoice) received from Flutter
struct CarScreenFilterGroup {
    let key: String
    let label: String
    let type: String // "singleChoice" or "multipleChoice"
    let selectedLabel: String
    let children: [CarScreenFilterChild]
}

/// Union type for filter items sent from Flutter
enum CarScreenFilterItem {
    case toggle(CarScreenFilter)
    case group(CarScreenFilterGroup)
}

class EvseManager: ObservableObject {
    static let shared = EvseManager()

    @Published var nearbyEvses: [Evse] = []

    /// Whether highway mode filtering is currently active (speed >= 50 km/h and auto is ON)
    @Published var isHighwayModeActive: Bool = false

    /// Highway mode: "off", "auto", or "on"
    @Published var highwayMode: String = "auto"

    /// Car screen filter definitions received from Flutter (typed items: toggle or group)
    @Published var filterItems: [CarScreenFilterItem] = []

    /// Favourite stations received from Flutter for the Favourites tab
    @Published var favouriteEvses: [Evse] = []

    /// Localised UI chrome strings received from Flutter.
    /// Native code reads these with a hardcoded English fallback.
    /// @Published so subscribers refresh tab titles and list labels when
    /// Phrase OTA updates flow through.
    @Published var uiStrings: [String: String] = [:]

    /// Get a UI string by key, falling back to the provided default if not yet received from Flutter.
    func uiString(_ key: String, fallback: String) -> String {
        return uiStrings[key] ?? fallback
    }

    func updateUiStrings(_ strings: [String: String]) {
        os_log("EvseManager: Updating UI strings - %d keys", log: .default, type: .info, strings.count)
        self.uiStrings = strings
    }

    func updateNearbyEvses(_ evses: [Evse]) {
        os_log("EvseManager: Updating with %d EVSEs", log: .default, type: .info, evses.count)

        if !evses.isEmpty {
            let sample = evses.prefix(3).map { "\($0.title)" }.joined(separator: ", ")
            os_log("EvseManager: Sample EVSE names: %@", log: .default, type: .info, sample)
        } else {
            os_log("EvseManager: WARNING - Empty EVSE list received", log: .default, type: .default)
        }

        self.nearbyEvses = evses
        os_log("EvseManager: Published update to observers", log: .default, type: .info)
    }

    func updateFilterItems(_ items: [CarScreenFilterItem]) {
        os_log("EvseManager: Updating filter items - %d definitions", log: .default, type: .info, items.count)
        self.filterItems = items
    }

    /// Find a filter group by key (for sub-screen rendering)
    func filterGroup(forKey key: String) -> CarScreenFilterGroup? {
        for item in filterItems {
            if case .group(let group) = item, group.key == key {
                return group
            }
        }
        return nil
    }

    func updateFavourites(_ evses: [Evse]) {
        os_log("EvseManager: Updating favourites - %d stations", log: .default, type: .info, evses.count)
        self.favouriteEvses = evses
    }

    func updateModeState(isHighwayModeActive: Bool, highwayMode: String) {
        os_log("EvseManager: Updating mode state - highwayModeActive: %@, highwayMode: %@",
               log: .default, type: .info,
               isHighwayModeActive ? "true" : "false",
               highwayMode)

        self.isHighwayModeActive = isHighwayModeActive
        self.highwayMode = highwayMode
    }
}
