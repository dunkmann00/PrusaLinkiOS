//
//  Printer.swift
//  PrusaLink
//
//  Created by George Waters on 9/20/23.
//

import Foundation

struct Printer: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageType: ImageType
    var genericImageColor: ColorData?
    var customImageData: Data?
    var ipAddress: String?
    var username: String?
    var password: String?
        
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageType
        case genericImageColor
        case customImageData
        case ipAddress
        case username
    }
    
    enum ImageType: Codable {
        case generic
        case custom
    }
    
    struct ColorData: Codable, Equatable {
        let h: Double
        let s: Double
        let b: Double
        
        static let defaultColor = ColorData(h: (16.0/360.0), s: 0.8, b: 0.98)
    }
}

extension Printer: Hashable {
    static func == (lhs: Printer, rhs: Printer) -> Bool {
        (
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.imageType == rhs.imageType &&
            lhs.genericImageColor == rhs.genericImageColor &&
            lhs.customImageData == rhs.customImageData &&
            lhs.ipAddress == rhs.ipAddress &&
            lhs.username == rhs.username &&
            lhs.password == rhs.password
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Printer {
    init() {
        id = UUID()
        name = "Printer"
        imageType = .generic
    }
}
