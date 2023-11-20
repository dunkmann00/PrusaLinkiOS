//
//  PrintersCVProxy.swift
//  PrusaLink
//
//  Created by George Waters on 11/4/23.
//
// This is supposed to mirror the behavior of a ScrollViewReader.
// Its not quite as magical though. A ProxyCVProxy must be created
// as a State variable and then the printersCVReader View modifier
// must be called on either a PrintersCollectionView or one of it's
// ancestor views. The printersCVProxy object can then be accessed
// as an environment variable. Call its scrollTo function and pass
// in the printer that should be scrolled to and the
// PrintersCollectionView will scroll to it.

import SwiftUI

class PrintersCVProxy {
    private struct Registration: Hashable {
        let id: Int
        let handler: (Printer) -> Bool
        
        static func == (lhs: PrintersCVProxy.Registration, rhs: PrintersCVProxy.Registration) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    private var registrations: Set<Registration> = []
    
    func registerPrintersCollectionVC<Content: View>(_ printersCollectionVC: PrintersCollectionViewController<Content>) {
        let registration = Registration(id: printersCollectionVC.hashValue) { printer in
            printersCollectionVC.scrollToPrinter(printer)
        }
        registrations.insert(registration)
    }
    
    func unregisterPrintersCollectionVC<Content: View>(_ printersCollectionVC: PrintersCollectionViewController<Content>) {
        let registration = Registration(id: printersCollectionVC.hashValue, handler: {_ in false})
        registrations.remove(registration)
    }
    
    func scrollTo(_ printer: Printer) {
        for registration in registrations {
            if registration.handler(printer) {
                break
            }
        }
    }
}

private struct PrintersCVProxyKey: EnvironmentKey {
    static let defaultValue = PrintersCVProxy()
}

extension EnvironmentValues {
    var printersCVProxy: PrintersCVProxy {
        get { self[PrintersCVProxyKey.self] }
        set { self[PrintersCVProxyKey.self] = newValue }
    }
}

extension View {
    func printersCVReader(_ printersCVProxy: PrintersCVProxy) -> some View {
        environment(\.printersCVProxy, printersCVProxy)
    }
}
