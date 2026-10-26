//
//  RoadWidgetExtensionLiveActivity.swift
//  RoadWidgetExtension
//
//  Created by Raymond Hunter on 19/02/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

let gradient = LinearGradient(
    colors: [
    Color(red: 213.0/255.0, green: 222.0/255.0, blue: 76.0/255.0),
    Color(red: 0, green: 241.0/255.0, blue: 10.0/255.0)],
    startPoint: .leading,
    endPoint: .trailing
)

let grayTextColor = Color(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0)

// MARK: - Formatting Helpers
struct ChargingDataFormatter {
    let state: ChargingStateAttributes.ContentState

    // Assumed charging rate for extrapolation (kW)
    private static let assumedChargingRateKW: Double = 10.0

    /// Session start time for the auto-updating timer. Prefers the backend-supplied ISO8601
    /// `startedAt` because it's stable across renders. Falls back to an estimate based on
    /// `durationMinutes`, but note that estimate shifts on every render (Date() moves forward),
    /// which causes the .timer Text to re-invalidate repeatedly — avoid relying on it.
    var sessionStartTime: Date {
        if let iso = state.startedAt, let parsed = ChargingDataFormatter.iso8601.date(from: iso) {
            return parsed
        }
        return Date().addingTimeInterval(-Double(state.durationMinutes) * 60)
    }

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Extrapolate current kWh based on assumed charging rate
    /// We know the kWh at the time of last update (when durationMinutes was calculated)
    /// So we estimate additional energy based on time elapsed since then
    /// Note: In a widget, this is recalculated on each render, giving a smooth estimate
    var extrapolatedKwh: Double {
        // The state.kwh is what was measured at the backend at 'durationMinutes' ago
        // We don't have the exact update timestamp, so we use the current approximation
        // For now, just return the last known value - extrapolation would require
        // knowing when exactly the update was received
        return state.kwh
    }

    var kwhFormatted: String {
        // Energy comes directly in kWh from backend
        return String(format: "%.1f", state.kwh)
    }

    /// Formatted session cost with currency symbol, or nil if not yet reported by the backend.
    var sessionCostFormatted: String? {
        guard let cost = state.sessionCost else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = state.currency ?? "EUR"
        return formatter.string(from: NSNumber(value: cost))
    }

    var durationFormatted: String {
        let totalMinutes = state.durationMinutes
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Lock Screen Live Activity View
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ChargingStateAttributes>

    private var formatter: ChargingDataFormatter {
        ChargingDataFormatter(state: context.state)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row: Logo + App name (+ location) | "now"
            HStack {
                HStack(spacing: 8) {
                    Image(context.attributes.brandImageName)
                        .resizable()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 1) {
                        Text(context.attributes.brandName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        if let location = context.attributes.locationName {
                            Text(location)
                                .font(.system(size: 12))
                                .foregroundColor(grayTextColor)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
                Spacer()
                Text("now")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 16)

            // Main content: Energy + Duration
            HStack(alignment: .top) {
                // Large kWh on left
                Text("\(formatter.kwhFormatted) kWh")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.white)
                    .tracking(0.15)

                Spacer()

                // Right-aligned stats - auto-updating timer + session cost
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Duration:")
                            .font(.system(size: 17))
                            .foregroundColor(grayTextColor)
                        Text(formatter.sessionStartTime, style: .timer)
                            .font(.system(size: 17, weight: .medium).monospacedDigit())
                            .foregroundColor(.white)
                    }
                    if let costText = formatter.sessionCostFormatted {
                        HStack(spacing: 4) {
                            Text("Cost:")
                                .font(.system(size: 17))
                                .foregroundColor(grayTextColor)
                            Text(costText)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .padding(24)
        .activityBackgroundTint(.black)
        .activitySystemActionForegroundColor(.white)
    }
}

// MARK: - Widget Configuration
struct RoadWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ChargingStateAttributes.self) { context in
            // Lock screen/banner UI - matches Figma design.
            // .widgetURL has to be applied here too — the modifier on the
            // DynamicIsland return value below only covers Dynamic Island
            // taps, not the lock screen / banner / Notification Center.
            LockScreenLiveActivityView(context: context)
                .widgetURL(URL(string: "\(context.attributes.deepLinkScheme)://charging"))

        } dynamicIsland: { context in
            let formatter = ChargingDataFormatter(state: context.state)

            return DynamicIsland {
                // Expanded UI - matches Figma design layout
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(context.attributes.brandImageName)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                        Text(context.attributes.brandName)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("now")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let location = context.attributes.locationName {
                            Text(location)
                                .font(.system(size: 12))
                                .foregroundColor(grayTextColor)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack(alignment: .top) {
                            // Large kWh on left
                            Text("\(formatter.kwhFormatted) kWh")
                                .font(.system(size: 32, weight: .regular))
                                .foregroundColor(.white)

                            Spacer()

                            // Right-aligned stats - auto-updating timer + session cost
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text("Duration:")
                                        .font(.system(size: 13))
                                        .foregroundColor(grayTextColor)
                                    Text(formatter.sessionStartTime, style: .timer)
                                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                                        .foregroundColor(.white)
                                }
                                if let costText = formatter.sessionCostFormatted {
                                    HStack(spacing: 4) {
                                        Text("Cost:")
                                            .font(.system(size: 13))
                                            .foregroundColor(grayTextColor)
                                        Text(costText)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 4)
                }
            } compactLeading: {
                Image(context.attributes.brandImageName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            } compactTrailing: {
                Text("\(formatter.kwhFormatted) kWh")
                    .font(.system(size: 14, weight: .medium))
            } minimal: {
                Image(context.attributes.brandImageName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            }
            .widgetURL(URL(string: "\(context.attributes.deepLinkScheme)://charging"))
            .keylineTint(Color(red: 0, green: 241.0/255.0, blue: 10.0/255.0))
        }
    }
}

extension ChargingStateAttributes {
    fileprivate static var preview: ChargingStateAttributes {
        ChargingStateAttributes(
            sessionCurrency: "EUR",
            activeSessionId: "preview-session",
            brandName: "E-Flux",
            brandImageName: "eflux60",
            deepLinkScheme: "eflux",
            locationName: "Office Arendsnest"
        )
    }
}

extension ChargingStateAttributes.ContentState {
    fileprivate static var smiley: ChargingStateAttributes.ContentState {
        ChargingStateAttributes.ContentState(
            activityId: "preview-activity-1",
            kwh: 12.5,
            durationMinutes: 83, // 1h 23m
            startedAt: nil,
            sessionCost: 12.45,
            currency: "EUR"
        )
     }

     fileprivate static var starEyes: ChargingStateAttributes.ContentState {
         ChargingStateAttributes.ContentState(
             activityId: "preview-activity-2",
             kwh: 8.2,
             durationMinutes: 45,
             startedAt: nil,
             sessionCost: 7.80,
             currency: "EUR"
         )
     }
}

#Preview("Notification", as: .content, using: ChargingStateAttributes.preview) {
   RoadWidgetExtensionLiveActivity()
} contentStates: {
    ChargingStateAttributes.ContentState.smiley
    ChargingStateAttributes.ContentState.starEyes
}

