//
//  Settings.swift
//  PrusaLink
//
//  Created by George Waters on 9/20/23.
//

import Foundation
import Combine

class Settings: ObservableObject {
    @Published var printers: [Printer]
    
    @Published var selectedPrinterID: UUID?
    
    init (printers: [Printer] = [], selectedPrinterID: UUID? = nil) {
        self.printers = printers
        self.selectedPrinterID = selectedPrinterID
    }
}
