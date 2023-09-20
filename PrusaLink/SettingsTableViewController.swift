//
//  SettingsTableViewController.swift
//  PrusaLink
//
//  Created by George Waters on 9/6/23.
//

import UIKit

class Settings {
    private static let ipAddressKey = "ipAddress"
    private static let usernameKey = "username"
    private static let passwordKey = "passwordKey"
    
    static let global = Settings()
    
    private var _ipAddress = UserDefaults.standard.string(forKey: Settings.ipAddressKey) {
        didSet {
            if oldValue != ipAddress {
                UserDefaults.standard.set(ipAddress, forKey: Settings.ipAddressKey)
            }
        }
    }
    
    var ipAddress: String? {
        get {
            _ipAddress
        }
        set {
            _ipAddress = newValue?.isEmpty ?? false ? nil : newValue
        }
    }
    
    private var _username = UserDefaults.standard.string(forKey: Settings.usernameKey) {
        didSet {
            if oldValue != username {
                UserDefaults.standard.set(username, forKey: Settings.usernameKey)
            }
        }
    }
    
    var username: String? {
        get {
            _username
        }
        set {
            _username = newValue?.isEmpty ?? false ? nil : newValue
        }
    }
    
    private var _password = KeychainSwift().get(Settings.passwordKey) {
        didSet {
            if oldValue != password {
                if let password = password {
                    KeychainSwift().set(password, forKey: Settings.passwordKey)
                } else {
                    KeychainSwift().delete(Settings.passwordKey)
                }
            }
        }
    }
    
    var password: String? {
        get {
            _password
        }
        set {
            _password = newValue?.isEmpty ?? false ? nil : newValue
        }
    }
}

class SettingsTableViewController: UITableViewController {
    let INPUT_CELL_ID = "inputCell"
    let ATTR_CELL_ID = "attributionCell"
    
    let ghString = "https://github.com/dunkmann00/PrusaLinkiOS"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getAttributionAttributedString() -> AttributedString {
        let linkURL = URL(string: ghString)
        var linkAttrString = AttributedString(ghString)
        linkAttrString.link = linkURL
        linkAttrString = AttributedString("The source code for this app can be found here:\n\n") +
                         linkAttrString +
                         AttributedString("\n\nPrusaLinkiOS - 2023 George Waters")
        linkAttrString.font = UIFont.systemFont(ofSize: 17)
        linkAttrString.foregroundColor = .label
        return linkAttrString
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let attributionCell = tableView.dequeueReusableCell(withIdentifier: ATTR_CELL_ID, for: indexPath) as! AttributionTableViewCell
//            attributionCell.attributedText = getAttributionAttributedString()
            return attributionCell
        }
        
        let inputCell = tableView.dequeueReusableCell(withIdentifier: INPUT_CELL_ID, for: indexPath) as! InputTableViewCell
        
        switch indexPath.section {
        case 0:
            inputCell.inputLabel.text = "IP Address"
            inputCell.inputTextField.placeholder = "0.0.0.0"
            inputCell.isSecureTextEntry = false
            inputCell.inputTextField.text = Settings.global.ipAddress
            inputCell.didEndEditingTextField = { textField in
                Settings.global.ipAddress = textField.text
            }
        case 1:
            switch indexPath.row {
            case 0:
                inputCell.inputLabel.text = "Username"
                inputCell.inputTextField.placeholder = nil
                inputCell.isSecureTextEntry = false
                inputCell.inputTextField.text = Settings.global.username
                inputCell.didEndEditingTextField = { textField in
                    Settings.global.username = textField.text
                }
            case 1:
                inputCell.inputLabel.text = "Password"
                inputCell.inputTextField.placeholder = nil
                inputCell.isSecureTextEntry = true
                inputCell.inputTextField.text = Settings.global.password
                inputCell.didEndEditingTextField = { textField in
                    Settings.global.password = textField.text
                }
            default:
                break
            }
        default:
            break
        }

        return inputCell
    }
}
