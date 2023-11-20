//
//  CustomPrinterView.swift
//  PrusaLink
//
//  Created by George Waters on 11/2/23.
//

import SwiftUI

struct CustomPrinterView: View {
    let imageData: Data?
    
    var body: some View {
        if let imageData = imageData,
           let image = Image(data: imageData) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Color(uiColor: .systemGray3)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(systemName: "questionmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(uiColor: .systemGray6))
                        .padding(15)
                }
        }
    }
}
