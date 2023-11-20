//
//  ColorDataPicker.swift
//  PrusaLink
//
//  Created by George Waters on 11/02/23.
//

import SwiftUI

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
