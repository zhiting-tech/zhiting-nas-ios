//
//  DownloadedDocumentManager.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/24.
//

import UIKit

class DownloadedDocumentManager {
    /// 文件存储目录url
    let goCacheUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true)
    
    lazy var fileManager = FileManager.default

    static let shared = DownloadedDocumentManager()
    
    private init() {}

}

extension DownloadedDocumentManager {
    /// 获取路径下文件夹和文件
    /// - Parameter path: 路径
    /// - Returns: FileModel数组
    func getFileList(by path: String) -> [FileModel] {
        guard let cacheUrl = goCacheUrl else {
            return []
        }
        
        if !fileManager.fileExists(atPath: cacheUrl.appendingPathComponent(path, isDirectory: true).path) { //目录不存在
            return []
        }
        
        guard let files = try? fileManager.contentsOfDirectory(atPath: cacheUrl.appendingPathComponent(path, isDirectory: true).path) else {
            return []
        }
        
        var fileModels = [FileModel]()

        files.forEach { fileName in
            if let attributes = try? fileManager.attributesOfItem(atPath: cacheUrl.appendingPathComponent(path, isDirectory: true).appendingPathComponent(fileName).path) {
                let fileModel = FileModel()
                /// 文件名
                fileModel.name = fileName
                
                /// 修改时间
                if let modTime = attributes[FileAttributeKey.modificationDate] as? Date {
                    fileModel.mod_time = Int(modTime.timeIntervalSince1970)
                }
                
                /// 文件大小
                if let size = attributes[FileAttributeKey.size] as? Int {
                    fileModel.size = size
                }
                
                /// 文件类型
                if let fileType = attributes[FileAttributeKey.type] as? String {
                    if fileType == "NSFileTypeRegular" {
                        fileModel.type = 1
                    } else {
                        fileModel.type = 0
                    }
                }

                fileModels.append(fileModel)
            }
        }

        return fileModels
    }
    
    
    /// 删除文件
    /// - Parameter url: 要删除文件的url
    func deleteFile(url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    /// 重命名文件
    /// - Parameters:
    ///   - url: 文件所在目录url
    ///   - name: 文件名
    ///   - newName: 修改后的文件名
    func renameFile(url: URL, name: String, newName: String) throws {
        try fileManager.moveItem(at: url.appendingPathComponent(name), to: url.appendingPathComponent(newName))

        
    }
}
