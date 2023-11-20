//
//  SettingsTextField.swift
//  PrusaLink
//
//  Created by George Waters on 9/18/23.
//

import SwiftUI

struct SettingsTextField: View {
    @Binding var text: String
    @FocusState var focused: Bool
    let title: String
    var autocapitalization: TextInputAutocapitalization?
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self.autocapitalization = .never
        self._text = text
    }
    
    var body: some View {
        HStack {
            TextField(title, text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(autocapitalization)
                .submitLabel(.done)
                .focused($focused)
            if focused && !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.init(uiColor: .systemGray3))
                }
            }
        }
        .buttonStyle(.borderless) // Prevents multiple buttons from taking action from each others taps...idk why
    }
    
    func textInputAutocapitalization(_ autocapitalization: TextInputAutocapitalization?) -> Self {
        var settingsTextField = self
        settingsTextField.autocapitalization = autocapitalization
        return settingsTextField
    }
}
