//
//  FileUploadItem.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/7.
//

import Foundation
import Alamofire

class FileUploadItem: BaseModel {
    /// 上传任务id
    lazy var id = UUID().uuidString
    
    /// 文件内容
    var data = Data()
    
    /// 上传请求
    var uploadRequest: UploadRequest?
    
    /// 文件名
    var filename = ""
    
    /// 上传路径
    var path = ""
    
    /// 文件上传状态
    var status: FileUploadStatus = .wait

    /// 文件hash
    var hash: String {
        return data.sha256
    }
    
    /// 文件大小
    var totalSize: Int {
        return data.count
    }
    
    /// 总分片数
    lazy var totalChunks = 1
    
    /// 是否分片上传
    lazy var isChunkUpload = false
    
    ///文件分片上传队列
    lazy var uploadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "FileItemUploadQueue"
        queue.qualityOfService = .background
        ///最大并发3 (最多同时3个分片同时上传)
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    /// 检查是否需要发送合并请求的锁
    lazy var checkCombineLock = DispatchSemaphore(value: 1)
    
    /// 检查上传进度的锁
    lazy var checkProgressLock = DispatchSemaphore(value: 1)
    
    /// 分片数组
    var subItems = [FileUploadSubItem]()
    
    /// 分片上传进度回调
    var progressCallback: ((_ percentage: CGFloat) -> ())?
    
    /// 分片上传成功回调
    var successCallback:((_ fileUploadSubItem: FileUploadItem) -> ())?
    
    /// 分片上传失败回调
    var errorCallback:((_ errorMsg: String) -> ())?

    /// 开始上传
    func start() {
        status = .uploading
        prepareForUpdate()
    }
    
    /// 重新开始上传
    func restart() {
        status = .uploading
        if totalChunks > 1 {
            subItems.forEach {
                $0.restart()
            }
        } else {
            uploadRequest?.resume()
        }
        
    }

    /// 暂停上传
    func suspend() {
        if (status == .uploading || status == .merging) && totalChunks > 1 {
            status = .suspend
            subItems.forEach {
                $0.suspend()
            }
        } else {
            uploadRequest?.suspend()
        }
    }

    
    
    private func prepareForUpdate() {
        /// 如果文件大小小于2mb直接上传
        if data.count < FileUploadManager.shared.uploadChunkSize {
            uploadDataToNetwork()
        } else { /// 否则分片上传
            /// 获取文件已上传的分块信息
            NetworkManager.shared.fileChunks(hash: hash) { [weak self] response in
                guard let self = self else { return }
                let chunkIndexes = response.chunks.map(\.id)
                self.createFileUploadSubItems(chunk_size: FileUploadManager.shared.uploadChunkSize, chunkIndexes: chunkIndexes)
                
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                self.status = .error
            }
        }
        
        

    }
    
    /// 创建上传文件需要上传的分片
    /// - Parameters:
    ///   - chunk_size: 分片大小
    ///   - chunkIndexes: 已经上传过的分片序号 1开始
    private func createFileUploadSubItems(chunk_size: Int, chunkIndexes: [Int]) {
        ///文件总大小
        let totalSize = data.count
        ///计算总分片数
        totalChunks = totalSize / chunk_size
        if totalChunks == 0 {
            totalChunks = 1
        } else {
            if totalSize % chunk_size > 0 {
                totalChunks += 1
            }
        }
        
        
        /// 需要上传的分片序号
        var needUploadChunkIndexes = [Int]()
        (1...totalChunks).forEach {
            if !chunkIndexes.contains($0) {
                needUploadChunkIndexes.append($0)
            }
        }
        
        /// 分片已全部上传完，进行合并
        if needUploadChunkIndexes.count  == 0 {
            combineFile()
        }

        ///创建上传分片item 注意index是从1开始
        needUploadChunkIndexes.forEach { [weak self] (index) in
            let subItem = FileUploadSubItem()
            subItem.filename = filename
            subItem.hash = hash
            subItem.path = path
            subItem.chunkNumber = index
            subItem.totalChunks = totalChunks
            subItem.totalSize = totalSize
       
            if (index - 1) * chunk_size + chunk_size > totalSize {
                subItem.data = data.subdata(in: ((index - 1) * chunk_size)..<data.count)
                subItem.chunkSize = data.count - ((index - 1) * chunk_size)
            } else {
                subItem.data = data.subdata(in: ((index - 1) * chunk_size)..<((index - 1) * chunk_size + chunk_size))
                subItem.chunkSize = chunk_size
            }
            
            /// 分片上传成功回调
            subItem.successCallback = { [weak self] subItem in
                self?.checkIsNeedCombine()
            }
            
            /// 分片上传进度回调
            subItem.progressCallback = { [weak self] uploadedCount in
                self?.calculateProgress()
            }
            
            /// 分片上传错误回调
            subItem.errorCallback = { [weak self] errorMsg in
                self?.checkIsNeedCombine()
            }
            
            subItems.append(subItem)
            
            /// 开始分片上传
            uploadQueue.addOperation {
                subItem.start()
            }
            
            
        }
        
        
    }
    
    
    /// 检查是否需要发送合并请求
    private func checkIsNeedCombine() {
        checkCombineLock.wait()
        defer {
            checkCombineLock.signal()
        }
        
        /// 未上传完成的分片数量
        let unfinishedSubItemsCount = subItems.filter { $0.status != .finish }.count
        
        /// 如果除了出错的分片都上传完了
        if subItems.filter({ $0.status == .finish }).count + subItems.filter({ $0.status == .error }).count == subItems.count && subItems.filter({ $0.status == .error }).count != 0 {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.errorCallback?("filename:\(self.filename),部分分片上错失败")
            }
            return
        }

        if unfinishedSubItemsCount > 0 {
            ///继续上传分片
            return
        } else {
            ///如果只有一片分片不需要合并
            if subItems.count == 1 {
                fileUploadLog("文件上传成功, filename:\(self.filename)")
                self.status = .finish
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.successCallback?(self)
                }
            } else {
                /// 分片都上传完了开始合并
                combineFile()
            }
            
        }

    }
    
    
    /// 合并文件
    private func combineFile() {
        /// 上传的token
        let header = HTTPHeader(name: "scope-token", value: AreaManager.shared.currentArea.scope_token)
        
        guard
            let baseUrl = AreaManager.shared.currentArea.sa_lan_address,
            let url = URL(string: "\(baseUrl)/api/plugin/wangpan/resources/\(path)\(self.filename)"),
            let totalSize = "\(totalSize)".data(using: .utf8),
            let totalChunks = "\(totalChunks)".data(using: .utf8),
            let action = "merge".data(using: .utf8),
            let hash = hash.data(using: .utf8)
        else {
            return
        }
        
        uploadRequest = AF.upload(multipartFormData: { [weak self] formData in
            guard let self = self else { return }
            formData.append(InputStream(data: self.data), withLength: UInt64(self.totalSize), name: "uploadfile", fileName: self.filename, mimeType: "application/octet-stream")
            formData.append(action, withName: "action")
            formData.append(totalSize, withName: "total_size")
            formData.append(totalChunks, withName: "total_chunks")
            formData.append(hash, withName: "hash")
        },
        to: url,
        method: .post,
        headers: HTTPHeaders([header]))
        .responseJSON(completionHandler: { [weak self] response in
            guard let self = self else { return }
            if let valueDict = response.value as? [String: Any],
               let fileInfoResponse = FileUploadInfoResponse.deserialize(from: valueDict) {
                /// 分片合并失败
                if fileInfoResponse.status != 0 {
                    fileUploadLog("chunks merge failed, filename:\(self.filename)")
                    fileUploadLog("reason: \(fileInfoResponse.reason)")
                    self.status = .error
                    self.errorCallback?(fileInfoResponse.reason)
                    return
                }

                /// 分片合并成功
                fileUploadLog("chunk merge successful, filename:\(self.filename)")
                self.status = .finish
                /// 文件上传成功回调
                self.successCallback?(self)

            } else {
                fileUploadLog("combile failed, filename:\(self.filename)")
                self.errorCallback?("unknown error")
            }
            
        })

    }

    /// 上传单个文件(小于2m)
    private func uploadDataToNetwork() {
        /// 上传的token
        let header = HTTPHeader(name: "scope-token", value: AreaManager.shared.currentArea.scope_token)
        
        guard
            let baseUrl = AreaManager.shared.currentArea.sa_lan_address,
            let url = URL(string: "http://\(baseUrl)/plugin/wangpan/resources/\(path)\(self.filename)"),
            let totalSize = "\(totalSize)".data(using: .utf8),
            let action = "upload".data(using: .utf8),
            let hash = hash.data(using: .utf8)
        else {
            return
        }
        
        uploadRequest = AF.upload(multipartFormData: { [weak self] formData in
            guard let self = self else { return }
            formData.append(InputStream(data: self.data), withLength: UInt64(self.totalSize), name: "uploadfile", fileName: self.filename, mimeType: "application/octet-stream")
            formData.append(action, withName: "action")
            formData.append(totalSize, withName: "total_size")
            formData.append(hash, withName: "hash")
        },
        to: url,
        method: .post,
        headers: HTTPHeaders([header]))
        .responseJSON(completionHandler: { [weak self] response in
            guard let self = self else { return }
            if let valueDict = response.value as? [String: Any],
               let fileInfoResponse = FileUploadInfoResponse.deserialize(from: valueDict) {
                /// 单个文件上传失败
                if fileInfoResponse.status != 0 {
                    fileUploadLog("single file failed to upload , filename:\(self.filename)")
                    fileUploadLog("reason: \(fileInfoResponse.reason)")
                    self.status = .error
                    self.errorCallback?(fileInfoResponse.reason)
                    return
                }

                fileUploadLog("single file uploaded successful, filename:\(self.filename)")
                self.status = .finish
                /// 文件上传成功回调
                self.successCallback?(self)

            } else {
                fileUploadLog("single file upload failed, filename:\(self.filename)")
                self.errorCallback?("unknown error")
                self.status = .error
            }
            
        })
        .uploadProgress(closure: { [weak self] progress in
            guard let self = self else { return }
            
            /// 分片上传进度回调
            let progressCount = Int(Double(self.totalSize) * progress.fractionCompleted)
            let percentage = CGFloat(progressCount) / CGFloat(self.totalSize)
            fileUploadLog("filename:\(self.filename), 已上传字节: \(progressCount) 百分比: \(percentage)")
            self.progressCallback?(percentage)
        })

    }

    /// 计算总上传进度
    /// - Parameter subItemProgress: 分片的上传回调回来的进度(已上传字节数)
    private func calculateProgress() {
        checkProgressLock.wait()
        defer {
            checkProgressLock.signal()
        }
        
        var progressCount = 0
        subItems.forEach {
            progressCount += $0.uploadedCount
        }
        
        let percentage = CGFloat(progressCount) / CGFloat(totalSize)
        
        fileUploadLog("filename:\(filename), 已上传字节: \(progressCount) 百分比: \(percentage)")
        ///文件上传百分比回调
        progressCallback?(percentage)
        
    }
    
}
