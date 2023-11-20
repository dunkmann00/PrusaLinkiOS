//
//  DiskIO.swift
//  PrusaLink
//
//  Created by George Waters on 11/02/23.
//

import Foundation

struct DiskIO {
    let appSupportDir: URL
    let storageDir: URL
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    init(storageDir: String) {
        appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.storageDir = appSupportDir.appendingPathComponent(storageDir, conformingTo: .directory)
        createDirIfMissing(self.storageDir)
        
    }
    
    private func createDirIfMissing(_ url: URL) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating Application Support Directory: \n\(error)")
        }
    }
    
    func urlForKey(_ name: String) -> URL {
        storageDir.appendingPathComponent(name, conformingTo: .json)
    }
    
    func load<T>(_ type: T.Type, forKey name: String) -> T? where T: Decodable {
        do {
            let data = try Data(contentsOf: urlForKey(name))
            let value = try decoder.decode(type, from: data)
            return value
        } catch {
            print("Error loading key '\(name)'")
            print(error)
            return nil
        }
    }
    
    func load<T>(_ type: Optional<T>.Type, forKey name: String) -> T? where T: Decodable {
        do {
            let data = try Data(contentsOf: urlForKey(name))
            let value = try decoder.decode(type, from: data)
            return value
        } catch {
            print("Error loading Optional key '\(name)'")
            print(error)
            return nil
        }
    }
    
    func store<T>(_ value: T, forKey name: String) where T: Encodable {
        do {
            let data = try encoder.encode(value)
            try data.write(to: urlForKey(name), options: .atomic)
        } catch {
            print("Error storing key '\(name)'")
            print(error)
        }
    }
    
    func removeKey(_ name: String) {
        do {
            try FileManager.default.removeItem(at: urlForKey(name))
        } catch {
            print("Error removing key '\(name)'")
            print(error)
        }
    }
}
