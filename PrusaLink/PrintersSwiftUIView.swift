//
//  PrintersSwiftUIView.swift
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

struct PrintersSwiftUIView: View {
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
                        PrusaWebSwiftUIView(printer: printer.wrappedValue, logoViewOffset: $logoViewOffset)
                    }
                case .settingsView(let printerID):
                    if let printerIndex = settings.printers.firstIndex(where: { $0.id == printerID }) {
                        let printer = $settings.printers[printerIndex]
                        SettingsSwiftUIView(printer: printer)
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

struct PrinterItem: View {
    var printer: Printer
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            switch printer.imageType {
            case .generic:
                GenericPrinterImage(colorData: printer.genericImageColor ?? .defaultColor)
            case .custom:
                CustomPrinterImage(imageData: printer.customImageData)
            }
            Spacer()
            Text(printer.name)
                .font(.system(.title3))
                .foregroundColor(.primary)
                .bold()
        }
        .lineLimit(3)
        .frame(
              minWidth: 0,
              maxWidth: .greatestFiniteMagnitude,
              minHeight: 0,
              maxHeight: .greatestFiniteMagnitude,
              alignment: .center
            )
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(lineWidth: 2)
                .foregroundColor(Color(uiColor: .opaqueSeparator))
        )
        .background(.background)
        .cornerRadius(10)
    }
}

struct NavLogoView: View {
    var offset: CGFloat
    var title: String
    
    let height: CGFloat = 44
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.headline)
                    .frame(height: height)
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.top, .bottom], 8)
                    .frame(height: height)
            }
            .offset(y: offset)
        }
        .frame(height: height, alignment: .top)
        .clipped()
    }
}

private struct SettingsKey: EnvironmentKey {
    static let defaultValue = Settings()
}

extension EnvironmentValues {
    var settings: Settings {
        get { self[SettingsKey.self] }
        set { self[SettingsKey.self] = newValue }
    }
}

extension View {
    func settings(_ settings: Settings) -> some View {
        environment(\.settings, settings)
    }
}

private struct NavigationViewsKey: EnvironmentKey {
    static let defaultValue: Binding<[NavigationView]> = .constant([])
}

extension EnvironmentValues {
    var navigationViews: Binding<[NavigationView]> {
        get { self[NavigationViewsKey.self] }
        set { self[NavigationViewsKey.self] = newValue }
    }
}

extension View {
    func navigationViews(_ navigationViews: Binding<[NavigationView]>) -> some View {
        environment(\.navigationViews, navigationViews)
    }
}

struct PrintersSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PrintersSwiftUIView()
            .environmentObject(Settings(printers: [Printer(id: UUID(), name: "Prusa Mk4", imageType: .generic)]))
    }
}
