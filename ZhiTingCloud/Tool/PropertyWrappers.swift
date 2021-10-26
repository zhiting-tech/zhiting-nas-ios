//
//  PropertyWrappers.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/11.
//

import Foundation

@propertyWrapper
struct UserDefaultBool{
    let userDefaultKey: String
    
    var wrappedValue: Bool {
        get {
            UserDefaults.standard.bool(forKey: userDefaultKey)
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: userDefaultKey)
        }
    }
    
    init(_ userDefaultKey: String) {
        self.userDefaultKey = userDefaultKey
    }

}

@propertyWrapper
struct UserDefaultString {
    let userDefaultKey: String
    
    var wrappedValue: String {
        get {
            UserDefaults.standard.string(forKey: userDefaultKey) ?? ""
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: userDefaultKey)
        }

    }
    
    init(_ userDefaultKey: String) {
        self.userDefaultKey = userDefaultKey
    }

}
