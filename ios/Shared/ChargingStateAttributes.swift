// Compiled into both the Runner app target and the RoadWidgetExtension widget
// target via Xcode Target Membership. A mismatch between the two would cause
// ActivityKit to silently fail to decode push payloads at runtime, so this file
// must remain the single source of truth — don't redeclare the struct elsewhere.

import ActivityKit
import Foundation

struct ChargingStateAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties - must match backend payload exactly.
        var activityId: String
        var kwh: Double           // Energy in kWh
        var durationMinutes: Int  // Session duration in minutes
        var startedAt: String?    // ISO8601 timestamp (BE populates)
        var sessionCost: Double?  // Running session cost (BE populates)
        var currency: String?     // Currency code (BE populates — duplicates the fixed attribute)
        // BE plans to add these once available in ActiveSessionDocument. Uncomment once populated.
        // var stateOfCharge: Double?                 // 0-100
        // var estimatedTimeRemainingMinutes: Int?    // Minutes until complete

        // CodingKeys to match backend JSON field names
        enum CodingKeys: String, CodingKey {
            case activityId = "activity-id"
            case kwh
            case durationMinutes
            case startedAt
            case sessionCost
            case currency
            // case stateOfCharge
            // case estimatedTimeRemainingMinutes
        }
    }

    // Fixed non-changing properties go here! (Set once when the activity starts.)
    var sessionCurrency: String
    var activeSessionId: String
    // Branding — supplied by Flutter from the current flavor so the widget can render
    // the correct logo / app name / deep link on all white-labels.
    var brandName: String
    var brandImageName: String
    var deepLinkScheme: String
    // Optional location name for the charging session (e.g. "Office Arendsnest").
    // Fixed at start time — push updates can't change attributes.
    var locationName: String?
}
