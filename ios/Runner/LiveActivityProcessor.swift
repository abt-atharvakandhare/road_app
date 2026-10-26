//
//  LiveActivityProcessor.swift
//  Runner
//
//  Created by Raymond Hunter on 19/02/2025.
//

import Foundation
import ActivityKit
import os.log

class LiveActivityProcessor {

    private struct Constants {
        static let channelName = "io.e-flux.mobile/liveActivity"
        static let showMethod = "showLiveActivity"
        static let endMethod = "endLiveActivity"
        // Flutter → Dart: fired when the user taps the Live Activity. The Live
        // Activity's widgetURL routes here via SceneDelegate; Dart routes the
        // intent to the charging status screen via AppLinksCubit.
        static let tappedMethod = "onLiveActivityTapped"

        // Result keys
        static let statusKey = "status"
        static let activityIdKey = "activityId"
        static let pushTokenKey = "pushToken"

        // Status values
        static let statusStarted = "started"
        static let statusUpdated = "updated"
        static let statusEnded = "ended"
        static let statusError = "error"
        static let errorKey = "error"
    }

    let methodChannel: FlutterMethodChannel

    init(binaryMessenger: FlutterBinaryMessenger) {
        self.methodChannel = FlutterMethodChannel(
            name: Constants.channelName,
            binaryMessenger: binaryMessenger
        )

        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case Constants.showMethod:
                self?.showLiveActivity(resultHandler: result, arguments: call.arguments)
            case Constants.endMethod:
                self?.endLiveActivity(resultHandler: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Forwards a Live Activity tap to the Flutter side. Called by SceneDelegate
    /// when it receives the widgetURL (`<flavor-scheme>://charging`).
    func notifyTapped() {
        os_log("LiveActivityProcessor: forwarding tap to Flutter", log: .default, type: .info)
        methodChannel.invokeMethod(Constants.tappedMethod, arguments: nil)
    }

    func showLiveActivity(resultHandler: @escaping FlutterResult, arguments: Any?) {
        os_log("┌─────────────────────────────────────────────────────────────", log: .default, type: .debug)
        os_log("│ 📱 iOS LIVE ACTIVITY - showLiveActivity called", log: .default, type: .debug)
        os_log("├─────────────────────────────────────────────────────────────", log: .default, type: .debug)

        guard let argumentsDict = arguments as? Dictionary<String, Any> else {
            os_log("│ ❌ Invalid arguments received", log: .default, type: .error)
            resultHandler([
                Constants.statusKey: Constants.statusError,
                Constants.errorKey: "Invalid arguments"
            ])
            return
        }

        os_log("│ Raw arguments: %{public}@", log: .default, type: .debug, String(describing: argumentsDict))

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            os_log("│ ❌ Live activities not enabled by user", log: .default, type: .error)
            resultHandler([
                Constants.statusKey: Constants.statusError,
                Constants.errorKey: "Live activities not enabled"
            ])
            return
        }

        os_log("│ ✅ Live activities are enabled", log: .default, type: .debug)

        // Parse session start time from milliseconds since epoch and calculate duration
        var durationMinutes: Int = 0
        if let startTimeMs = (argumentsDict["sessionStartedAt"] as? NSNumber)?.doubleValue {
            let sessionStartedAt = Date(timeIntervalSince1970: startTimeMs / 1000.0)
            durationMinutes = Int(Date().timeIntervalSince(sessionStartedAt) / 60.0)
        }

        let energyWh = (argumentsDict["energy"] as? NSNumber)?.doubleValue ?? 0
        let kwh = energyWh / 1000.0  // Convert Wh to kWh
        let currency = (argumentsDict["currency"] as? String) ?? "EUR"
        // Optional location name (e.g. "Office Arendsnest"). Empty → nil so the widget
        // can lay itself out without a stray empty subtitle line.
        let locationNameRaw = argumentsDict["locationName"] as? String
        let locationName: String? = (locationNameRaw?.isEmpty ?? true) ? nil : locationNameRaw

        guard let activeSessionId = argumentsDict["activeSessionId"] as? String, !activeSessionId.isEmpty else {
            os_log("│ ❌ Missing activeSessionId", log: .default, type: .error)
            resultHandler([
                Constants.statusKey: Constants.statusError,
                Constants.errorKey: "Missing activeSessionId"
            ])
            return
        }

        // Branding is required — fail rather than silently rendering the wrong brand on a
        // white-label. Flutter always provides these via _brandingArgs(); anything else
        // indicates a bug in the caller.
        guard
            let brandName = argumentsDict["brandName"] as? String, !brandName.isEmpty,
            let brandImageName = argumentsDict["brandImageName"] as? String, !brandImageName.isEmpty,
            let deepLinkScheme = argumentsDict["deepLinkScheme"] as? String, !deepLinkScheme.isEmpty
        else {
            os_log("│ ❌ Missing branding (brandName/brandImageName/deepLinkScheme)", log: .default, type: .error)
            resultHandler([
                Constants.statusKey: Constants.statusError,
                Constants.errorKey: "Missing branding"
            ])
            return
        }

        let currentActivities: [Activity<ChargingStateAttributes>] = Activity.activities
        let existingActivity = currentActivities.first

        os_log("│ Parsed values:", log: .default, type: .debug)
        os_log("│   - Active Session ID: %{public}@", log: .default, type: .debug, activeSessionId)
        os_log("│   - Energy: %.1f Wh (%.2f kWh)", log: .default, type: .debug, energyWh, kwh)
        os_log("│   - Duration: %d minutes", log: .default, type: .debug, durationMinutes)
        os_log("│   - Currency: %{public}@", log: .default, type: .debug, currency)
        os_log("│ Current activities count: %d", log: .default, type: .debug, currentActivities.count)

        // If there's an existing activity for the same session, update it.
        if let existing = existingActivity, existing.attributes.activeSessionId == activeSessionId {
            let contentState = ChargingStateAttributes.ContentState(
                activityId: existing.id,
                kwh: kwh,
                durationMinutes: durationMinutes,
                startedAt: nil,
                sessionCost: nil,
                currency: currency
            )
            os_log("│ 🔄 Updating existing activity for same session: %{public}@", log: .default, type: .debug, existing.id)
            Task {
                await existing.update(
                    ActivityContent<ChargingStateAttributes.ContentState>(
                        state: contentState,
                        staleDate: Date.now.addingTimeInterval(60)
                    )
                )
                os_log("│ ✅ Activity updated successfully", log: .default, type: .debug)
                os_log("└─────────────────────────────────────────────────────────────", log: .default, type: .debug)
                resultHandler([
                    Constants.statusKey: Constants.statusUpdated,
                    Constants.activityIdKey: existing.id
                ])
            }
            return
        }

        // Otherwise we need to start a new activity, ending any stale one first.
        Task {
            if let stale = existingActivity {
                os_log("│ 🧹 Ending stale activity (different session): %{public}@ (was %{public}@)",
                       log: .default, type: .debug, stale.id, stale.attributes.activeSessionId)
                await stale.end(stale.content, dismissalPolicy: .immediate)
            }

            os_log("│ 🆕 Starting new activity for session: %{public}@", log: .default, type: .debug, activeSessionId)
            let attributes = ChargingStateAttributes(
                sessionCurrency: currency,
                activeSessionId: activeSessionId,
                brandName: brandName,
                brandImageName: brandImageName,
                deepLinkScheme: deepLinkScheme,
                locationName: locationName
            )

            do {
                // Use a placeholder activityId; we overwrite with the real one once it's assigned.
                let initialState = ChargingStateAttributes.ContentState(
                    activityId: "",
                    kwh: kwh,
                    durationMinutes: durationMinutes,
                    startedAt: nil,
                    sessionCost: nil,
                    currency: currency
                )
                let activity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: initialState, staleDate: nil),
                    pushType: .token
                )

                os_log("│ ✅ Activity started with id: %{public}@", log: .default, type: .debug, activity.id)
                os_log("│ ⏳ Waiting for push token (5s timeout)...", log: .default, type: .debug)

                // Wait for the first push token update, but give up after 5 seconds so the
                // caller's BLoC isn't blocked indefinitely (e.g. on dev builds without push
                // entitlement or when the device is offline). If we time out we still return
                // `started` so the activity is visible — just without a token for BE registration.
                let tokenTask = Task<String?, Never> {
                    for await tokenData in activity.pushTokenUpdates {
                        return tokenData.map { String(format: "%02x", $0) }.joined()
                    }
                    return nil
                }
                let timeoutTask = Task<String?, Never> {
                    try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                    return nil
                }
                let tokenString: String? = await withTaskGroup(of: String?.self) { group in
                    group.addTask { await tokenTask.value }
                    group.addTask { await timeoutTask.value }
                    let first = await group.next() ?? nil
                    group.cancelAll()
                    return first
                }

                var response: [String: String] = [
                    Constants.statusKey: Constants.statusStarted,
                    Constants.activityIdKey: activity.id,
                ]
                if let tokenString {
                    os_log("│ 🔑 Push token received: %{public}@", log: .default, type: .debug, tokenString)
                    response[Constants.pushTokenKey] = tokenString
                } else {
                    os_log("│ ⏱ Push token timed out — returning started without token", log: .default, type: .debug)
                }
                os_log("└─────────────────────────────────────────────────────────────", log: .default, type: .debug)
                resultHandler(response)
            } catch {
                os_log("│ ❌ Failed to start activity: %{public}@", log: .default, type: .error, error.localizedDescription)
                os_log("└─────────────────────────────────────────────────────────────", log: .default, type: .debug)
                resultHandler([
                    Constants.statusKey: Constants.statusError,
                    Constants.errorKey: error.localizedDescription
                ])
            }
        }
    }

    func endLiveActivity(resultHandler: @escaping FlutterResult) {
        let currentActivities: [Activity<ChargingStateAttributes>] = Activity.activities
        guard let activity = currentActivities.first else {
            resultHandler([
                Constants.statusKey: Constants.statusError,
                Constants.errorKey: "No active live activity"
            ])
            return
        }

        Task {
            await activity.end(activity.content, dismissalPolicy: .immediate)
            os_log("LiveActivityProcessor: Ended activity", log: .default, type: .debug)
            resultHandler([
                Constants.statusKey: Constants.statusEnded
            ])
        }
    }
}
