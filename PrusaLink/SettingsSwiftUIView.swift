//
//  SettingsSwiftUIView.swift
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
                    .focused($focused)
                if !focused {
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: "eye.slash.fill")
                    }
                }
            }
        }
    }
    
}

struct SettingsTextFieldModifier: ViewModifier {
    @Binding var text: String
    @FocusState var focused: Bool
    
    func body(content: Content) -> some View {
        HStack {
            content
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
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
}

struct SettingsSwiftUIView: View {
    let ghString = "https://github.com/dunkmann00/PrusaLinkiOS"
    let prusaGHString = "https://github.com/prusa3d"
    
    @StateObject var settings: Settings = Settings.global
    
    @FocusState var ipAddressIsFocused: Bool
    
    var body: some View {
        Form {
            Section("IP Address") {
                TextField(text: Binding($settings.ipAddress, replacingNilWith: "")) {
                    Text("IP Address")
                }
                .settingsTextField(Binding($settings.ipAddress, replacingNilWith: ""))
                .focused($ipAddressIsFocused)
                .keyboardType(.decimalPad)
                .toolbar {
                    if ipAddressIsFocused {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("done") {
                                ipAddressIsFocused = false
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    }
                }
            }
            Section("Credentials") {
                TextField(text: Binding($settings.username, replacingNilWith: "")) {
                    Text("Username")
                }
                .settingsTextField(Binding($settings.username, replacingNilWith: ""))
                SecureTextField(text: Binding($settings.password, replacingNilWith: "")) {
                    Text("Password")
                }
                .settingsTextField(Binding($settings.password, replacingNilWith: ""))
            }
            Section("Info") {
                VStack(alignment: .leading, spacing: 18) {
                    Group{
                        Text("The source code for this app can be found here:")
                            .font(.system(.title3))
                            .bold()
                        Link(ghString, destination: URL(string: ghString)!)
                            .frame(maxWidth: .infinity)
                    }
                    Divider()
                    Group {
                        Text("What this app does:")
                            .font(.system(.title3))
                            .bold()
                        HStack(alignment: .firstTextBaseline) {
                            Text("1.")
                            Text("Load the PrusaLink web app from your printer at the provided IP Address.")
                        }
                        HStack(alignment: .firstTextBaseline) {
                            Text("2.")
                            Text("Handle the authentication with the provided credentials.")
                        }
                    }
                    Group {
                        Text("Why is that useful?")
                            .font(.system(.title3))
                            .bold()
                        Text("As of the release date of version \(Bundle.main.getAppVersion()) of this app, due to an unknown issue, you can't view PrusaLink with Safari on iOS. It will keep asking for the credentials but never load the webpage.")
                        Text("It is also kind of nice to have a dedicated app for viewing your printer's status...well I think it is anyway. 😁")
                    }
                    Text("If you have any issues or questions, please visit the link above.")
                        .font(.system(.title3))
                        .bold()
                    Divider()
                    Group {
                        Text("This app is not made by or affiliated with Prusa.")
                            .font(.system(.title2))
                            .bold()
                        Text("To check out Prusa's Open Source Software visit their Github Page:")
                            .font(.system(.title3))
                            .bold()
                        Link(prusaGHString, destination: URL(string: prusaGHString)!)
                            .frame(maxWidth: .infinity)
                    }
                    Divider()
                    Text("PrusaLinkiOS - \(Bundle.main.getAppVersion())\nGeorge Waters \(Bundle.main.getCompileYear())")
                        .font(.system(.title2))
                        .bold()
                        
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUIView()
    }
}

extension View {
    func settingsTextField(_ text: Binding<String>) -> some View {
        modifier(SettingsTextFieldModifier(text: text))
    }
}

// https://alanquatermain.me/programming/swiftui/2019-11-15-CoreData-and-bindings/#assigning-nil-or-non-nil-to-a-non-optional-binding
public extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilValue: Value) {
        self.init(
            get: { source.wrappedValue ?? nilValue },
            set: { newValue in
                if newValue == nilValue {
                    source.wrappedValue = nil
                }
                else {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}
