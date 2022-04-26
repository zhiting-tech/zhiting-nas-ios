//
//  FileModel.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/18.
//

import UIKit

class FileModel: BaseModel {
    /// id
    var id = 0
    /// 子目录/文件名称
    var name = ""
    /// 类型 0:目录;1:文件
    var type = 0
    /// 文件最后更新时间
    var mod_time = 0
    /// 子目录/文件大小
    var size = 0
    /// 子目录/文件路径
    var path = ""
    /// 是否被选择
    var isSelected = false
    
    //shareFile
    
    var from_user = ""
    
    var is_family_path = 0
    
    //是否加密
    var is_encrypt = 0 //是否加密文件夹；文件夹有效0:1
    /// 是否可读：1/0
    var read = 0
    /// 是否可写：1/0
    var write = 0
    /// 是否可删：1/0
    var deleted = 0
    /// 缩略图地址
    var thumbnail_url = ""
}
