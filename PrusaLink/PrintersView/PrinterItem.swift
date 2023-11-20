//
//  PrinterItem.swift
//  PrusaLink
//
//  Created by George Waters on 10/16/23.
//

import SwiftUI

struct PrinterItem: View {
    var printer: Printer
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            switch printer.imageType {
            case .generic:
                GenericPrinterView(colorData: printer.genericImageColor ?? .defaultColor)
            case .custom:
                CustomPrinterView(imageData: printer.customImageData)
            }
            Spacer()
            Text(printer.name)
                .font(.system(.title3))
                .foregroundColor(.primary)
                .bold()
        }
        .lineLimit(3)
        .frame(
              minWidth: 0,
              maxWidth: .greatestFiniteMagnitude,
              minHeight: 0,
              maxHeight: .greatestFiniteMagnitude,
              alignment: .center
            )
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(lineWidth: 2)
                .foregroundColor(Color(uiColor: .opaqueSeparator))
        )
        .background(.background)
        .cornerRadius(10)
    }
}
