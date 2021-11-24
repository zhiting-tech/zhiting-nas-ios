//
//  TransferModel.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/6/1.
//

import UIKit

enum FileType {
    case update
    case download
}

class TransferModel: BaseModel {
    
    //文件名称
    var file = FileModel()
    //文件地址
    var filePath = ""
    //文件总量
    var fileSize:CGFloat = 0.0
    //文件下载量
    var fileFinishSize:CGFloat = 0.0
    //文件速率
    var fileRate = ""
    //文件状态
    var fileState = 0
    //文件类型
    var fileType = FileType.update

}
