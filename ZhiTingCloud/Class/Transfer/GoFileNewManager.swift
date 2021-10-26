//
//  GoFileNewManager.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/9/9.
//

import UIKit
import Foundation
import Combine
import Gonet


class GoFileNewManager {
    /// 文件存储目录
    let goCachePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true).absoluteString.components(separatedBy: "file://").last
    
    /// 文件存储目录url
    let goCacheUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true)
    
    static let shared = GoFileNewManager()
    
    /// 操作队列
    lazy var goOperationQueue = DispatchQueue(label: "zhiting.goFileQuueue", qos: .default, attributes: .concurrent)
    
    /// 检查下载数量锁
    lazy var checkDownloadLock = DispatchSemaphore(value: 1)
    
    /// 检查上传数量锁
    lazy var checkUploadLock = DispatchSemaphore(value: 1)
    
    //gonet下载管理对象
    lazy var downloadManager = GonetNewDownloadManager(AreaManager.shared.currentArea.sa_lan_address, goCachePath, "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}")
    //gonet上传管理对象
    lazy var uploadManager = GonetNewUploadManager(AreaManager.shared.currentArea.sa_lan_address, goCachePath, "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}")
    
    lazy var cancellables = Set<AnyCancellable>()
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseAll), name: UIApplication.willResignActiveNotification, object: nil)
        
        NetworkStateManager.shared.networkStatusPublisher.sink {[weak self] state in
            guard let self = self else {return}
            switch state {
            case .noNetwork:
                self.noNetSate()
            
            default :
                break
            }
        }
        .store(in: &cancellables)
    }
        
    /// 任务完成发布者
    let taskCountChangePublisher = PassthroughSubject<Void,Never>()

    /// 初始化设置
    func setup() {
        guard
            let dst = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true),
            let src = Bundle.main.url(forResource: "mobile", withExtension: "db")
        else {
            return
        }
        
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true), !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: [:])
            
            
            do {
                let data = try Data(contentsOf: src)
                FileManager.default.createFile(atPath: dst.appendingPathComponent("mobile.db").absoluteString, contents: nil, attributes: [.appendOnly: false])
                try data.write(to: dst.appendingPathComponent("mobile.db"))
                
                print("GoFileManager setup success.")
            } catch (let error) {
                print(error.localizedDescription)
            }

        }
        
        //初始化临时文件
        if FileManager.default.fileExists(atPath: dst.appendingPathComponent("mobile.db").path) {
            let downloadItems = getDownloadList().filter({ $0.status == 1 })
            downloadItems.forEach {
                pauseDownloadTask(by: $0, type: $0.type)
            }

            let uploadItems = getUploadList().filter({ $0.status == 1 })
            uploadItems.forEach {
                deleteUploadTask(by: $0)
            }
            
            /// 重新打开app时移除正在生成临时文件的上传任务
            let needDeleteuploadItems = getUploadList().filter({ $0.status == 5 })
            needDeleteuploadItems.forEach {
                pauseUploadTask(by: $0)
            }
                        
            return
        }
    
    }
    
    func gomobileRun(){
        
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.downloadManager?.run("{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}")
        }
        
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.uploadManager?.run("{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}")

        }
    }
    
    // MARK: - Download
    
    /// 通过下载路径获取文件夹的密码
    /// - Parameter urlStr: 文件夹或文件夹路径
    /// - Parameter area: 家庭
    /// - Returns: 密码(无缓存 则为“”）
    func getDirDownloadPwd(area: Area = AreaManager.shared.currentArea, by urlStr: String) -> String {
        guard let path = urlStr.components(separatedBy: "/wangpan/download").last else { return "" }
        let pathComponents = path.components(separatedBy: "/").filter({ $0 != "" })
        if pathComponents.count >= 2 {
            let rootPath = "/" + pathComponents[0] + "/" + pathComponents[1]
            let key = area.scope_token + rootPath
            let pwdJsonStr = UserDefaults.standard.value(forKey: key) as? String ?? ""
            let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
            return pwdModel?.password ?? ""
        } else {
            return ""
        }
    }

    //通过文件Path获取下载URL
    func downloadUrlFromPath(_ path: String) -> String {
        return "/plugin/wangpan/download\(path)"
    }
    
    /// 下载任务
    /// - Parameters:
    ///   - url: 任务url
    func download(path: String) {
        
            /// 文件夹密码
            let pwd = self.getDirDownloadPwd(by: path)

        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            
        self.downloadManager?.createFileDownloader(self.downloadUrlFromPath(path), headerStr: "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", pwd: pwd)
            
        }
            self.taskCountChangePublisher.send(())
        
    }
    
    /// 下载文件夹任务
    /// - Parameters:
    ///   - url: 任务url
    /// - Description:
    /// 传参参考
    /// findApi  "http://192.168.0.133:8080/api/plugin/wangpan/resources/*path"
    /// downloadApi  "http://192.168.0.133:8080/api/plugin/wangpan/download/*path"
    /// filePath  "/1/ceshi"
    /// path  "./"
    /// headerStr `{"scope-token" :  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MjY0MjI5MDUsInNhX2lkIjoidGVzdC1zYSIsInNjb3BlcyI6InVzZXIsYXJlYSIsInVpZCI6MX0 .YBQuESRnxp7aMozhzR3PxpS3K8FY1U-7sEGlD1KvwC0"}`
    func downloadDir(requestUrl: String, filePath: String) {
        let findApi = "\(requestUrl)/resources/*path"
        let downloadApi = "\(requestUrl)/download/*path"
        
        /// 文件夹密码
        let pwd = getDirDownloadPwd(by: filePath)
            
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            self.downloadManager?.createDirDownloader(findApi, downloadApi: downloadApi, downloadPath: filePath, headerStr: "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", pwd: pwd)
        }
            self.taskCountChangePublisher.send(())
                    
    }
    
    /// 获取下载任务列表
    /// - Returns: 下载任务列表
    func getDownloadList() -> [GoFileDownloadInfoModel] {
        
        guard let downloads = GoDownloadListResponse.deserialize(from: GonetGetDownloadList(goCachePath, "file", 0)) else {
            return [GoFileDownloadInfoModel]()
        }
        return downloads.DownloadList

    }
    
    /// 获取文件夹下载任务里面文件的下载状态信息
    /// - Returns: 文件夹里的文件任务信息
    func getDownloadDirInfo(by task: GoFileDownloadInfoModel) -> [GoFileDownloadInfoModel] {
        guard let downloads = GoDownloadListResponse.deserialize(from: GonetGetDownloadList(goCachePath, "dir", task.id)) else {
            return [GoFileDownloadInfoModel]()
        }
        return downloads.DownloadList
    }
    

    /// 通过id和scopetoken暂停下载任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    func pauseDownloadTask(by task: GoFileDownloadInfoModel, type: String) {
        downloadManager?.stop(task.id)
    }

    /// 通过id和scopetoken删除下载任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    func deleteDownloadTask(by task: GoFileDownloadInfoModel, type: String) {
        
        downloadManager?.delete(task.id)

    }
    
    /// 通过id和scopetoken继续下载任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    func resumeDownloadTask(by task: GoFileDownloadInfoModel, type: String) {

            self.downloadManager?.start(task.id)

    }
    
    // MARK: - Upload
    
    /// 通过上传路径获取文件夹的密码
    /// - Parameter urlStr: 文件夹或文件夹路径
    /// - Parameter area: 家庭
    /// - Returns: 密码(无缓存 则为“”）
    func getDirUploadPwd(area: Area = AreaManager.shared.currentArea, by urlStr: String) -> String {
        guard let path = urlStr.components(separatedBy: "/wangpan/resources").last else { return "" }
        let pathComponents = path.components(separatedBy: "/").filter({ $0 != "" })
        if pathComponents.count >= 2 {
            let rootPath = "/" + pathComponents[0] + "/" + pathComponents[1]
            let key = area.scope_token + rootPath
            let pwdJsonStr = UserDefaults.standard.value(forKey: key) as? String ?? ""
            let pwdModel = PasswordModel.deserialize(from: pwdJsonStr)
            return pwdModel?.password ?? ""
        } else {
            return ""
        }
    }

    /// 获取上传列表
    /// - Returns: 上传列表
    func getUploadList() -> [GoFileUploadInfoModel] {
        guard let uploads = GoUploadListResponse.deserialize(from: GonetGetUploadList(goCachePath)) else {
            return [GoFileUploadInfoModel]()
        }
        return uploads.UploadList
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - urlPath: 上传地址
    ///   - filename: 文件名
    ///   - tmpPath: 文件位置(图片、视频为绝对路径  其他文件为沙盒tmp下相对路径)
    ///   - scopeToken: scopeToken
    func upload(urlPath: String, filename: String, tmpPath: String) {

            var filePath = tmpPath
            if let path = tmpPath.components(separatedBy: "file://").last {
                filePath = path
            }
            let pwd = self.getDirUploadPwd(by: urlPath)
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            self.uploadManager?.createFileUploader("\(urlPath)\(filename)", filePath: filePath, fileName: filename, headerStr: "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", pwd: pwd)
        }
        self.taskCountChangePublisher.send(())
            
            
    }
    
    /// 通过id和scopetoken获取上传任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    /// - Returns: 下载任务
    func getUploadTask(by task: GoFileUploadInfoModel) -> GonetFileUploader? {
        let scopeToken = AreaManager.shared.currentArea.scope_token

        let uploader = GonetGetUploaderById(task.id, goCachePath, "{\"scope-token\":\"\(scopeToken)\"}")
        return uploader
    }
    
    
    /// 通过id和scopetoken暂停上传任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    func pauseUploadTask(by task: GoFileUploadInfoModel) {
        uploadManager?.stop(task.id)
    }

    /// 通过id和scopetoken删除上传任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    func deleteUploadTask(by task: GoFileUploadInfoModel) {
        uploadManager?.delete(task.id)
    }
    
    /// 通过id和scopetoken继续上传任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    func resumeUploadTask(by task: GoFileUploadInfoModel) {
        uploadManager?.start(task.id)
    }

    /// 通过id暂停下载任务
    /// - Parameters:
    ///   - id: 任务id
    func pauseDownloadTask(by task: GoFileDownloadInfoModel) {
        downloadManager?.stop(task.id)
    }
    
    /// 切换host
    /// - Parameters:
    ///   - host：服务器地址
    func updateHost(host: String) {
        downloadManager?.changeHost(host)
        uploadManager?.changeHost(host)
    }
    
    /// 退出APP
    /// - Parameters:
    ///   - id: 任务id
    func quitApp() {
        downloadManager?.quitAPP()
        uploadManager?.quitAPP()
    }
    

    private func getDownloadingCount() -> Int {
        checkDownloadLock.wait()
        let count = getDownloadList().filter({ $0.status == 1 }).count
        checkDownloadLock.signal()
        return count
    }
    
    /// 获取正在上传的任务的数量
    /// - Returns: int
    private func getUploadingCount() -> Int {
        checkUploadLock.wait()
        let count = getUploadList().filter({ $0.status == 1 || $0.status == 5 }).count
        checkUploadLock.signal()
        return count
    }

    /// 获取正在进行的任务的总数量
    /// - Returns: int
    func getTotalonGoingCount() -> Int {
        guard let response = GoTaskNumResponse.deserialize(from: GonetGetOnGoingTaskNum(goCachePath)) else {
            return 0
        }
        return response.AllNum
    }

    
    @objc
    private func pauseAll() {

        self.quitApp()
    }
    
    private func noNetSate(){
        self.downloadManager?.networkNil()
        self.uploadManager?.networkNil()
    }

}


class GoCallback:NSObject, GonetCallbackProtocol {
    var callback: (() -> ())?

    func sendResult(_ json: String?) {
        callback?()
    }
}
