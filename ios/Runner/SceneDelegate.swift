//
//  SceneDelegate.swift
//  Runner
//
//  Created by Mohammad Al Kalaleeb on 11/07/2025.
//
import GoogleMaps
import UIKit
import os.log

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var paymentProcessor: PaymentProcessor?
    var initialLocationProcessor: InitialLocationProcessor?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        os_log("SceneDelegate: Scene will connect to session", log: .default, type: .info)
        guard let windowScene = scene as? UIWindowScene else { return }

        // Get the pre-warmed FlutterEngine from AppDelegate
        // This engine has all plugins (including flutter_native_splash) registered
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterEngine = appDelegate.flutterEngine

        // Create FlutterViewController with the pre-warmed engine
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

        // Set splash screen to prevent black screen during Flutter initialization
        // This matches the LaunchScreen storyboard and will be replaced by flutter_native_splash
        flutterViewController.splashScreenView = createSplashScreenView()

        setupMethodChannels(controller: flutterViewController)

        // Create window and set root view controller
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()

        // Cold-launch URL path: when the user taps the Live Activity from a
        // terminated state, the widgetURL arrives here rather than via
        // scene(_:openURLContexts:).
        handleURLContexts(connectionOptions.urlContexts)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleURLContexts(URLContexts)
    }

    /// Routes incoming URLs into the right Flutter-side handler. Today the
    /// only URL we receive is the Live Activity widgetURL
    /// (`<flavor-scheme>://charging`) — anything else is logged and ignored
    /// so we'd notice a misconfiguration in TestFlight rather than silently.
    private func handleURLContexts(_ contexts: Set<UIOpenURLContext>) {
        for context in contexts {
            let url = context.url
            os_log("SceneDelegate: received URL %{public}@", log: .default, type: .info, url.absoluteString)
            if url.host?.lowercased() == "charging" {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.liveActivityProcessor?.notifyTapped()
            } else {
                os_log("SceneDelegate: unhandled URL host %{public}@", log: .default, type: .info, url.host ?? "<nil>")
            }
        }
    }

    private func createSplashScreenView() -> UIView? {
        // Get the launch screen storyboard name from Info.plist (flavor-specific)
        guard let launchScreenName = Bundle.main.object(forInfoDictionaryKey: "UILaunchStoryboardName") as? String else {
            os_log("SceneDelegate: Could not read UILaunchStoryboardName from Info.plist", log: .default, type: .error)
            return nil
        }

        // Load the flavor-specific launch screen storyboard
        let launchScreenStoryboard = UIStoryboard(name: launchScreenName, bundle: nil)
        guard let splashViewController = launchScreenStoryboard.instantiateInitialViewController() else {
            os_log("SceneDelegate: Failed to load launch screen storyboard: %@", log: .default, type: .error, launchScreenName)
            return nil
        }

        return splashViewController.view
    }
    
    private func setupMethodChannels(controller: FlutterViewController) {
        self.paymentProcessor = PaymentProcessor(flutterVc: controller)
        self.initialLocationProcessor = InitialLocationProcessor(flutterVc: controller)
    }
}
