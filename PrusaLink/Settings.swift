//
//  Settings.swift
//  PrusaLink
//
//  Created by George Waters on 9/20/23.
//

import Foundation
import Combine

class Settings: ObservableObject {
    private static let ipAddressKey = "ipAddress"
    private static let usernameKey = "username"
    private static let passwordKey = "passwordKey"
    
    @Published var ipAddress: String? = UserDefaults.standard.string(forKey: Settings.ipAddressKey)
    @Published var username: String?  = UserDefaults.standard.string(forKey: Settings.usernameKey)
    @Published var password: String?  = KeychainSwift().get(Settings.passwordKey)
    
    static let global = Settings()
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        persistentlyStore(publisher: $ipAddress) { ipAddress in
            UserDefaults.standard.set(ipAddress, forKey: Settings.ipAddressKey)
        }
        
        persistentlyStore(publisher: $username) { username in
            UserDefaults.standard.set(username, forKey: Settings.usernameKey)
        }
        
        persistentlyStore(publisher: $password) { password in
            if let password = password {
                KeychainSwift().set(password, forKey: Settings.passwordKey)
            } else {
                KeychainSwift().delete(Settings.passwordKey)
            }
        }
    }
    
    func persistentlyStore<Value: Equatable>(publisher: Published<Value>.Publisher, onUpdate: @escaping (Value) -> Void) {
        publisher
            .receive(on: DispatchQueue.global(qos: .default))
            .debounce(for: .seconds(1), scheduler: RunLoop.current)
            .removeDuplicates()
            .sink(receiveValue: onUpdate)
            .store(in: &cancellables)
    }
}
