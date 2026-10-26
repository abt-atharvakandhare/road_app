import Flutter
import GoogleMaps
import UIKit

class StreetViewFactory: NSObject, FlutterPlatformViewFactory {
    static let viewType = "road_mobile/street_view"

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return StreetViewPlatformView(frame: frame, arguments: args as? [String: Any])
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

/// Embeds a native Google Street View panorama, positioned near the coordinate
/// passed in the creation params. All user interaction (pan, zoom, navigation)
/// is handled by the native view; there is no channel back to Dart.
class StreetViewPlatformView: NSObject, FlutterPlatformView {
    private let panoramaView: GMSPanoramaView

    init(frame: CGRect, arguments args: [String: Any]?) {
        let latitude = args?["latitude"] as? Double ?? 0
        let longitude = args?["longitude"] as? Double ?? 0
        let radius = args?["radius"] as? Double ?? 50

        panoramaView = GMSPanoramaView(frame: frame)
        super.init()
        panoramaView.moveNearCoordinate(
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            radius: UInt(radius)
        )
    }

    func view() -> UIView {
        return panoramaView
    }
}
