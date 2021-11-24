//
//  AuthModel.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/2.
//

import Foundation


class AuthModel: BaseModel {
    /// 授权的用户账号id
    var cloud_user_id: Int?
    /// 云端地址
    var cloud_url: String?
    
    /// 云端账号cookie
    var sessionCookie: String?
    /// 用户昵称
    var nickname = ""
    /// 授权的家庭列表
    var areas = [Area]()
}


