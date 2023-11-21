//
//  TestPrinters.swift
//  PrusaLink
//
//  Created by George Waters on 11/21/23.
//

import Foundation

struct TestPrinters {
    let printers: [Printer]
    
    static var `default` = TestPrinters(printers: [
        Printer(
            id: .init(),
            name: "MK4",
            imageType: .generic,
            genericImageColor: Printer.ColorData.defaultColor,
            customImageData: nil,
            ipAddress: "192.168.1.95",
            username: "maker",
            password: "helloworld"
        ),
        Printer(
            id: .init(),
            name: "MINI",
            imageType: .generic,
            genericImageColor: Printer.ColorData(h: 59/360, s: 0.53, b: 1),
            customImageData: nil,
            ipAddress: "192.168.1.95",
            username: "maker",
            password: "helloworld"
        ),
        Printer(
            id: .init(),
            name: "XL",
            imageType: .generic,
            genericImageColor: Printer.ColorData(h: 195/360, s: 0.55, b: 1),
            customImageData: nil,
            ipAddress: "192.168.1.95",
            username: "maker",
            password: "helloworld"
        ),
        Printer(
            id: .init(),
            name: "Top Secret",
            imageType: .generic,
            genericImageColor: Printer.ColorData(h: 280/360, s: 0.61, b: 0.96),
            customImageData: nil,
            ipAddress: "192.168.1.95",
            username: "maker",
            password: "helloworld"
        ),
        Printer(
            id: .init(),
            name: "Printer 5",
            imageType: .generic,
            genericImageColor: Printer.ColorData(h: 113/360, s: 0.47, b: 0.82),
            customImageData: nil,
            ipAddress: "192.168.1.95",
            username: "maker",
            password: "helloworld"
        )
    ])
}
