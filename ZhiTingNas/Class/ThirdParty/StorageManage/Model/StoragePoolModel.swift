//
//  StoragePoolModel.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/6/30.
//

import UIKit

/// 存储池
class StoragePoolModel: BaseModel {
    
    /// 存储池id
    var id = 0

    /// 存储池名称
    var name = ""
    
    /// 已用容量（默认GB）
    var use_capacity = 0
    
    /// 容量（默认GB）
    var capacity = 0
    
    /// 是否被选中
    var isSelected: Bool?
    
    /// 逻辑分区
    var lv = [LogicVolume]()
    
    /// 物理分区(硬盘)
    var pv = [PhysicalVolume]()
    
    /// 为空则没有异步任务,
    /// TaskDelPool_0删除存储池失败,
    /// TaskDelPool_1删除存储池中
    var status = ""
    
    /// 异步任务id
    var task_id = ""
    
    /// 存储池状态枚举值
    var statusEnum: StoragePoolStatus {
        StoragePoolStatus(status: status)
    }

}

extension StoragePoolModel {
    /// 存储池状态枚举
    enum StoragePoolStatus {
        /// 无
        case none
        /// 删除失败
        case failToDelete
        /// 删除中
        case deleting
        
        init(status: String) {
            if status == "TaskDelPool_0" {
                self = .failToDelete
            } else if status == "TaskDelPool_1" {
                self = .deleting
            } else {
                self = .none
            }
        }
    }
}


/// 存储池逻辑卷(分区)
class LogicVolume: BaseModel {
    /// id
    var id = ""
    /// 逻辑分区名称
    var name = ""
    /// 容量
    var capacity = 0
    /// 已用容量
    var use_capacity = 0
    
    //    为空则没有任务状态,
    //    TaskAddPartition_1添加存储池分区中,
    //    TaskAddPartition_0添加存储池分区失败,
    //    TaskUpdatePartition_1修改存储池分区中,
    //    TaskUpdatePartition_0修改存储池分区失败,
    //    TaskDelPartition_1删除存储池分区中,
    //    TaskDelPartition_0删除存储池分区失败
    var status = ""

    /// 异步任务id
    var task_id = ""
    
    /// 存储池状态枚举值
    var statusEnum: LogicVolumeStatus {
        LogicVolumeStatus(status: status)
    }

    /// 是否被选中
    var isSelected: Bool?
}

extension LogicVolume {
    /// 存储池状态枚举
    enum LogicVolumeStatus {
        /// 无
        case none
        /// 删除存储池分区失败
        case failToDelete
        /// 删除存储池分区中
        case deleting
        /// 添加存储池分区失败
        case failToAdd
        /// 添加存储池分区中
        case adding
        /// 编辑存储池分区失败
        case failToEdit
        /// 编辑存储池分区中
        case editing
        
        init(status: String) {
            if status == "TaskDelPartition_0" {
                self = .failToDelete
            } else if status == "TaskDelPartition_1" {
                self = .deleting
            } else if status == "TaskAddPartition_0" {
                self = .failToAdd
            } else if status == "TaskAddPartition_1" {
                self = .adding
            } else if status == "TaskUpdatePartition_0" {
                self = .failToEdit
            } else if status == "TaskUpdatePartition_1" {
                self = .editing
            }  else {
                self = .none
            }
        }
    }
}

/// 存储池物理卷(硬盘)
class PhysicalVolume: BaseModel {
    /// id
    var id = ""
    /// 物理分区名称
    var name = ""
    /// 容量
    var capacity = 0
}
