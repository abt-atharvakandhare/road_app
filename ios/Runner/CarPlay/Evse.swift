//
//  Location.swift
//  Runner
//
//  Created by Mohammad Al Kalaleeb on 11/07/2025.
//

import Foundation
import CoreLocation
import os.log

/// Status of a charging location for map pin display
enum EvseStatus {
    case available    // availableCount > 0 (green pin)
    case charging     // availableCount == 0 && chargingCount > 0 (blue pin)
    case unknown      // availableCount == 0 && chargingCount == 0 (red pin)
}

struct Evse {
    let id: String
    let latitude: Double
    let longitude: Double

    // Raw counts for marker color logic only
    let availableCount: Int
    let chargingCount: Int
    let totalCount: Int

    // Pre-formatted display strings from Flutter (native renders these as-is)
    let title: String
    let subtitle: String
    let summary: String
    let detailSubtitle: String
    let detailSummary: String

    // Detail screen data
    let connectorRows: [[String: String]]
    let priceText: String
    let addressText: String

    // Favourite state
    let isFavourite: Bool
    let favouriteButtonLabel: String

    /// Returns a copy with the favourite state toggled (for optimistic UI updates)
    func withToggledFavourite() -> Evse {
        Evse(id: id, latitude: latitude, longitude: longitude,
             availableCount: availableCount, chargingCount: chargingCount, totalCount: totalCount,
             title: title, subtitle: subtitle, summary: summary,
             detailSubtitle: detailSubtitle, detailSummary: detailSummary,
             connectorRows: connectorRows, priceText: priceText, addressText: addressText,
             isFavourite: !isFavourite, favouriteButtonLabel: favouriteButtonLabel)
    }

    /// Computed status based on availability counts
    var status: EvseStatus {
        if availableCount > 0 {
            return .available
        } else if chargingCount > 0 {
            return .charging
        } else {
            return .unknown
        }
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Calculate distance from a given location
    func distance(from userLocation: CLLocation?) -> CLLocationDistance? {
        guard let userLocation = userLocation else { return nil }
        return userLocation.distance(from: self.location)
    }
    
    // Format distance for display
    func formattedDistance(from userLocation: CLLocation?) -> String? {
        guard let distanceInMeters = distance(from: userLocation) else { return nil }

        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .providedUnit  // Don't auto-convert units - use what we provide

        // Detect if system uses metric or imperial
        let usesMetric = Locale.current.usesMetricSystem

        if usesMetric {
            // Metric: show meters or kilometers
            if distanceInMeters < 1000 {
                // Short distance: meters with no decimals
                formatter.numberFormatter.maximumFractionDigits = 0
                let measurement = Measurement(value: distanceInMeters, unit: UnitLength.meters)
                return formatter.string(from: measurement)
            } else {
                // Long distance: kilometers with 1 decimal
                formatter.numberFormatter.maximumFractionDigits = 1
                let measurement = Measurement(value: distanceInMeters, unit: UnitLength.meters)
                let kmMeasurement = measurement.converted(to: .kilometers)
                return formatter.string(from: kmMeasurement)
            }
        } else {
            // Imperial: show yards or miles
            let distanceInYards = distanceInMeters * 1.09361 // Convert meters to yards

            if distanceInYards < 1760 {
                // Short distance: yards with no decimals
                formatter.numberFormatter.maximumFractionDigits = 0
                let measurement = Measurement(value: distanceInYards, unit: UnitLength.yards)
                return formatter.string(from: measurement)
            } else {
                // Long distance: miles with 1 decimal
                formatter.numberFormatter.maximumFractionDigits = 1
                let measurement = Measurement(value: distanceInYards, unit: UnitLength.yards)
                let milesMeasurement = measurement.converted(to: .miles)
                return formatter.string(from: milesMeasurement)
            }
        }
    }
}
