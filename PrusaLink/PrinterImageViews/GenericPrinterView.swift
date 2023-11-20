//
//  GenericPrinterView.swift
//  PrusaLink
//
//  Created by George Waters on 11/2/23.
//

import SwiftUI

struct GenericPrinterView: View {
    let colorData: Printer.ColorData
    
    var color: Color {
        Color(colorData: colorData)
    }
    
    var backgroundColor: Color {
        let ideal: CGFloat = 0.25
        var s = colorData.b, b = colorData.s, d = s - b // Swap saturation & brightness and compute delta
        
        if abs(d) >= ideal { // Happy path
            return Color(hue: colorData.h, saturation: s, brightness: b)
        }
        
        let minValue: CGFloat = min(0.2, s, b) // Our range, but we have to make it
        let maxValue: CGFloat = max(0.8, s, b) // larger if s or b are outside of it
        let sign: CGFloat = d > 0 ? 1 : -1 // s > b is +, s < b is -
        
        if abs(d) < ideal { // Too close
            let r: CGFloat = sign * ideal - d // Amount needed to separate s & b
            b = min(max(minValue, b - r), maxValue) // Clamp, if d is +, we want to decrease b, otherwise increase it
        }
        d = s - b // Compute delta again
        if abs(d) < ideal { // Still too close, b was either too close to min or max value
            let r: CGFloat = sign * ideal - d
            s = max(min(maxValue, s + r), minValue) // Clamp, if d is +, we want to increase s, otherwise decrease it
        }
        
        return Color(hue: colorData.h, saturation: s, brightness: b)
    }
    
    var body: some View {
        ZStack {
            Image("PrinterTemplateBackground")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(backgroundColor)
            Image("PrinterTemplateMask")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(color)
        }
    }
}
