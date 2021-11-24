//
//  UIFont+Extension.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit

extension UIFont {
    
    enum AppFontType: String {
        case bold = "PingFangSC-SemiBold"
        case regular = "PingFangSC-Regular"
        case medium = "PingFangSC-Medium"
        case light = "PingFangSC-Light"
        case D_bold = "DINAlternate-Bold"
    }
    /// Generate App font
    /// - Parameters:
    ///   - size: font size
    ///   - type: appFontType
    /// - Returns: App font
    static func font(size: CGFloat, type: AppFontType = .regular) -> UIFont {
        let name = type.rawValue
        guard let font = UIFont(name: name, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
