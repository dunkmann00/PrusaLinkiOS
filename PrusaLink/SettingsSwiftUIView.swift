//
//  SettingsSwiftUIView.swift
//  PrusaLink
//
//  Created by George Waters on 9/18/23.
//

import SwiftUI
import PhotosUI

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

struct SettingsSwiftUIView: View {
    @Binding var printer: Printer
        
    @FocusState var ipAddressIsFocused: Bool
        
    @State var isPhotoPickerPresented = false
    @State var selectedPhotoItem: PhotosPickerItem?
    @State var isLoadingPhoto = false
    
    @State var isShowingRemoveAlert = false
    
    @EnvironmentObject var settings: Settings
    @Environment(\.navigationViews) var navigationViews
    
    var body: some View {
        Form {
            Section("Name") {
                SettingsTextField("Name", text: $printer.name)
                    .textInputAutocapitalization(.words)
            }
            
            Section("IP Address") {
                SettingsTextField("IP Address", text: Binding($printer.ipAddress, replacingNilWith: ""))
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
                SettingsTextField("Username", text: Binding($printer.username, replacingNilWith: ""))

                SecureTextField(text: Binding($printer.password, replacingNilWith: "")) {
                    Text("Password")
                }
            }
            
            Section("Image") {
                Picker("Type", selection: $printer.imageType) {
                    Text("Prusa Image").tag(Printer.ImageType.generic)
                    Text("Photo").tag(Printer.ImageType.custom)
                }
                switch printer.imageType {
                case .generic:
                    VStack {
                        GenericPrinterImage(colorData: printer.genericImageColor ?? .defaultColor)
                            .frame(maxHeight: 300)
                        ColorDataPicker(colorData: $printer.genericImageColor)
                    }
                case .custom:
                    VStack(spacing: 16) {
                        if isLoadingPhoto {
                            ProgressView()
                                .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxHeight: 300)
                        } else {
                            CustomPrinterImage(imageData: printer.customImageData)
                                .frame(maxHeight: 300)
                        }
                        HStack {
                            Button("Choose Photo") {
                                isPhotoPickerPresented = true
                            }
                            Spacer()
                        }
                    }
                    .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedPhotoItem, matching: .images)
                    
                }
                Button("Reset") {
                    printer.customImageData = nil
                    printer.genericImageColor = nil
                    printer.imageType = .generic
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                isLoadingPhoto = true
                Task(priority: .userInitiated) {
                    defer {
                        isLoadingPhoto = false
                    }
                    guard let data = try? await newItem?.loadTransferable(type: Data.self) else {
                        print("Loading photo failed")
                        printer.customImageData = nil
                        return
                    }
                    printer.customImageData = data
                    
                }
            }
            
            HStack {
                Spacer()
                Button("Remove Printer", role: .destructive) {
                    isShowingRemoveAlert = true
                }
                Spacer()
            }
        }
        .removePrinterAlert(printer.name, isPresented: $isShowingRemoveAlert) {
            guard let index = settings.printers.firstIndex(where: { $0.id == printer.id }) else {
                return
            }
            settings.printers.remove(at: index)
            navigationViews.wrappedValue = []
        }
    }
}

struct InfoView: View {
    let ghString = "https://github.com/dunkmann00/PrusaLinkiOS"
    let prusaGHString = "https://github.com/prusa3d"
    
    var body: some View {
        Form {
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
        .navigationTitle("App Info")
    }
}

struct ColorDataPicker: View {
    @Binding var colorData: Printer.ColorData?
        
    var color: Binding<Color> {
        Binding {
            Color(colorData: colorData ?? .defaultColor)
        } set: { newValue in
            colorData = newValue.colorData
        }
    }
    
    init(colorData: Binding<Printer.ColorData?>) {
        _colorData = colorData
    }
    
    var body: some View {
        ColorPicker("Choose Color", selection: color, supportsOpacity: false)
    }
}

struct RemovePrinterAlertModifier: ViewModifier {
    let printerName: String
    @Binding var isPresented: Bool
    let removeAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Remove \(printerName)", isPresented: $isPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Remove Printer", role: .destructive, action: removeAction)
            } message: {
                Text("Are you sure you want to remove this printer?")
            }
    }
}

extension View {
    func removePrinterAlert(_ printerName: String, isPresented: Binding<Bool>, removeAction: @escaping () -> Void) -> some View {
        modifier(RemovePrinterAlertModifier(printerName: printerName, isPresented: isPresented, removeAction: removeAction))
    }
}

struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUIView(printer: .constant(Printer(id: UUID(), name:"Preview", imageType: .custom)))
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
