//
//  OpenUrlManager.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/2.
//

import Foundation

// MARK: - OpenUrlManager
class OpenUrlManager {
    enum Action: String {
        /// 网盘授权
        case auth
    }

    static var shared = OpenUrlManager()

    private init() {}

    func open(url: URL) {
        let urlString = url.absoluteString
        
        print("--------------------- open from other app ----------------------------------")
        print(Date())
        print("---------------------------------------------------------------------------")
        print("open url from \(urlString)")
        print("---------------------------------------------------------------------------\n\n")
        guard
            let components = urlString.components(separatedBy: "zhitingNas://operation?").last,
            let action = components.components(separatedBy: "&").first?.components(separatedBy: "=").last
        else {
            return
        }
        
        switch Action(rawValue: action) {
        case .auth:
            // ZhiTingNas://operation?action=auth
            let shareTokenURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.zhiting.tech")!.appendingPathComponent("shareToken.plist")
            
            /// 读取授权成功响应并解密
            guard
                let data = try? Data(contentsOf: shareTokenURL),
                let json = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? String
            else { return }
            
            if let authResult = AuthModel.deserialize(from: json) {
                let user = User()
                user.nickname = authResult.nickname

                /// 存储家庭信息
                AreaManager.shared.cacheAreas(areas: authResult.areas)
                if let area = AreaManager.shared.getAreaList().first {
                    AreaManager.shared.currentArea = area
                    user.user_id = area.sa_user_id
                }
                
                
                
                if let cloudUserId = authResult.cloud_user_id,
                   let cloudUrl = authResult.cloud_url,
                   let cookieValue = authResult.sessionCookie { /// 云端的授权
                    user.user_id = cloudUserId
                    UserManager.shared.isCloudUser = true
                    UserManager.shared.cloudUrl = cloudUrl
                    
                    /// 写入云端账号cookie
                    let url =  cloudUrl.components(separatedBy: "https://").last
                    
                    if let cookie = HTTPCookie(properties: [
                        HTTPCookiePropertyKey.domain : url?.components(separatedBy: "http://").last ?? "",
                        HTTPCookiePropertyKey.value : cookieValue,
                        HTTPCookiePropertyKey.path : "/",
                        HTTPCookiePropertyKey.name : "_session_"
                    ]) {
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                    
                    
                } else {
                    UserManager.shared.isCloudUser = false
                }
                
                
                UserManager.shared.currentUser = user
                UserManager.shared.cacheUser(user: user)
            }
            
            // gomobile
            //授权成功，重新激活gomobile
            GoFileNewManager.shared.setup()
            GoFileNewManager.shared.gomobileRun()
            
            SceneDelegate.shared.window?.rootViewController = TabbarController()
        default:
            break
        }

    }
    
}
