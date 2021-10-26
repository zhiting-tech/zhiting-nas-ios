//
//  Screen.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/17.
//

import Foundation
import UIKit

//等比例缩放
func ZTScaleValue(_ value:CGFloat) -> CGFloat{
    return value * Screen.screenWidth / 375.0
}

struct Screen {
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var screenRatio: CGFloat {
        return screenHeight / 667 // base on iphone 8
    }
    
    ///navigation bar height
    static var k_nav_height: CGFloat {
        return statusBarHeight > 20 ? 88 : 64
    }

    /// tabbar height
    static var tabbarHeight: CGFloat {
        return statusBarHeight > 20 ? 83 : 49
    }

    /// safe area bottom margin
    static var bottomSafeAreaHeight: CGFloat {
        return statusBarHeight > 20 ? 20 : 0
    }

    
//    static var statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    
    /// status bar height
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
    }
}


// MARK: - ZTScaleProtocol
protocol ZTScaleProtocol {
    var ztScaleValue: CGFloat { get }
}


extension Int: ZTScaleProtocol {
    var ztScaleValue: CGFloat {
        return CGFloat(self) * Screen.screenWidth / 375.0
    }
}

extension Double: ZTScaleProtocol {
    var ztScaleValue: CGFloat {
        return CGFloat(self) * Screen.screenWidth / 375.0
    }
}

extension CGFloat: ZTScaleProtocol {
    var ztScaleValue: CGFloat {
        return self * Screen.screenWidth / 375.0
    }
}

extension Float: ZTScaleProtocol {
    var ztScaleValue: CGFloat {
        return CGFloat(self) * Screen.screenWidth / 375.0
    }
}
