//
//  PrusaLinkApp.swift
//  PrusaLink
//
//  Created by George Waters on 10/18/23.
//

import SwiftUI

@main
struct PrusaLinkApp: App {
    var settingsDataStore: SettingsDataStore
    
    @StateObject var settings: Settings
    @State var navigationViews: [NavigationView] = []
    
    init() {
        let settingsDataStore = SettingsDataStore()
        self.settingsDataStore = settingsDataStore
        let settings = settingsDataStore.loadSettings()
        _settings = StateObject(wrappedValue: settings)
        if let selectedPrinterID = settings.selectedPrinterID,
           settings.printers.contains(where: { $0.id == selectedPrinterID }) {
            _navigationViews = State(wrappedValue: [.webView(selectedPrinterID)])
        }
    }
    
    var body: some Scene {
        WindowGroup {
            PrintersView()
                .environmentObject(settings)
                .navigationViews($navigationViews)
        }
    }
}
