//
//  CarPlaySceneDelegate.swift
//  Runner
//
//  Created by Mohammad Al Kalaleeb on 11/07/2025.
//
//  Coordinator: owns the CarPlay interface controller, sets up Combine
//  subscriptions, handles location updates, and delegates tab-specific
//  work to dedicated managers.
//

import CarPlay
import MapKit
import Combine
import CoreLocation
import os.log
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CLLocationManagerDelegate {

    // MARK: - Core

    private var interfaceController: CPInterfaceController?
    private var tabBarTemplate: CPTabBarTemplate?
    private var cancellables = Set<AnyCancellable>()
    private var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    private var carPlayProcessor: CarPlayProcessor?

    // MARK: - Tab Managers

    private var mapTabManager: CarPlayMapTabManager?
    private var filtersTabManager: CarPlayFiltersTabManager?
    private var favouritesTabManager: CarPlayFavouritesTabManager?
    private var detailPresenter: CarPlayDetailPresenter?

    // MARK: - CPTemplateApplicationSceneDelegate

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        os_log("CarPlaySceneDelegate: CarPlay connected", log: .default, type: .info)
        self.interfaceController = interfaceController

        setupCarPlayProcessor()
        setupManagers()
        subscribeToUpdates()
        setupCarPlayInterface()
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController,
                                  from window: CPWindow) {
        os_log("CarPlaySceneDelegate: CarPlay disconnected", log: .default, type: .info)

        carPlayProcessor?.notifyCarSystemStateChanged(isActive: false)
        carPlayProcessor = nil

        mapTabManager?.reset()
        filtersTabManager?.reset()
        favouritesTabManager?.reset()

        mapTabManager = nil
        filtersTabManager = nil
        favouritesTabManager = nil
        detailPresenter = nil

        self.interfaceController = nil
        self.tabBarTemplate = nil
        cancellables.removeAll()
    }

    // MARK: - Scene Lifecycle

    func sceneDidBecomeActive(_ scene: UIScene) {
        os_log("CarPlaySceneDelegate: Scene became active", log: .default, type: .info)
        if carPlayProcessor != nil {
            carPlayProcessor?.notifyCarSystemStateChanged(isActive: true)
        } else {
            os_log("CarPlaySceneDelegate: Skipping notification — processor not yet initialized", log: .default, type: .info)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        os_log("CarPlaySceneDelegate: Scene will resign active", log: .default, type: .info)
        carPlayProcessor?.notifyCarSystemStateChanged(isActive: false)
    }

    // MARK: - Setup

    private func setupCarPlayProcessor() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("CarPlaySceneDelegate: ERROR — Could not get AppDelegate", log: .default, type: .error)
            return
        }
        let engine = appDelegate.flutterEngine
        carPlayProcessor = CarPlayProcessor(binaryMessenger: engine.binaryMessenger)
        os_log("CarPlaySceneDelegate: Processor initialized", log: .default, type: .info)
    }

    private func setupManagers() {
        // Detail presenter (shared by map + favourites)
        detailPresenter = CarPlayDetailPresenter(
            interfaceController: interfaceController,
            carPlayProcessor: carPlayProcessor
        )

        // Map tab
        let map = CarPlayMapTabManager(
            carPlayProcessor: carPlayProcessor,
            currentLocationProvider: { [weak self] in self?.currentLocation }
        )
        map.detailPresenter = detailPresenter
        mapTabManager = map

        // Filters tab
        filtersTabManager = CarPlayFiltersTabManager(carPlayProcessor: carPlayProcessor, interfaceController: interfaceController)

        // Favourites tab
        let favs = CarPlayFavouritesTabManager()
        favs.onStationSelected = { [weak self] evse in
            self?.detailPresenter?.showDetail(for: evse)
        }
        favouritesTabManager = favs
    }

    private func setupCarPlayInterface() {
        setupLocationManager()

        let mapTemplate = mapTabManager!.createTemplate()
        let filtersTemplate = filtersTabManager!.createTemplate()
        let favouritesTemplate = favouritesTabManager!.createTemplate()

        let tabBar = CPTabBarTemplate(templates: [mapTemplate, filtersTemplate, favouritesTemplate])
        self.tabBarTemplate = tabBar

        interfaceController?.setRootTemplate(tabBar, animated: false) { [weak self] success, error in
            if let error = error {
                os_log("CarPlaySceneDelegate: ERROR — Failed to set root template: %@",
                       log: .default, type: .error, error.localizedDescription)
            } else if success {
                os_log("CarPlaySceneDelegate: Root template set — requesting fresh data", log: .default, type: .info)
                self?.carPlayProcessor?.notifyCarSystemStateChanged(isActive: true)
            }
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100

        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    // MARK: - Combine Subscriptions

    private func subscribeToUpdates() {
        EvseManager.shared.$nearbyEvses
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] evses in
                os_log("CarPlaySceneDelegate: EVSE update — %d locations", log: .default, type: .info, evses.count)
                self?.mapTabManager?.update()
            }.store(in: &cancellables)

        EvseManager.shared.$isHighwayModeActive
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                os_log("CarPlaySceneDelegate: Highway mode active state changed", log: .default, type: .info)
                self?.mapTabManager?.update()
            }.store(in: &cancellables)

        EvseManager.shared.$highwayMode
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                os_log("CarPlaySceneDelegate: Highway mode changed", log: .default, type: .info)
                self?.mapTabManager?.update()
                self?.filtersTabManager?.update()
            }.store(in: &cancellables)

        EvseManager.shared.$filterItems
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] items in
                os_log("CarPlaySceneDelegate: Filter items updated — %d definitions", log: .default, type: .info, items.count)
                self?.filtersTabManager?.update()
            }.store(in: &cancellables)

        EvseManager.shared.$favouriteEvses
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] favourites in
                os_log("CarPlaySceneDelegate: Favourites updated — %d stations", log: .default, type: .info, favourites.count)
                self?.favouritesTabManager?.update()
            }.store(in: &cancellables)

        EvseManager.shared.$uiStrings
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] strings in
                os_log("CarPlaySceneDelegate: UI strings updated — %d keys", log: .default, type: .info, strings.count)
                guard let self = self else { return }
                self.mapTabManager?.applyUiStrings()
                self.filtersTabManager?.applyUiStrings()
                self.favouritesTabManager?.applyUiStrings()
                // Setting tabTitle on individual templates doesn't refresh the
                // already-mounted tab bar — CarPlay caches titles when the
                // tab bar is first laid out. Calling updateTemplates forces
                // CarPlay to re-read each template's tabTitle.
                if let tabBar = self.tabBarTemplate,
                   let map = self.mapTabManager?.template,
                   let filters = self.filtersTabManager?.template,
                   let favs = self.favouritesTabManager?.template {
                    tabBar.updateTemplates([map, filters, favs])
                }
            }.store(in: &cancellables)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("CarPlaySceneDelegate: Location error: %@", log: .default, type: .error, error.localizedDescription)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}
