//
//  PrintersView.swift
//  PrusaLink
//
//  Created by George Waters on 10/16/23.
//

import SwiftUI
import UniformTypeIdentifiers

enum NavigationView: Hashable {
    case webView(UUID)
    case settingsView(UUID)
    case infoView
}

struct PrintersView: View {
    @EnvironmentObject var settings: Settings
    
    @State var logoViewOffset: CGFloat = 0
    
    @State var printersCVProxy: PrintersCVProxy = PrintersCVProxy()
    
    @Environment(\.navigationViews) var navigationViews
    
    var body: some View {
        NavigationStack(path: navigationViews) {
            PrintersCollectionView($settings.printers) { $printer in
                NavigationLink(view: .webView(printer.id)) {
                    PrinterItem(printer: printer)
                }
            }
            .printersCVReader(printersCVProxy)
            .navigationDestination(for: NavigationView.self) { navigationView in
                switch navigationView {
                case .webView(let printerID):
                    if let printerIndex = settings.printers.firstIndex(where: { $0.id == printerID }) {
                        let printer = $settings.printers[printerIndex]
                        PrusaWebView(printer: printer.wrappedValue, logoViewOffset: $logoViewOffset)
                    }
                case .settingsView(let printerID):
                    if let printerIndex = settings.printers.firstIndex(where: { $0.id == printerID }) {
                        let printer = $settings.printers[printerIndex]
                        SettingsView(printer: printer)
                            .navigationTitle("Printer Settings")
                            .navigationBarTitleDisplayMode(.large)
                    }
                case .infoView:
                    InfoView()
                }
            }
        }
        .onChange(of: navigationViews.wrappedValue) { newValue in
            var selectedPrinterID: UUID? = nil
            if let initialNavigationView = newValue.first,
               case let .webView(printerID) = initialNavigationView  {
                selectedPrinterID = printerID
            }
            if settings.selectedPrinterID != selectedPrinterID {
                settings.selectedPrinterID = selectedPrinterID
            }
        }
    }
}

struct PrintersView_Previews: PreviewProvider {
    static var previews: some View {
        PrintersView()
            .environmentObject(Settings(printers: [Printer(id: UUID(), name: "Prusa Mk4", imageType: .generic)]))
    }
}
