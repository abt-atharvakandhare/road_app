//
//  CarPlayFavouritesTabManager.swift
//  Runner
//
//  Manages the CarPlay Favourites tab: template creation and updates.
//

import CarPlay
import os.log

class CarPlayFavouritesTabManager {

    // MARK: - Properties

    private(set) var template: CPListTemplate?

    /// Called when a favourite station is tapped — the coordinator
    /// should present the detail view via CarPlayDetailPresenter.
    var onStationSelected: ((Evse) -> Void)?

    // MARK: - Template Lifecycle

    func createTemplate() -> CPListTemplate {
        let items = buildItems(from: EvseManager.shared.favouriteEvses)
        let section = CPListSection(items: items)
        let title = EvseManager.shared.uiString("tabFavourites", fallback: "Favourites")

        let newTemplate = CPListTemplate(title: title, sections: [section])
        if let icon = UIImage(systemName: "heart") {
            newTemplate.tabImage = icon
        }
        newTemplate.tabTitle = title
        template = newTemplate
        return newTemplate
    }

    func update() {
        let items = buildItems(from: EvseManager.shared.favouriteEvses)
        let section = CPListSection(items: items)
        template?.updateSections([section])
    }

    /// Re-apply localized strings to the already-built template.
    /// Called when Phrase OTA strings arrive after the template was created.
    func applyUiStrings() {
        let title = EvseManager.shared.uiString("tabFavourites", fallback: "Favourites")
        template?.tabTitle = title
        // The empty-state message lives inside the items — rebuild them so it refreshes too.
        update()
    }

    func reset() {
        template = nil
    }

    // MARK: - Private

    private func buildItems(from favourites: [Evse]) -> [CPListItem] {
        guard !favourites.isEmpty else {
            let message = EvseManager.shared.uiString("noFavourites", fallback: "No favourites yet")
            return [CPListItem(text: message, detailText: nil)]
        }

        return favourites.map { evse -> CPListItem in
            let item = CPListItem(text: evse.title, detailText: evse.subtitle)
            item.handler = { [weak self] _, completion in
                os_log("CarPlayFavouritesTabManager: Favourite selected — %@", log: .default, type: .info, evse.title)
                self?.onStationSelected?(evse)
                completion()
            }
            return item
        }
    }
}
