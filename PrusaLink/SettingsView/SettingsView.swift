//
//  SettingsView.swift
//  PrusaLink
//
//  Created by George Waters on 9/18/23.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
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
                .keyboardType(.numberPad)
                .toolbar {
                    if ipAddressIsFocused {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button {
                                printer.ipAddress = (printer.ipAddress ?? "") + "."
                            } label: {
                                Text(".")
                                    .padding(.horizontal, 8)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.init(uiColor: .systemGray2))
                            
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
                        GenericPrinterView(colorData: printer.genericImageColor ?? .defaultColor)
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
                            CustomPrinterView(imageData: printer.customImageData)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(printer: .constant(Printer(id: UUID(), name:"Preview", imageType: .custom)))
    }
}
