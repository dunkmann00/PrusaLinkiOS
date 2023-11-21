//
//  InfoView.swift
//  PrusaLink
//
//  Created by George Waters on 11/2/23.
//

import SwiftUI

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
                        Text("Load the PrusaLink web app from your printer at the provided IP Address. (Multiple printers are supported.)")
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
                    Text("As of the release date of version \(Bundle.main.getAppVersion()) of this app, due to an issue, you can't view PrusaLink with Safari on iOS. It will keep asking for the credentials but never load the webpage.")
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

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
