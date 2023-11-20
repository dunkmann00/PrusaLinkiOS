//
//  SecureTextField.swift
//  PrusaLink
//
//  Created by George Waters on 9/18/23.
//

import SwiftUI

struct SecureTextField<Label: View>: View {
    @Binding var text: String
    let prompt: Text?
    @ViewBuilder let label: () -> Label

    @State var isSecure: Bool = true
    @FocusState var focused: Bool
    
    init(text: Binding<String>, prompt: Text? = nil, @ViewBuilder label: @escaping () -> Label) {
        self._text = text
        self.prompt = prompt
        self.label = label
    }
    
    var body: some View {
        HStack {
            if isSecure {
                SecureField(text: $text, prompt: prompt, label: label)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .focused($focused)
                if !focused {
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: "eye.fill")
                    }
                }
            } else {
                TextField(text: $text, prompt: prompt, label: label)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .focused($focused)
                if !focused {
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: "eye.slash.fill")
                    }
                }
            }
            if focused && !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.init(uiColor: .systemGray3))
                }
            }
        }
        .buttonStyle(.borderless)
    }
    
}
