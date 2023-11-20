//
//  RemovePrinterAlertModifier.swift
//  PrusaLink
//
//  Created by George Waters on 11/20/23.
//

import SwiftUI

struct RemovePrinterAlertModifier: ViewModifier {
    let printerName: String
    @Binding var isPresented: Bool
    let removeAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Remove \(printerName)", isPresented: $isPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Remove Printer", role: .destructive, action: removeAction)
            } message: {
                Text("Are you sure you want to remove this printer?")
            }
    }
}

extension View {
    func removePrinterAlert(_ printerName: String, isPresented: Binding<Bool>, removeAction: @escaping () -> Void) -> some View {
        modifier(RemovePrinterAlertModifier(printerName: printerName, isPresented: isPresented, removeAction: removeAction))
    }
}
