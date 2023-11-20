//
//  PrintersCollectionView.swift
//  PrusaLink
//
//  Created by George Waters on 11/4/23.
//

import UIKit
import SwiftUI


// This is more of a wrapper view to the view doing all the actual
// work. But because the underlying _PrintersCollectionView is a
// UIViewControllerRepresentable, I can't add all the SwiftUI view
// modifiers. So we wrap it with this and add all our SwiftUI
// customization.
struct PrintersCollectionView<Content: View>: View {
    @Binding var printers: [Printer]
    @ViewBuilder let content: (Binding<Printer>) -> Content
        
    @Environment(\.printersCVProxy) var printersCVProxy: PrintersCVProxy
    
    var body: some View {
        _PrintersCollectionView($printers, content: content)
            .ignoresSafeArea()
            .navigationTitle("Printers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        let newPrinter = Printer()
                        printers.append(newPrinter)
                        Task {
                            // We need to wait for SwiftUI to propagate
                            // the new printers array to all the other
                            // views, the PrintersCollectionView in particular.
                            try await Task.sleep(for: .seconds(0.1))
                            printersCVProxy.scrollTo(newPrinter)
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    NavigationLink(view: .infoView) {
                        Image(systemName: "info.circle")
                    }
                }
            }
    }
    
    init(_ printers: Binding<[Printer]>, @ViewBuilder content: @escaping (Binding<Printer>) -> Content) {
        self._printers = printers
        self.content = content
    }
}

struct _PrintersCollectionView<Content: View>: UIViewControllerRepresentable {
    class Coordinator {
        var parent: _PrintersCollectionView
        
        init(_ parent: _PrintersCollectionView) {
            self.parent = parent
        }
    }
    
    private class Status {
        var needsUpdate = true
    }
        
    @Binding var printers: [Printer]
    @ViewBuilder let content: (Binding<Printer>) -> Content
    
    @Environment(\.printersCVProxy) var printersCVProxy: PrintersCVProxy
    
    private let status = Status()
    
    init(_ printers: Binding<[Printer]>, @ViewBuilder content: @escaping (Binding<Printer>) -> Content) {
        self._printers = printers
        self.content = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PrintersCollectionViewController<Content> {
        let printersCollectionVC = PrintersCollectionViewController(printers, coordinator: context.coordinator, content: content)
        printersCVProxy.registerPrintersCollectionVC(printersCollectionVC)
        return printersCollectionVC
    }
    
    func updateUIViewController(_ uiViewController: PrintersCollectionViewController<Content>, context: Context) {
        Task {
            if status.needsUpdate {
                context.coordinator.parent = self
                printersCVProxy.registerPrintersCollectionVC(uiViewController)
                uiViewController.updatePrinterBoxesWithPrinters(printers)
                uiViewController.updatePrinterBoxesWithContent(content)
                status.needsUpdate = false
            }
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: PrintersCollectionViewController<Content>, coordinator: Coordinator) {
        coordinator.parent.printersCVProxy.unregisterPrintersCollectionVC(uiViewController)
    }
}
