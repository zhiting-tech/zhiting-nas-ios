//
//  FileUploadSubItem.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/7.
//

import Foundation
import Alamofire

class FileUploadSubItem: BaseModel {
    
    /// 分片内容
    var data = Data()
    
    /// 分片序号
    var chunkNumber = 1
    
    /// 总分片数
    var totalChunks = 1
    
    /// 上传path
    var path = ""
    
    /// 文件名
    var filename = ""
    
    var totalSize = 0

    /// 分片上传状态
    var status: FileUploadStatus = .wait
    
    /// 文件hash
    var hash = ""
    
    /// 当前分片大小
    var size: Int {
        return data.count
    }
    
    /// 分片大小
    var chunkSize: Int = 0
    
    /// 已上传字节数
    var uploadedCount = 0
    
    /// 分片上传请求
    var uploadRequest: UploadRequest?
    
    /// 分片上传进度回调
    var progressCallback: ((_ uploadedCount: Int) -> ())?
    
    /// 分片上传成功回调
    var successCallback:((_ fileUploadSubItem: FileUploadSubItem) -> ())?
    
    /// 分片上传失败回调
    var errorCallback:((_ errorMsg: String) -> ())?
    
    required init() {
        
    }
    
    /// 开始上传
    func start() {
        status = .uploading
        uploadDataToNetwork()
    }

    /// 暂停上传
    func suspend() {
        if status == .uploading {
            status = .suspend
            uploadRequest?.suspend()
        }
        
    }
    
    /// 重新开始上传
    func restart() {
        if status == .suspend {
            status = .uploading
            uploadRequest?.resume()
        }
    }
    
    /// 上传分片
    private func uploadDataToNetwork() {
        /// 上传的token
        let header = HTTPHeader(name: "scope-token", value: AreaManager.shared.currentArea.scope_token)
        
        guard
            let baseUrl = AreaManager.shared.currentArea.sa_lan_address,
            let url = URL(string: "\(baseUrl)/api/plugin/wangpan/resources/\(path)\(filename)"),
            let chunkNumber = "\(chunkNumber)".data(using: .utf8),
            let totalChunks = "\(totalChunks)".data(using: .utf8),
            let chunkSize = "\(size)".data(using: .utf8),
            let totalSize = "\(totalSize)".data(using: .utf8),
            let hash = self.hash.data(using: .utf8),
            let action = "chunk".data(using: .utf8)
        else {
            return
        }
        
        uploadRequest = AF.upload(multipartFormData: { [weak self] formData in
            guard let self = self else { return }
            formData.append(InputStream(data: self.data), withLength: UInt64(self.size), name: "uploadfile", fileName: self.filename, mimeType: "application/octet-stream")
            formData.append(chunkNumber, withName: "chunk_number")
            formData.append(totalChunks, withName: "total_chunks")
            formData.append(chunkSize, withName: "chunk_size")
            formData.append(self.data, withName: "current_chunk_size")
            formData.append(hash, withName: "hash")
            formData.append(totalSize, withName: "total_size")
            formData.append(action, withName: "action")
            
        },
        to: url,
        method: .post,
        headers: HTTPHeaders([header]))
        .responseJSON(completionHandler: { [weak self] response in
            guard let self = self else { return }
            if let valueDict = response.value as? [String: Any],
               let fileInfoResponse = FileUploadInfoResponse.deserialize(from: valueDict) {
                /// 分片上传失败
                if fileInfoResponse.status != 0 {
                    fileUploadLog("chunk upload failed, filename:\(self.filename), chunk_number:\(self.chunkNumber)")
                    fileUploadLog("reason: \(fileInfoResponse.reason)")
                    self.status = .error
                    /// 分片上传失败回调
                    self.errorCallback?(fileInfoResponse.reason)
                    return
                }

                /// 分片上传成功
                fileUploadLog("chunk upload successful, filename:\(self.filename), chunk_number:\(self.chunkNumber)")
                self.status = .finish
                /// 分片上传成功回调
                self.successCallback?(self)

            } else {
                self.status = .error
                fileUploadLog("chunk upload failed, filename:\(self.filename), chunk_number:\(self.chunkNumber)")
                self.errorCallback?("unknown error")
            }
            
        })
        .uploadProgress(closure: { [weak self] progress in
            guard let self = self else { return }
            
            /// 分片上传进度回调
            self.uploadedCount = Int(Double(self.size) * progress.fractionCompleted)
            self.progressCallback?(self.uploadedCount)
        })
        

    }
}
