//
//  PrusaWebView.swift
//  PrusaLink
//
//  Created by George Waters on 10/18/23.
//

import SwiftUI

struct PrusaWebView: View {
    var printer: Printer
    @Binding var logoViewOffset: CGFloat
    
    var body: some View {
        _PrusaWebView(printer: printer, logoViewOffset: $logoViewOffset)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavLogoView(offset: logoViewOffset, title: printer.name)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(view: .settingsView(printer.id)) {
                        Image(systemName: "gearshape")
                    }
                }
            }
    }
}

struct _PrusaWebView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PrusaWebViewController
    
    var printer: Printer
    @Binding var logoViewOffset: CGFloat
    
    func makeUIViewController(context: Context) -> PrusaWebViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(identifier: PrusaWebViewController.storyboardID) { coder in
            PrusaWebViewController(coder: coder, printer: printer, logoViewOffset: $logoViewOffset)
        }
    }
    
    func updateUIViewController(_ uiViewController: PrusaWebViewController, context: Context) {
        if uiViewController.printer != printer {
            uiViewController.printer = printer
        }
    }
}



struct PrusaWebView_Previews: PreviewProvider {
    static var previews: some View {
        PrusaWebView(printer: Printer(), logoViewOffset: .constant(50))
    }
}
