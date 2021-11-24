//
//  UserManager.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/9.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    lazy var fileManager = FileManager.default
    
    /// 用户缓存的路径url
    var userCacheFileURL: URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return url.appendingPathComponent("userCache")
    }
    
    var currentUser = User()
    
    @UserDefaultBool("isCloudUser")
    var isCloudUser: Bool
    
    @UserDefaultString("cloudUrl")
    var cloudUrl: String


    /// 获取缓存的用户信息
    /// - Returns: 用户信息缓存
    func getUserFromCache() -> User? {
        guard
            let url = userCacheFileURL,
            let jsonData = try? Data(contentsOf: url),
            let json = String(data: jsonData, encoding: .utf8),
            let user = User.deserialize(from: json)
        else {
            return nil
        }
        
        return user
    }
    
    
    /// 缓存用户到本地
    /// - Parameter areas: 需要缓存的用户
    func cacheUser(user: User) {
        guard let url = userCacheFileURL else { return }
        
        print("用户信息缓存至\(url.absoluteString)")

        if !fileManager.fileExists(atPath: url.absoluteString) {
            fileManager.createFile(atPath: url.absoluteString, contents: nil, attributes: nil)
        }
        
        guard let jsonData = user.toJSONString()?.data(using: .utf8) else { return }
        
        try? jsonData.write(to: url)

    }
}


