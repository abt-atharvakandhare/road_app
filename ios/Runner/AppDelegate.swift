// xcode: set sdk=iOS

import UIKit
import Flutter
import GoogleMaps
import os.log

@main
@objc class AppDelegate: FlutterAppDelegate {

    // MARK: - Constants
    private struct Constants {
        static let configChannelName = "io.e-flux.mobile/config"
        static let setGoogleServicesKeyMethod = "setGoogleServicesKey"
        static let invalidArgumentError = "INVALID_ARGUMENT"
        static let invalidArgumentMessage = "Google Services key must be a string"
    }

    lazy var flutterEngine = FlutterEngine(name: "basic")
    var liveActivityProcessor: LiveActivityProcessor?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Pre-warm the Flutter engine
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: self.flutterEngine)

        // Setup config channel - must be done here to work in all scenarios including background launch
        setupConfigChannel()

        // Live Activity channel — registered on the engine here (not in SceneDelegate) so the
        // handler exists the moment Dart can call it, including cold/background launches where no
        // UI scene has connected yet. This is what lets us terminate a stale Live Activity that
        // outlived a killed app session as soon as the charging status is re-checked on launch.
        liveActivityProcessor = LiveActivityProcessor(binaryMessenger: flutterEngine.binaryMessenger)

        // Street View panorama platform view — registered on the engine here for the
        // same cold/background-launch reasons as the channels above.
        if let streetViewRegistrar = flutterEngine.registrar(forPlugin: "StreetViewPlatformView") {
            streetViewRegistrar.register(StreetViewFactory(), withId: StreetViewFactory.viewType)
        }

        // Only set up window for iOS < 13
        guard #available(iOS 13.0, *) else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Required for iOS 13+
    @available(iOS 13.0, *)
    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Config Channel Setup
    private func setupConfigChannel() {
        let configChannel = FlutterMethodChannel(
            name: Constants.configChannelName,
            binaryMessenger: flutterEngine.binaryMessenger
        )

        configChannel.setMethodCallHandler { [weak self] (call, result) in
            guard self != nil else {
                result(FlutterError(code: "UNAVAILABLE", message: "AppDelegate unavailable", details: nil))
                return
            }

            if call.method == Constants.setGoogleServicesKeyMethod {
                if let key = call.arguments as? String {
                    os_log("AppDelegate: Setting Google Maps API key", log: .default, type: .info)
                    GMSServices.provideAPIKey(key)
                    result(nil)
                } else {
                    result(FlutterError(
                        code: Constants.invalidArgumentError,
                        message: Constants.invalidArgumentMessage,
                        details: nil
                    ))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
