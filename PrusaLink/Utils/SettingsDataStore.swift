//
//  SettingsDataStore.swift
//  PrusaLink
//
//  Created by George Waters on 11/02/23.
//

import Foundation
import Combine

class SettingsDataStore {
    private var storedPrinters: [Printer] = []
    private var storedSelectedPrinterID: UUID?
    
    var cancellables: Set<AnyCancellable> = []
    
    let keychain = KeychainSwift()
    let diskIO = DiskIO(storageDir: "storage/settings")
    
    func loadSettings() -> Settings {
        cancellables = []
        
        // Only needed temporarily, can remove after a version or two
        moveUserDefaultDataToDiskIO()
        
        let printerIds = loadPrinterIDs()
        let printers = printerIds.compactMap { loadPrinterWithID($0) }
        let selectedPrinterID = loadSelectedPrinterID()
        let settings = Settings(printers: printers, selectedPrinterID: selectedPrinterID)
        storedPrinters = printers
        storedSelectedPrinterID = selectedPrinterID
        
        settings.$printers
            .receive(on: DispatchQueue.global(qos: .utility))
            .debounce(for: .seconds(1), scheduler: RunLoop.current)
            .sink { [weak self] printers in
                guard let self = self else { return }
                print("Printers publisher received")
                if storedPrinters != printers {
                    print("Printers Changed!")
                    updateStoredPrinters(printers)
                }
            }
            .store(in: &cancellables)
        
        settings.$selectedPrinterID
            .receive(on: DispatchQueue.global(qos: .utility))
            .debounce(for: .seconds(1), scheduler: RunLoop.current)
            .sink { [weak self] selectedPrinterId in
                guard let self = self else { return }
                if storedSelectedPrinterID != selectedPrinterId {
                    print("Selected Printer ID Changed")
                    storeSelectedPrinterID(selectedPrinterId)
                }
            }
            .store(in: &cancellables)
        
        return settings
    }
}

private extension SettingsDataStore {
    static let printerIDPrefix = "prusalink-printer"
    static let printerIDListKey = "prusalink-printer-ids"
    static let selectedPrinterID = "prusalink-selected-printer-id"
    
    func printerKeyForID(_ id: UUID) -> String {
        return "\(Self.printerIDPrefix)-\(id.uuidString)"
    }
    
    func loadPrinterWithID(_ id: UUID) -> Printer? {
        guard var printer = diskIO.load(Printer.self, forKey: printerKeyForID(id)) else {
            return nil
        }
        printer.password = keychain.get(printerKeyForID(printer.id))
        return printer
    }
    
    func storePrinter(_ printer: Printer) {
        diskIO.store(printer, forKey: printerKeyForID(printer.id))
        if let password = printer.password {
            keychain.set(password, forKey: printerKeyForID(printer.id))
        } else {
            keychain.delete(printerKeyForID(printer.id))
        }
    }
    
    func removePrinter(_ printer: Printer) {
        diskIO.removeKey(printerKeyForID(printer.id))
        keychain.delete(printerKeyForID(printer.id))
    }
    
    func loadSelectedPrinterID() -> UUID? {
        diskIO.load(UUID?.self, forKey: Self.selectedPrinterID)
    }
    
    func storeSelectedPrinterID(_ printerID: UUID?) {
        diskIO.store(printerID, forKey: Self.selectedPrinterID)
        storedSelectedPrinterID = printerID
    }
    
    func loadPrinterIDs() -> [UUID] {
        diskIO.load([UUID].self, forKey: Self.printerIDListKey) ?? []
    }
    
    func storePrinterIDs(_ printerIDs: [UUID]) {
        diskIO.store(printerIDs, forKey: Self.printerIDListKey)
    }
    
    func didPrinterIDsChange(_ newPrinters: [Printer]) -> Bool {
        if newPrinters.count != storedPrinters.count {
            return true
        }
        for (printer, storedPrinter) in zip(newPrinters, storedPrinters) {
            if printer.id != storedPrinter.id {
                return true
            }
        }
        return false
    }
    
    func updateStoredPrinters(_ newPrinters: [Printer]) {
        if didPrinterIDsChange(newPrinters) {
            let printerIDs = newPrinters.map { $0.id }
            storePrinterIDs(printerIDs)
        }
        
        let storedPrinterDict: [UUID: Printer] = Dictionary(uniqueKeysWithValues: storedPrinters.lazy.map { ($0.id, $0) })
        let newPrinterDict: [UUID: Printer] = Dictionary(uniqueKeysWithValues: newPrinters.lazy.map { ($0.id, $0) })
        
        let storedKeySet = Set(storedPrinters.lazy.map { $0.id })
        let newKeySet = Set(newPrinters.lazy.map { $0.id })

        
        let addedPrinters = newKeySet.subtracting(storedKeySet).compactMap { newPrinterDict[$0] }
        let deletedPrinters = storedKeySet.subtracting(newKeySet).compactMap { storedPrinterDict[$0] }
        let updatedPrinters = storedKeySet.intersection(newKeySet).map { (storedPrinterDict[$0], newPrinterDict[$0]) }
        
        addedPrinters.forEach { storePrinter($0) }
        deletedPrinters.forEach { removePrinter($0) }
        updatedPrinters.forEach { storedPrinter, newPrinter in
            guard let newPrinter = newPrinter,
                  let storedPrinter = storedPrinter else {
                return
            }
            if newPrinter != storedPrinter {
                storePrinter(newPrinter)
            }
        }
        
        storedPrinters = newPrinters
    }
    
    func moveUserDefaultDataToDiskIO() {
        let ipAddressKey = "ipAddress"
        let usernameKey = "username"
        let passwordKey = "passwordKey"
        
        let ipAddress = UserDefaults.standard.string(forKey: ipAddressKey)
        let username = UserDefaults.standard.string(forKey: usernameKey)
        let password = KeychainSwift().get(passwordKey)
        
        if ipAddress != nil || username != nil || password != nil {
            UserDefaults.standard.removeObject(forKey: ipAddressKey)
            UserDefaults.standard.removeObject(forKey: usernameKey)
            KeychainSwift().delete(passwordKey)
            
            let printer = Printer(id: UUID(), name: "Printer", imageType: .generic, ipAddress: ipAddress, username: username, password: password)
            storePrinterIDs([printer.id])
            storePrinter(printer)
        }
    }
}
