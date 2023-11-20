//
//  Environment.swift
//  PrusaLink
//
//  Created by George Waters on 10/16/23.
//

import SwiftUI

private struct SettingsKey: EnvironmentKey {
    static let defaultValue = Settings()
}

private struct NavigationViewsKey: EnvironmentKey {
    static let defaultValue: Binding<[NavigationView]> = .constant([])
}

extension EnvironmentValues {
    var settings: Settings {
        get { self[SettingsKey.self] }
        set { self[SettingsKey.self] = newValue }
    }
    
    var navigationViews: Binding<[NavigationView]> {
        get { self[NavigationViewsKey.self] }
        set { self[NavigationViewsKey.self] = newValue }
    }
}

extension View {
    func settings(_ settings: Settings) -> some View {
        environment(\.settings, settings)
    }
    
    func navigationViews(_ navigationViews: Binding<[NavigationView]>) -> some View {
        environment(\.navigationViews, navigationViews)
    }
}
