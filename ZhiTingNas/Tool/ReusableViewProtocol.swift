//
//  ReusableViewProtocol.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/19.
//

import Foundation
import UIKit


protocol ReusableView {
    static var reusableIdentifier: String { get }
}


extension ReusableView where Self: UIView {
    static var reusableIdentifier: String {
        return NSStringFromClass(self)
    }
}
