//
//  NavLogoView.swift
//  PrusaLink
//
//  Created by George Waters on 10/16/23.
//

import SwiftUI

struct NavLogoView: View {
    var offset: CGFloat
    var title: String
    
    let height: CGFloat = 44
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.headline)
                    .frame(height: height)
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.top, .bottom], 8)
                    .frame(height: height)
            }
            .offset(y: offset)
        }
        .frame(height: height, alignment: .top)
        .clipped()
    }
}
