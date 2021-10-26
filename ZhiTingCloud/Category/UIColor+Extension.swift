//
//  UIColor+Extension.swift
//  ZhiTingCloud
//
//  Created by mac on 2021/5/14.
//

import Foundation
import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        var hex = hex
        
        if hex.count == 7 {
            hex.append("ff")
        }

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
}


extension UIColor {
    static func custom(_ customColor: CustomColors) -> UIColor {
        return UIColor(named: customColor.colorName) ?? .white
    }
}

enum CustomColors: String {
    case black_3f4663
    case black_333333
    case black_555b73
    
    case white_ffffff
    
    case gray_cfd6e0
    case gray_f2f5fa
    case gray_f6f8fd
    case gray_f1f4fd
    case gray_f1f4fc
    case gray_94a5be
    case gray_dddddd
    case gray_eeeeee
    case gray_eeeff2
    case gray_dde5eb
    case gray_fafafa
    case gray_a2a7ae
    
    case orange_f6ae1e
    case orange_fdf3df
    case orange_feb447
    
    case red_fe0000
    case red_ffb06b
    
    case green_47d4ae
    case green_01dbc0
    
    case yellow_f3a934
    case yellow_ffd26e
    case yellow_febf32
    
    case blue_2da3f6
    case blue_7ba2f2
    case blue_427aed
    case blue_7ecffc
    
    case pink_ff7e6b
    
    case orange_ff6d57
    
    
    var colorName: String {
        return "color_\(self.rawValue.components(separatedBy: "_").last ?? "")"
    }
}
