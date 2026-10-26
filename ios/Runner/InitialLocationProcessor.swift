//
//  InitialLocationProcessor.swift
//  Runner
//
//  One-shot CoreLocation reader used to seed LocationBloc on iOS.
//  geolocator's getCurrentPosition can stall in some scenarios (notably the
//  simulator with a single simulated location), so we call CLLocationManager
//  directly — the same API the Google Maps SDK uses to render the blue dot.
//  The continuous position stream stays on geolocator.
//

import Foundation
import CoreLocation
import os.log

class InitialLocationProcessor: NSObject, CLLocationManagerDelegate {

    private struct Constants {
        static let channelName = "io.e-flux.mobile/initial_location"
        static let getCurrentLocationMethod = "getCurrentLocation"
        static let timeoutSeconds: TimeInterval = 5.0

        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let accuracyKey = "accuracy"
    }

    private let manager: CLLocationManager
    private var pendingResult: FlutterResult?
    private var timeoutTask: DispatchWorkItem?

    init(flutterVc: FlutterViewController) {
        self.manager = CLLocationManager()
        super.init()
        self.manager.delegate = self
        // Coarse accuracy returns a cached / network-based fix near-instantly,
        // which is all we need to seed map centering. The continuous geolocator
        // stream upgrades this to a precise fix shortly after.
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer

        let channel = FlutterMethodChannel(
            name: Constants.channelName,
            binaryMessenger: flutterVc.binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case Constants.getCurrentLocationMethod:
                self?.getCurrentLocation(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func getCurrentLocation(result: @escaping FlutterResult) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            os_log("InitialLocationProcessor: not authorized (%d)", log: .default, type: .info, status.rawValue)
            result(nil)
            return
        }

        if let cached = manager.location {
            os_log("InitialLocationProcessor: returning cached CLLocation", log: .default, type: .info)
            result(toDict(cached))
            return
        }

        if pendingResult != nil {
            os_log("InitialLocationProcessor: request already in flight — returning nil to second caller", log: .default, type: .info)
            result(nil)
            return
        }

        pendingResult = result

        let task = DispatchWorkItem { [weak self] in
            guard let self = self, let pending = self.pendingResult else { return }
            os_log("InitialLocationProcessor: requestLocation timed out", log: .default, type: .info)
            self.pendingResult = nil
            self.timeoutTask = nil
            pending(nil)
        }
        timeoutTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.timeoutSeconds, execute: task)

        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If pendingResult is nil, the timeout already fired and resolved the
        // Flutter call with nil — drop this late delivery rather than callback twice.
        guard let location = locations.last, let pending = pendingResult else { return }
        timeoutTask?.cancel()
        timeoutTask = nil
        pendingResult = nil
        pending(toDict(location))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("InitialLocationProcessor: didFailWithError %@", log: .default, type: .error, String(describing: error))
        guard let pending = pendingResult else { return }
        timeoutTask?.cancel()
        timeoutTask = nil
        pendingResult = nil
        pending(nil)
    }

    private func toDict(_ location: CLLocation) -> [String: Double] {
        return [
            Constants.latitudeKey: location.coordinate.latitude,
            Constants.longitudeKey: location.coordinate.longitude,
            Constants.accuracyKey: location.horizontalAccuracy,
        ]
    }
}
