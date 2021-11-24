//
//  FileUploadManager.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/7.
//

import UIKit


enum FileUploadStatus: String {
    case wait
    case uploading
    case suspend
    case merging
    case finish
    case error
}

class FileUploadManager {
    /// 是否打印debug信息
    static var isDebugLog = true
    
    lazy var fileManager = FileManager.default

    /// 上传任务缓存文件的地址
    var cachePath: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("uploadCache").appendingPathComponent("upload.plist", isDirectory: false)
    }

    static let shared = FileUploadManager()
    
    private init() {

    }
    

    /// 最大同时上传任务数
    let maxUploadingCount = 2
    
    /// 每个分片的大小最多2m
    let uploadChunkSize = 2 * 1024 * 1024
    
    /// 正在上传的文件
    lazy var uploadFilesArray = [FileUploadItem]()
    
    /// 检查未上传文件的锁
    private lazy var checkUploadLock = DispatchSemaphore(value: 1)
    

    func setup() {
        if !fileManager.fileExists(atPath: cachePath.path) {
            try? fileManager.createDirectory(at: fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("uploadCache"), withIntermediateDirectories: true, attributes: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(totalCache), name: UIApplication.willResignActiveNotification, object: nil)

        guard
            let cacheData = try? Data(contentsOf: cachePath),
            let json = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cacheData) as? [String: Any],
            let cacheModel = CacheUploadListModel.deserialize(from: json)
        else {
            return
        }
        
        uploadFilesArray = cacheModel.uploadFilesArray
        
    }
}

extension FileUploadManager {
    
    /// 添加上传任务
    /// - Parameters:
    ///   - filename: 文件名
    ///   - data: 文件data
    ///   - path: 上传路径
    func upload(filename: String = "", data: Data, path: String) {
        let uploadItem = FileUploadItem()
        uploadItem.data = data
        uploadItem.path = path
        
        if filename == "" {
            uploadItem.filename = UUID().uuidString
        } else {
            uploadItem.filename = filename
        }
        
        /// 文件上传完成后回调
        uploadItem.successCallback = { [weak self] item in
            self?.checkUploadFile()
        }
        
        /// 文件上传出错回调
        uploadItem.errorCallback = { [weak self] errorMessage in
            self?.checkUploadFile()
        }
        
        ///加入到上传任务数组中
        uploadFilesArray.append(uploadItem)

        checkUploadFile()
        
    }
    
    /// 检查上传任务中等待上传的文件
    func checkUploadFile() {
        checkUploadLock.wait()
        defer {
            checkUploadLock.signal()
        }
        
        /// 等待上传的任务
        let waitItems = uploadFilesArray.filter { $0.status == .wait || $0.status == .suspend }.prefix(maxUploadingCount)
        
        
        /// 正在上传的任务数量
        let uploadingCount = uploadFilesArray
            .filter { $0.status == .uploading }
            .count
        
        /// 有等待上传的任务且正在上传的任务数不超过最大同时上传任务数
        if waitItems.count != 0 && uploadingCount < maxUploadingCount {
            waitItems.forEach {
                $0.start()
            }
        }
        
    }
    
    /// 开始所有上传任务
    func startAll() {
        checkUploadFile()
    }
    
    /// 暂停所有上传任务
    func suspendAll() {
        uploadFilesArray.filter { $0.status == .uploading }.forEach {
            $0.suspend()
        }
    }
    
    /// 缓存上传任务
    @objc
    func totalCache() {
        uploadFilesArray.forEach {
            if $0.status == .uploading {
                $0.suspend()
            }
        }
        
        let cacheModel = CacheUploadListModel()
        cacheModel.uploadFilesArray = uploadFilesArray

        
        if let jsonDict = cacheModel.toJSON() {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: jsonDict, requiringSecureCoding: false)
            
            do {
                try data?.write(to: cachePath.standardizedFileURL, options: .atomic)
            } catch let err {
                print(err)
            }
            
            
            fileUploadLog("缓存上传列表成功")
        }
    }
    
    
}

extension FileUploadManager {
    private class CacheUploadListModel: BaseModel {
        var uploadFilesArray = [FileUploadItem]()
    }
}



/// 打印debug信息
func fileUploadLog(_ items: Any..., file: String = #file, line: Int = #line) {
    if FileUploadManager.isDebugLog {
        let threadNum = (Thread.current.description as NSString).components(separatedBy: "{").last?.components(separatedBy: ",").first ?? ""
        let filename = file.components(separatedBy: "/").last ?? ""
        print("-------FileUploadManagerDebug-------")
        print("Thread: \(threadNum)")
        print("file:\(filename)")
        print("line:\(line)")
        print(items)
        print("------------------------------------")
    }
}
