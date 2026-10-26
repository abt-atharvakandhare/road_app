//
//  CarPlayFiltersTabManager.swift
//  Runner
//
//  Manages the CarPlay Filters tab: template creation, updates, and
//  drill-down sub-screens for singleChoice / multipleChoice filter groups.
//

import CarPlay
import os.log

class CarPlayFiltersTabManager {

    // MARK: - Properties

    private(set) var template: CPListTemplate?
    private weak var carPlayProcessor: CarPlayProcessor?
    private weak var interfaceController: CPInterfaceController?

    /// Track the currently pushed group sub-screen (if any)
    private var pushedGroupKey: String?
    private var pushedGroupTemplate: CPListTemplate?

    // MARK: - Init

    init(carPlayProcessor: CarPlayProcessor?, interfaceController: CPInterfaceController?) {
        self.carPlayProcessor = carPlayProcessor
        self.interfaceController = interfaceController
    }

    // MARK: - Template Lifecycle

    func createTemplate() -> CPListTemplate {
        let sections = buildSections(from: EvseManager.shared.filterItems)
        let title = EvseManager.shared.uiString("tabFilters", fallback: "Filters")

        let newTemplate = CPListTemplate(title: title, sections: sections)
        if let icon = UIImage(systemName: "line.3.horizontal.decrease.circle") {
            newTemplate.tabImage = icon
        }
        newTemplate.tabTitle = title
        template = newTemplate
        return newTemplate
    }

    func update() {
        let sections = buildSections(from: EvseManager.shared.filterItems)
        template?.updateSections(sections)

        // Also refresh any pushed group sub-screen
        if let groupKey = pushedGroupKey,
           let group = EvseManager.shared.filterGroup(forKey: groupKey) {
            let childItems = buildGroupChildItems(group: group)
            let childSection = CPListSection(items: childItems)
            pushedGroupTemplate?.updateSections([childSection])
        }
    }

    /// Re-apply localized strings to the already-built template.
    /// Called when Phrase OTA strings arrive after the template was created.
    func applyUiStrings() {
        template?.tabTitle = EvseManager.shared.uiString("tabFilters", fallback: "Filters")
        // Sections contain many localized strings (headers, on/off labels,
        // highway mode text) — rebuild them to pick up fresh values.
        update()
    }

    func reset() {
        template = nil
        pushedGroupKey = nil
        pushedGroupTemplate = nil
    }

    // MARK: - Main Filter List

    private func buildSections(from filterItems: [CarScreenFilterItem]) -> [CPListSection] {
        // Section 1: Highway mode (separate from filters)
        let highwayItem = buildHighwayItem()
        let highwaySection = CPListSection(items: [highwayItem])

        // Section 2: Filters
        let filterItems = buildFilterItems(from: filterItems)
        let filtersHeader = EvseManager.shared.uiString("filters", fallback: "Filters")
        let filtersSection = CPListSection(items: filterItems, header: filtersHeader, sectionIndexTitle: nil)

        return [highwaySection, filtersSection]
    }

    private func buildHighwayItem() -> CPListItem {
        let highwayMode = EvseManager.shared.highwayMode
        let highwayLabel: String
        switch highwayMode {
        case "off":
            highwayLabel = EvseManager.shared.uiString("highwayOff", fallback: "Highway mode: Off")
        case "on":
            highwayLabel = EvseManager.shared.uiString("highwayOn", fallback: "Highway mode: On")
        default:
            highwayLabel = EvseManager.shared.uiString("highwayAuto", fallback: "Highway mode: Auto")
        }
        let highwayItem = CPListItem(text: EvseManager.shared.uiString("highway", fallback: "Highway mode"), detailText: highwayLabel)
        highwayItem.handler = { [weak self] _, completion in
            os_log("CarPlayFiltersTabManager: Highway mode tapped — cycling from %@", log: .default, type: .info, highwayMode)
            self?.carPlayProcessor?.toggleHighwayMode()
            completion()
        }
        return highwayItem
    }

    private func buildFilterItems(from filterItems: [CarScreenFilterItem]) -> [CPListItem] {
        var items = [CPListItem]()

        let onLabel = EvseManager.shared.uiString("filterOn", fallback: "On")
        let offLabel = EvseManager.shared.uiString("filterOff", fallback: "Off")

        for filterItem in filterItems {
            switch filterItem {
            case .toggle(let filter):
                let item = CPListItem(text: filter.label, detailText: filter.enabled ? onLabel : offLabel)
                item.handler = { [weak self] _, completion in
                    let newEnabled = !filter.enabled
                    os_log("CarPlayFiltersTabManager: Filter toggled — %@ -> %@",
                           log: .default, type: .info, filter.key, newEnabled ? "on" : "off")
                    self?.carPlayProcessor?.toggleCarScreenFilter(key: filter.key, enabled: newEnabled)
                    completion()
                }
                items.append(item)

            case .group(let group):
                let item = CPListItem(text: group.label, detailText: group.selectedLabel)
                item.accessoryType = .disclosureIndicator
                item.handler = { [weak self] _, completion in
                    os_log("CarPlayFiltersTabManager: Group tapped — %@", log: .default, type: .info, group.key)
                    self?.pushGroupScreen(group: group)
                    completion()
                }
                items.append(item)
            }
        }

        return items
    }

    // MARK: - Group Sub-Screen

    private func pushGroupScreen(group: CarScreenFilterGroup) {
        let childItems = buildGroupChildItems(group: group)
        let section = CPListSection(items: childItems)
        let subTemplate = CPListTemplate(title: group.label, sections: [section])

        pushedGroupKey = group.key
        pushedGroupTemplate = subTemplate

        interfaceController?.pushTemplate(subTemplate, animated: true, completion: nil)
    }

    private func buildGroupChildItems(group: CarScreenFilterGroup) -> [CPListItem] {
        var items = [CPListItem]()

        // For singleChoice groups, add an "All" option that clears all selections
        if group.type == "singleChoice" {
            let noneSelected = group.children.allSatisfy { !$0.selected }
            let allItem = CPListItem(text: EvseManager.shared.uiString("all", fallback: "All"),
                                     detailText: noneSelected ? "✓" : nil)
            allItem.handler = { [weak self] _, completion in
                os_log("CarPlayFiltersTabManager: 'All' tapped for group %@", log: .default, type: .info, group.key)
                // Turn off all children in this group
                for child in group.children where child.selected {
                    self?.carPlayProcessor?.toggleCarScreenFilter(key: child.key, enabled: false)
                }
                completion()
            }
            items.append(allItem)
        }

        for child in group.children {
            let item = CPListItem(text: child.label, detailText: child.selected ? "✓" : nil)
            item.handler = { [weak self] _, completion in
                let newSelected = !child.selected
                os_log("CarPlayFiltersTabManager: Group child toggled — %@ -> %@",
                       log: .default, type: .info, child.key, newSelected ? "on" : "off")
                self?.carPlayProcessor?.toggleCarScreenFilter(key: child.key, enabled: newSelected)
                completion()
            }
            items.append(item)
        }

        return items
    }
}
