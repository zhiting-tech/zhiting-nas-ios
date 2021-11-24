//
//  Area.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/2.
//

import Foundation

class Area: BaseModel {
    /// id
    var id = ""
    /// 名称
    var name = ""
    /// sa的地址
    var sa_lan_address: String?
    /// sa的token
    var sa_user_token = ""
    /// sa的mac地址
    var bssid: String?
    /// sa的 user_id
    var sa_user_id = 1
    /// 权限token
    var scope_token = ""
    /// 权限token 过期时间
    var expires_in = 0
    
    var temporaryIP = "https://sc.zhitingtech.com"
    /// 请求的地址url(判断请求sa还是sc)
    var requestURL: URL {
        if bssid == NetworkStateManager.shared.getWifiBSSID()
            && bssid != nil {//局域网
            return URL(string: "\(sa_lan_address ?? "")/api")!
        } else {
            return URL(string: "\(temporaryIP)/api")!
//            return URL(string: "\(sa_lan_address ?? "")/api")!
        }
    }

}
