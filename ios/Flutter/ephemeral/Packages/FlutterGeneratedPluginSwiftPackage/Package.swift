// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "app_links", path: "../.packages/app_links-7.2.1"),
        .package(name: "app_settings", path: "../.packages/app_settings-9.0.0"),
        .package(name: "biometric_storage", path: "../.packages/biometric_storage-6.0.0-dev.5"),
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-13.2.0"),
        .package(name: "firebase_analytics", path: "../.packages/firebase_analytics-12.6.0"),
        .package(name: "firebase_app_check", path: "../.packages/firebase_app_check-0.4.8"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.15.0"),
        .package(name: "firebase_crashlytics", path: "../.packages/firebase_crashlytics-5.4.0"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-16.7.0"),
        .package(name: "flutter_fgbg", path: "../.packages/flutter_fgbg-0.8.0"),
        .package(name: "flutter_file_dialog", path: "../.packages/flutter_file_dialog-3.3.3"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications-22.3.1"),
        .package(name: "flutter_secure_storage_darwin", path: "../.packages/flutter_secure_storage_darwin-0.4.3"),
        .package(name: "flutter_timezone", path: "../.packages/flutter_timezone-5.1.0"),
        .package(name: "geocoding_darwin", path: "../.packages/geocoding_darwin-1.0.3"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple-2.3.14"),
        .package(name: "google_places_sdk_plus_ios", path: "../.packages/google_places_sdk_plus_ios-1.2.0"),
        .package(name: "integration_test", path: "../.packages/integration_test"),
        .package(name: "intercom_flutter", path: "../.packages/intercom_flutter-9.6.28"),
        .package(name: "map_launcher", path: "../.packages/map_launcher-6.0.0"),
        .package(name: "mixpanel_flutter", path: "../.packages/mixpanel_flutter-2.14.0"),
        .package(name: "mobile_scanner", path: "../.packages/mobile_scanner-7.4.2"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-10.2.1"),
        .package(name: "passkeys_darwin", path: "../.packages/passkeys_darwin-0.4.5"),
        .package(name: "share_plus", path: "../.packages/share_plus-13.3.0"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.7"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.2"),
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview-3.26.1"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "app-links", package: "app_links"),
                .product(name: "app-settings", package: "app_settings"),
                .product(name: "biometric-storage", package: "biometric_storage"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "firebase-analytics", package: "firebase_analytics"),
                .product(name: "firebase-app-check", package: "firebase_app_check"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "flutter-fgbg", package: "flutter_fgbg"),
                .product(name: "flutter-file-dialog", package: "flutter_file_dialog"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "flutter-secure-storage-darwin", package: "flutter_secure_storage_darwin"),
                .product(name: "flutter-timezone", package: "flutter_timezone"),
                .product(name: "geocoding-darwin", package: "geocoding_darwin"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "google-places-sdk-plus-ios", package: "google_places_sdk_plus_ios"),
                .product(name: "integration-test", package: "integration_test"),
                .product(name: "intercom-flutter", package: "intercom_flutter"),
                .product(name: "map-launcher", package: "map_launcher"),
                .product(name: "mixpanel-flutter", package: "mixpanel_flutter"),
                .product(name: "mobile-scanner", package: "mobile_scanner"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "passkeys-darwin", package: "passkeys_darwin"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
