//
//  CarPlayMapTabManager.swift
//  Runner
//
//  Manages the CarPlay map (Point of Interest) tab: template creation,
//  POI building, selection tracking, update deferral, and map-follow logic.
//

import CarPlay
import MapKit
import CoreLocation
import os.log

class CarPlayMapTabManager: NSObject, CPPointOfInterestTemplateDelegate {

    // MARK: - Public Properties

    /// The current map template (set after `createTemplate()`)
    private(set) var template: CPPointOfInterestTemplate?

    /// Whether an update was deferred while the detail view was open
    private(set) var hasPendingUpdate: Bool = false

    /// Detail presenter used for POI button actions
    var detailPresenter: CarPlayDetailPresenter?

    // MARK: - Private Properties

    private weak var carPlayProcessor: CarPlayProcessor?
    private var currentLocationProvider: () -> CLLocation?

    // Selection tracking
    private var selectedStationId: String?
    private var selectionTimestamp: Date?

    // First-update flag
    private var isFirstUpdate = true

    // MARK: - Constants

    static let locationIdKey = "locationId"
    private static let minimumDetailViewTime: TimeInterval = 15.0

    // MARK: - Init

    init(carPlayProcessor: CarPlayProcessor?,
         currentLocationProvider: @escaping () -> CLLocation?) {
        self.carPlayProcessor = carPlayProcessor
        self.currentLocationProvider = currentLocationProvider
        super.init()
    }

    // MARK: - Template Lifecycle

    func createTemplate() -> CPPointOfInterestTemplate {
        let nearbyEvses = EvseManager.shared.nearbyEvses
        os_log("CarPlayMapTabManager: Creating template with %d EVSEs", log: .default, type: .info, nearbyEvses.count)

        let pois = buildPOIs(evses: nearbyEvses)

        let newTemplate = CPPointOfInterestTemplate(
            title: templateTitle,
            pointsOfInterest: pois,
            selectedIndex: NSNotFound
        )
        newTemplate.pointOfInterestDelegate = self

        if let icon = UIImage(systemName: "map") {
            newTemplate.tabImage = icon
        }
        newTemplate.tabTitle = EvseManager.shared.uiString("tabMap", fallback: "Map")

        template = newTemplate
        return newTemplate
    }

    func reset() {
        template = nil
        isFirstUpdate = true
        clearSelection()
        hasPendingUpdate = false
    }

    /// Re-apply localized strings to the already-built template.
    /// Called when Phrase OTA strings arrive after the template was created.
    func applyUiStrings() {
        template?.tabTitle = EvseManager.shared.uiString("tabMap", fallback: "Map")
        template?.title = templateTitle
    }

    // MARK: - Updates

    func update() {
        let nearbyEvses = EvseManager.shared.nearbyEvses

        // On first update with data, just mark the flag and fall through to
        // applyUpdate(). Template recreation via updateTemplates causes the
        // POI list to render with the first item partially scrolled off-screen.
        if isFirstUpdate && !nearbyEvses.isEmpty {
            os_log("CarPlayMapTabManager: First data update — %d POIs", log: .default, type: .info, nearbyEvses.count)
            isFirstUpdate = false
        }

        // Defer update while detail view is open
        if let selectedId = selectedStationId, let timestamp = selectionTimestamp {
            if nearbyEvses.first(where: { $0.id == selectedId }) == nil {
                os_log("CarPlayMapTabManager: Selected station no longer in list — applying update", log: .default, type: .info)
                clearSelection()
            } else {
                let elapsed = Date().timeIntervalSince(timestamp)
                if elapsed < Self.minimumDetailViewTime {
                    os_log("CarPlayMapTabManager: Deferring update — detail open %.1fs (min %.1fs)",
                           log: .default, type: .info, elapsed, Self.minimumDetailViewTime)
                    hasPendingUpdate = true
                    return
                }
            }
        }

        applyUpdate()
    }

    // MARK: - Private Helpers

    private var templateTitle: String {
        EvseManager.shared.isHighwayModeActive
            ? EvseManager.shared.uiString("fastChargersAhead", fallback: "Fast Chargers Ahead")
            : EvseManager.shared.uiString("nearbyStations", fallback: "Nearby Stations")
    }

    private func applyUpdate() {
        let nearbyEvses = EvseManager.shared.nearbyEvses
        let pois = buildPOIs(evses: nearbyEvses)

        template?.title = templateTitle

        // Preserve selection; default to first item so the list scrolls to the top
        var resolvedIndex = pois.isEmpty ? NSNotFound : 0
        if let selectedId = selectedStationId {
            for (i, poi) in pois.enumerated() {
                if let info = poi.userInfo as? [String: Any],
                   let locId = info[Self.locationIdKey] as? String,
                   locId == selectedId {
                    resolvedIndex = i
                    break
                }
            }
        }
        template?.setPointsOfInterest(pois, selectedIndex: resolvedIndex)
        hasPendingUpdate = false
        os_log("CarPlayMapTabManager: Updated with %d POIs, title: %@",
               log: .default, type: .info, pois.count, templateTitle)
    }

    private func clearSelection() {
        selectedStationId = nil
        selectionTimestamp = nil
    }

    // MARK: - POI Building

    private func buildPOIs(evses: [Evse]) -> [CPPointOfInterest] {
        os_log("CarPlayMapTabManager: Building POIs for %d locations", log: .default, type: .info, evses.count)
        let markerGen = CarPlayMarkerGenerator.shared
        let currentLoc = currentLocationProvider()

        return evses.enumerated().map { (index, evse) in
            let letter = CarPlayMarkerGenerator.letter(for: index)
            let listTitle = letter != nil ? "\(letter!). \(evse.title)" : evse.title

            let distanceText = evse.formattedDistance(from: currentLoc)
            let summaryText: String
            if let distance = distanceText, !distance.isEmpty, !evse.summary.isEmpty {
                summaryText = "\(distance) - \(evse.summary)"
            } else {
                summaryText = distanceText ?? evse.summary
            }

            let pinImage: UIImage?
            if let letter = letter {
                pinImage = markerGen.markerImage(for: evse.status, letter: letter)
            } else {
                switch evse.status {
                case .available: pinImage = UIImage(named: "CarPlayMarkerAvailable")
                case .charging:  pinImage = UIImage(named: "CarPlayMarkerCharging")
                case .unknown:   pinImage = UIImage(named: "CarPlayMarkerUnknown")
                }
            }

            let selectedPinImage: UIImage?
            if let letter = letter {
                selectedPinImage = markerGen.selectedMarkerImage(letter: letter)
            } else {
                selectedPinImage = UIImage(named: "CarPlayMarkerSelected")?.withRenderingMode(.alwaysOriginal)
            }

            let item: CPPointOfInterest
            if #available(iOS 16.0, *) {
                item = CPPointOfInterest(
                    location: MKMapItem(placemark: MKPlacemark(coordinate: evse.coordinate)),
                    title: listTitle,
                    subtitle: evse.subtitle,
                    summary: summaryText,
                    detailTitle: evse.title,
                    detailSubtitle: evse.detailSubtitle,
                    detailSummary: evse.detailSummary,
                    pinImage: pinImage,
                    selectedPinImage: selectedPinImage
                )
            } else {
                item = CPPointOfInterest(
                    location: MKMapItem(placemark: MKPlacemark(coordinate: evse.coordinate)),
                    title: listTitle,
                    subtitle: evse.subtitle,
                    summary: summaryText,
                    detailTitle: evse.title,
                    detailSubtitle: evse.detailSubtitle,
                    detailSummary: evse.detailSummary,
                    pinImage: pinImage
                )
            }

            item.userInfo = [Self.locationIdKey: evse.id]

            item.primaryButton = CPTextButton(
                title: EvseManager.shared.uiString("navigate", fallback: "Navigate"),
                textStyle: .confirm
            ) { [weak self] _ in
                self?.detailPresenter?.startNavigation(to: evse)
            }

            item.secondaryButton = CPTextButton(
                title: EvseManager.shared.uiString("showDetails", fallback: "Show details"),
                textStyle: .normal
            ) { [weak self] _ in
                self?.detailPresenter?.showDetail(for: evse)
            }

            return item
        }
    }

    // MARK: - CPPointOfInterestTemplateDelegate

    func pointOfInterestTemplate(_ template: CPPointOfInterestTemplate,
                                 didChangeMapRegion region: MKCoordinateRegion) {
        os_log("CarPlayMapTabManager: Map region changed — center (%f, %f)",
               log: .default, type: .info,
               region.center.latitude, region.center.longitude)
    }

    func pointOfInterestTemplate(_ template: CPPointOfInterestTemplate,
                                 didSelectPointOfInterest poi: CPPointOfInterest) {
        guard let info = poi.userInfo as? [String: Any],
              let locationId = info[Self.locationIdKey] as? String else {
            os_log("CarPlayMapTabManager: POI selected but userInfo missing", log: .default, type: .error)
            return
        }
        selectedStationId = locationId
        selectionTimestamp = Date()
        os_log("CarPlayMapTabManager: POI selected — %@", log: .default, type: .info, locationId)
    }

    func pointOfInterestTemplate(_ template: CPPointOfInterestTemplate,
                                 didDeselectPointOfInterest poi: CPPointOfInterest) {
        os_log("CarPlayMapTabManager: POI deselected", log: .default, type: .info)
        clearSelection()

        if hasPendingUpdate {
            os_log("CarPlayMapTabManager: Applying pending update after deselect", log: .default, type: .info)
            applyUpdate()
        }
    }
}
