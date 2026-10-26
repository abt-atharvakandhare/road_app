//
//  CarPlayDetailPresenter.swift
//  Runner
//
//  Handles showing EVSE detail templates and launching Apple Maps navigation.
//

import CarPlay
import MapKit
import os.log

class CarPlayDetailPresenter {
    private weak var interfaceController: CPInterfaceController?
    private weak var carPlayProcessor: CarPlayProcessor?

    init(interfaceController: CPInterfaceController?, carPlayProcessor: CarPlayProcessor?) {
        self.interfaceController = interfaceController
        self.carPlayProcessor = carPlayProcessor
    }

    // MARK: - Detail Template

    func showDetail(for evse: Evse) {
        // Look up latest data to ensure favourite state is current
        let evse = EvseManager.shared.nearbyEvses.first { $0.id == evse.id }
            ?? EvseManager.shared.favouriteEvses.first { $0.id == evse.id }
            ?? evse

        os_log("CarPlayDetailPresenter: Showing detail for %@", log: .default, type: .info, evse.title)

        var items = [CPInformationItem]()

        if !evse.addressText.isEmpty {
            items.append(CPInformationItem(title: evse.addressText, detail: nil))
        }

        for row in evse.connectorRows {
            let title = row["title"] ?? ""
            let detail = row["detail"] ?? ""
            items.append(CPInformationItem(title: title, detail: detail))
        }

        if !evse.priceText.isEmpty {
            items.append(CPInformationItem(title: evse.priceText, detail: nil))
        }

        // Create template first, then build actions that can reference it
        let template = CPInformationTemplate(title: evse.title, layout: .leading, items: items, actions: [])
        template.actions = buildDetailActions(for: evse, on: template)
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }

    // MARK: - Navigation

    func startNavigation(to evse: Evse) {
        os_log("CarPlayDetailPresenter: Starting navigation to %@", log: .default, type: .info, evse.title)

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: evse.coordinate))
        destination.name = evse.title

        if #available(iOS 13.0, *) {
            destination.pointOfInterestCategory = .evCharger
        }

        if let carPlayScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? CPTemplateApplicationScene })
            .first {
            destination.openInMaps(
                launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                    MKLaunchOptionsShowsTrafficKey: true
                ],
                from: carPlayScene,
                completionHandler: { success in
                    os_log("CarPlayDetailPresenter: Apple Maps launch - Success: %@",
                           log: .default, type: .info, success ? "true" : "false")
                }
            )
        } else {
            destination.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                MKLaunchOptionsShowsTrafficKey: true
            ])
        }
    }

    // MARK: - Private

    private func buildDetailActions(for evse: Evse, on template: CPInformationTemplate) -> [CPTextButton] {
        var actions = [CPTextButton]()

        let navigateLabel = EvseManager.shared.uiString("navigate", fallback: "Navigate")
        actions.append(CPTextButton(title: navigateLabel, textStyle: .confirm) { [weak self] _ in
            self?.startNavigation(to: evse)
        })

        if !evse.favouriteButtonLabel.isEmpty {
            let favLabel = evse.isFavourite
                ? EvseManager.shared.uiString("saved", fallback: "❤️ Saved")
                : EvseManager.shared.uiString("save", fallback: "🤍 Save")
            actions.append(CPTextButton(title: favLabel, textStyle: .normal) { [weak self, weak template] _ in
                os_log("CarPlayDetailPresenter: Favourite toggled for %@", log: .default, type: .info, evse.id)
                self?.carPlayProcessor?.toggleFavourite(locationId: evse.id)
                // Update actions in place with toggled state
                if let template = template {
                    template.actions = self?.buildDetailActions(for: evse.withToggledFavourite(), on: template) ?? []
                }
            })
        }

        return actions
    }
}
