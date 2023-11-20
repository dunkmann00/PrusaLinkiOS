//
//  Extenions.swift
//  PrusaLink
//
//  Created by George Waters on 9/20/23.
//

import UIKit

extension Bundle {
    func loadResource(_ name: String?, withExension ext: String?) -> String? {
        guard let resourceURL = url(forResource: name, withExtension: ext),
              let resourceData = try? Data(contentsOf: resourceURL) else {
            return nil
        }
        return String(data: resourceData, encoding: .utf8)
    }
    
    func getAppVersion() -> String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    func getCompileDate() -> Date {
        let bundleName = infoDictionary?["CFBundleName"] as? String ?? "Info.plist"
        guard let infoPath = path(forResource: bundleName, ofType: nil),
              let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
              let infoDate = infoAttr[.creationDate] as? Date else {
            return .now
        }
        
        return infoDate
    }
    
    func getCompileYear() -> String {
        String(Calendar(identifier: .gregorian).dateComponents([.year], from: getCompileDate()).year!)
    }
}

extension UIEdgeInsets {
    static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: lhs.top + rhs.top,
            left: lhs.left + rhs.left,
            bottom: lhs.bottom + rhs.bottom,
            right: lhs.right + rhs.right
        )
    }
}
