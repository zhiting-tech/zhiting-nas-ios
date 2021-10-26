//
//  UserModel.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/5/24.
//

import UIKit


class User: BaseModel {
    /// 用户名字
    var nickname = ""
    
    /// 用户头像
    var icon_url = ""
    
    /// 用户权限
    var role_infos = [Role]()
    
    /// 用户云端id
    var user_id = 0

    /// sa_user_token
    var token = ""
    
    /// 手机号
    var phone = ""

    /// 是否被选中
    var isSelected: Bool?
    
    /// 是否家庭拥有者
    var is_owner: Bool?
    
    /// 用户文件夹读权限
    var read = 0
    /// 用户文件夹写权限
    var write = 0
    /// 用户文件夹删权限
    var deleted = 0
    
}



class Role: BaseModel {
    var id = ""
    var name = ""
}


/// 文件夹权限model
class FolderAuthModel: BaseModel {
    /// 用户id
    var u_id = 0
    
    /// 头像
    var face = ""
    
    /// 名称
    var nickname = ""

    /// 权限：“read/write/delete”，使用"/"隔开
    /// 用户文件夹读权限
    var read = 0
    /// 用户文件夹写权限
    var write = 0
    /// 用户文件夹删权限
    var deleted = 0
}
