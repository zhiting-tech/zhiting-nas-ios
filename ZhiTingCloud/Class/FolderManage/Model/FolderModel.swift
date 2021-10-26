//
//  FolderModel.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/7/8.
//

import UIKit

class FolderModel: BaseModel {
    /// 文件夹id
    var id = 0
    
    /// 存储池id
    var pool_id: String?
    
    /// 存储池分区id
    var partition_id: String?
    
    /// 名称
    var name = ""
    
    /// 类型  1私人文件夹 2分享文件夹
    var mode = 2
    
    /// 是否加密 0未加密 1加密
    var is_encrypt = 0
    
    /// 文件夹路径
    var path = ""
    
    /// 存储分区名称
    var pool_name: String?
    
    /// 存储池分区名称
    var partition_name: String?
    
    /// 可访问成员
    var persons: String?
    
    /// 可访问成员
    var auth: [FolderAuthModel]?
    
    /// 为空则代表没有异步状态,
    ///  TaskMovingFolder_1 修改中,
    ///   TaskMovingFolder_0 修改失败,
    ///    TaskDelFolder_1 删除中,
    ///     TaskDelFolder_0 删除失败
    var status = ""
    
    /// 异步任务id
    var task_id = ""
    
    var statusEnum: FolderStatus {
        FolderStatus(status: status)
    }

    /// 文件夹枚举类型
    var folderMode: FolderMode {
        FolderMode(type: mode)
    }
}

extension FolderModel {
    /// 文件夹类型枚举
    enum FolderMode {
        /// 个人文件夹
        case `private`
        /// 分享文件夹
        case shared
        
        
        init(type: Int) {
            if type == 1 {
                self = .private
            } else {
                self = .shared
            }
        }
        
        var intValue: Int {
            switch self {
            case .private:
                return 1
            case .shared:
                return 2
            }
        }

    }
    
    
    /// 文件夹状态枚举
    enum FolderStatus {
        /// 无
        case none
        /// 删除失败
        case failToDelete
        /// 删除中
        case deleting
        /// 修改失败
        case failToEdit
        /// 修改中
        case editing
        
        init(status: String) {
            if status == "TaskDelFolder_0" {
                self = .failToDelete
            } else if status == "TaskDelFolder_1" {
                self = .deleting
            } else if status == "TaskMovingFolder_0" {
                self = .failToEdit
            } else if status == "TaskMovingFolder_1" {
                self = .editing
            } else {
                self = .none
            }
        }
        
    }
    

}
