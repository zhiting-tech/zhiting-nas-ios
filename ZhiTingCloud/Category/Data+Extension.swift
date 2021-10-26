//
//  Data+Extension.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/7.
//

import Foundation
import CommonCrypto
import CryptoKit

fileprivate func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
    return iterator.map { String(format: "%02x", $0) }.joined()
}

extension Data {
    public var sha256: String {
        return hexString(SHA256.hash(data: self).makeIterator())
        
    }
}

