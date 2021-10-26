//
//  ResponseModel.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/2.
//

import Foundation


class ApiServiceResponseModel<T: BaseModel>: BaseModel {
    var status = 0
    var reason = ""
    var data = T()
}

class ApiServiceListResponseModel<T: BaseModel>: BaseModel {
    var status = 0
    var reason = ""
    var data = [T]()
}


class ExampleResponse: BaseModel {
    var status = 0
    var reason = ""
}

class PagerModel: BaseModel {
    /// 当前页数
    var page = 0
    /// 每页数量
    var page_size = 0
    /// 总条数
    var total_rows = 0
    /// 是否有更多
    var has_more = true
}

class FileListResponse: BaseModel {
    var list = [FileModel]()
    var pager = PagerModel()
}

class UserDetailResponse: BaseModel {
    var user_info = User()
}

class SAUserListResponse: BaseModel {
    var users = [User]()
}

class AreaListResponse: BaseModel {
    var areas = [Area]()
}

class FolderListResposne: BaseModel {
    var list = [FolderModel]()
    var pager = PagerModel()
}

class StoragePoolListResposne: BaseModel {
    var list = [StoragePoolModel]()
    var pager = PagerModel()
}

class HardDiskListResposne: BaseModel {
    var list = [PhysicalVolume]()
    var pager = PagerModel()
}



//MARK: - 文件上传
/// 已上传文件块信息响应
class FileChunksResponse: BaseModel {
    var chunks = [ChunkModel]()
    
    
}

/// 分块model

class ChunkModel: BaseModel {
    /// 分块ID
    var id = 0
    /// 分块大小
    var size = 0
}

class FileUploadInfoResponse: BaseModel {
    var status = 0
    var reason = ""
    var data = FileUploadInfo()
    
    
    
}
class FileResourceModel: BaseModel {
    /// 目录/文件名称
    var name = ""
    
    /// 目录/文件大小
    var size = 0
    
    /// 最后更新时间
    var mod_time = 0
    
    /// 类型 0:目录;1:文件
    var type = 1
    
    /// 目录/文件路径
    var path = ""
    
   
}

/// 文件上传响应
class FileUploadInfo: BaseModel {
    var resources = FileResourceModel()
    var chunks = [ChunkModel]()
}

class TemporaryResponse: BaseModel {
    //临时通道地址
    var host = ""
    
    //端口过期时间,单位秒
    var expires_time = 0
    
    //存储的时间
    var saveTime = ""
}

class SAAccessResponse: BaseModel {
    /// 是否允许访问(判断用户token是否在该SA中有效)
    var access_allow = false
}
