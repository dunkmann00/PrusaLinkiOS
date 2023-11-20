//
//  PrinterBox.swift
//  PrusaLink
//
//  Created by George Waters on 11/4/23.
//
// The idea with PrinterBox is to create a way for us to let our UIHostingConfiguration
// in our Collection View Cell know there were changes to the printer. Because the
// PrinterBox is an ObservableObject, when printer or content changes, SwiftUI will
// update all the views that need to be updated. Because PrinterBox is a class, we can
// hold on to a reference of it and update it as needed, thus initiating the update. If
// we just gave the CollectionViewCell the printer/closure struct, we would have no way
// of updating them.

import SwiftUI

protocol PrinterBoxDelegate: AnyObject {
    func printerDidChangeInBox<Content: View>(_ printerBox: PrinterBox<Content>)
}

class PrinterBox<Content: View>: ObservableObject {
    let id: UUID = UUID()
    @Published var printer: Printer {
        didSet {
            delegate?.printerDidChangeInBox(self)
        }
    }
    @Published var content: (Binding<Printer>) -> Content
    
    weak var delegate: PrinterBoxDelegate?
    
    init(_ printer: Printer, @ViewBuilder content: @escaping (Binding<Printer>) -> Content) {
        self.printer = printer
        self.content = content
    }
}

extension PrinterBox: Hashable {
    static func == (lhs: PrinterBox, rhs: PrinterBox) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
