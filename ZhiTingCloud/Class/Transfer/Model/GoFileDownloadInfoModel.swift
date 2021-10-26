//
//  FileDownloadInfoModel.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/17.
//

import Foundation
import UIKit

class GoFileDownloadInfoModel: BaseModel {
    var id = 0
    /// 下载地址
    var url = ""
    /// 文件大小
    var size = 0
    /// 文件名字
    var name = ""
    /// 下载速度
    var speeds = 0
    /// 下载状态 0未开始 1下载中 2已暂停 3已完成 4下载失败
    var status = 0
    /// 已下载大小
    var downloaded = 0
    
    /// dir: 文件夹 file: 文件
    var type = "file"
    
    /// 任务开始时间
    var create_time: Int = 0
    
    /// 进度
    var percentage: Float {
        if size == 0 {
            return 0
        }

        return Float(downloaded) / Float(size)
    }

}

class GoDownloadListResponse: BaseModel {
    var DownloadList = [GoFileDownloadInfoModel]()
}

class GoTaskNumResponse: BaseModel {
    var FileUploadNum = 0
    var FileDownloadNum = 0
    var AllNum = 0
}


class GoFileUploadInfoModel: BaseModel {
    var id = 0
    /// 上传地址
    var url = ""
    /// 文件大小
    var size = 0
    /// 文件名字
    var name = ""
    /// 上传速度
    var speeds = 0
    /// 上传状态 0未开始 1上传中 2已暂停 3已完成 4上传失败 5生成临时文件中
    var status = 0
    /// 已上传大小
    var upload = 0
    /// 暂存文件名
    var tmp_name = ""
    /// 文件hash
    var hash = ""
    /// 任务开始时间
    var create_time: Int = 0
    
    /// 进度
    var percentage: Float {
        if size == 0 {
            return 0
        }
        return Float(upload) / Float(size)
    }

}

class GoUploadListResponse: BaseModel {
    var UploadList = [GoFileUploadInfoModel]()
}
