//
//  SwiftUIExtensions.swift
//  PrusaLink
//
//  Created by George Waters on 11/4/23.
//

import SwiftUI

extension Color {
    init(colorData: Printer.ColorData) {
        self.init(hue: colorData.h, saturation: colorData.s, brightness: colorData.b)
    }
    
    var colorData: Printer.ColorData {
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return .defaultColor
        }
        
        return Printer.ColorData(h: h, s: s, b: b)
    }
}

extension Image {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        self.init(uiImage: uiImage)
    }
}

extension NavigationLink where Destination == Never {
    init(view: NavigationView, @ViewBuilder label: () -> Label) {
        self.init(value: view, label: label)
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
