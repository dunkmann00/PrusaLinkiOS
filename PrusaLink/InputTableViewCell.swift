//
//  InputTableViewCell.swift
//  PrusaLink
//
//  Created by George Waters on 9/6/23.
//

import UIKit

class InputTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    var isSecureTextEntry = false {
        didSet {
            if isSecureTextEntry {
                inputTextField.rightViewMode = .unlessEditing
                inputTextField.isSecureTextEntry = true
            } else {
                inputTextField.rightViewMode = .never
                inputTextField.isSecureTextEntry = false
            }
        }
    }
        
    private weak var showHideButton: UIButton!
    
    var didEndEditingTextField: ((UITextField) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let button = UIButton(type: .custom, primaryAction: UIAction(
            handler: { [weak self] action in
                let button = action.sender as! UIButton
                button.isSelected.toggle()
                
                self?.inputTextField.isSecureTextEntry.toggle()
            }
        ))
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        showHideButton = button
        
        inputTextField.rightView = showHideButton
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension InputTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("Editing Did End")
        didEndEditingTextField?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
