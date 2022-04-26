//
//  GoFileManager.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/9/9.
//

import UIKit
import Foundation
import Combine
import Gonet
import SwiftUI


class GoFileManager {
    /// 文件存储目录
    let goCachePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true).absoluteString.components(separatedBy: "file://").last
    
    /// 文件存储目录url
    let goCacheUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true)
    
    static let shared = GoFileManager()
    
    /// 操作队列
    lazy var goOperationQueue = DispatchQueue(label: "zhiting.goFileQuueue", qos: .default, attributes: .concurrent)
    
    /// 检查下载数量锁
    lazy var checkDownloadLock = DispatchSemaphore(value: 1)
    
    /// 检查上传数量锁
    lazy var checkUploadLock = DispatchSemaphore(value: 1)
    
    //gonet下载管理对象
    lazy var downloadManager = GonetNewDownloadManager(AreaManager.shared.currentArea.sa_lan_address, goCachePath, "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}")
    
    //gonet上传管理对象回调
    let uploadCallbackObj = UploadCallbackObj()
    
    //gonet上传管理对象
    lazy var uploadManager = GonetNewUploadManager(AreaManager.shared.currentArea.sa_lan_address, goCachePath, "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", 2)
    
    lazy var cancellables = Set<AnyCancellable>()
    private init() {
        //        NotificationCenter.default.addObserver(self, selector: #selector(pauseAll), name: UIApplication.willTerminateNotification, object: nil)
        
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
    
    var isSetup: Bool {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true), !FileManager.default.fileExists(atPath: url.path) {
            return false
        }
        
        return true
    }

    /// 初始化设置
    func setup() {
        guard
            let dst = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true),
            let src = Bundle.main.url(forResource: "mobile", withExtension: "db")
        else {
            return
        }
        
        FileManager.default.clearTmpDirectory()
        
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("goFileItems", isDirectory: true), !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: [.appendOnly:false])
            
            
            do {
                let data = try Data(contentsOf: src)
                FileManager.default.createFile(atPath: dst.appendingPathComponent("mobile.db").absoluteString, contents: nil, attributes: [.appendOnly: false])
                try data.write(to: dst.appendingPathComponent("mobile.db"))
                
                print("GoFileManager setup success.")
            } catch (let error) {
                print(error.localizedDescription)
            }
            
        }

        
    }
    
    func gomobileRun(){
        
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.downloadManager?.run("{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}")
        }
        
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.uploadManager?.run("{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", callback: self.uploadCallbackObj)
            
        }
    }
    
    // MARK: - Download
    
    /// 通过下载路径获取文件夹的密码
    /// - Parameter urlStr: 文件夹或文件夹路径
    /// - Parameter area: 家庭
    /// - Returns: 密码(无缓存 则为“”）
    func getDirDownloadPwd(area: Area = AreaManager.shared.currentArea, by urlStr: String) -> String {
        guard let path = urlStr.components(separatedBy: "/wangpan/api/download").last else { return "" }
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
        return "/wangpan/api/download\(path)"
    }
    
    /// 下载任务
    /// - Parameters:
    ///   - url: 任务url
    func download(path: String, thumbnailUrl: String) {
        
        /// 文件夹密码
        let pwd = self.getDirDownloadPwd(by: path)
        
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            let id = AreaManager.shared.currentArea.sa_user_id
            let areaID = Int(AreaManager.shared.currentArea.id)
            self.downloadManager?.iosCreateFileDownloader(self.downloadUrlFromPath(path), thumbnailUrl: thumbnailUrl, headerStr: "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", pwd: pwd, userId: id, areaId: areaID ?? 0)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            guard let self = self else { return }
            /// 发布者发布消息
            self.taskCountChangePublisher.send(())
        }
        
        
    }
    
    /// 下载文件夹任务
    /// - Parameters:
    ///   - url: 任务url
    /// - Description:
    /// 传参参考
    /// findApi  "http://192.168.0.133:8080/wangpan/api/resources/*path"
    /// downloadApi  "http://192.168.0.133:8080/wangpan/api/download/*path"
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
            let id = AreaManager.shared.currentArea.sa_user_id
            let areaID = Int(AreaManager.shared.currentArea.id)
            
            self.downloadManager?.iosCreateDirDownloader(findApi, downloadApi: downloadApi, downloadPath: filePath, headerStr: "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", pwd: pwd, userId: id, areaId: areaID ?? 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            guard let self = self else {return}
            /// 发布者发布消息
            self.taskCountChangePublisher.send(())
        }
        
    }
    
    /// 获取下载任务列表
    /// - Returns: 下载任务列表
    func getDownloadList() -> [GoFileDownloadInfoModel] {
        
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        
        guard let downloads = GoDownloadListResponse.deserialize(from: GonetGetDownloadList(goCachePath, "file", 0, id, areaID ?? 0)) else {
            return [GoFileDownloadInfoModel]()
        }
        return downloads.DownloadList
        
    }
    
    /// 获取文件夹下载任务里面文件的下载状态信息
    /// - Returns: 文件夹里的文件任务信息
    func getDownloadDirInfo(by task: GoFileDownloadInfoModel) -> [GoFileDownloadInfoModel] {
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        
        guard let downloads = GoDownloadListResponse.deserialize(from: GonetGetDownloadList(goCachePath, "dir", task.id, id, areaID ?? 0)) else {
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
    func deleteDownloadTask(by task: GoFileDownloadInfoModel) {
        
        downloadManager?.delete(task.id)
        
    }
    
    /// 通过id和scopetoken继续下载任务
    /// - Parameters:
    ///   - id: 任务id
    ///   - scopeToken: scopeToken
    func resumeDownloadTask(by task: GoFileDownloadInfoModel, type: String) {
        
        self.downloadManager?.start(task.id)
        
    }
    
    //继续所有下载任务
    func startAllDownLoadTask(){
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            self.downloadManager?.startAll(id, areaId: areaID ?? 0)
        }
    }
    //暂停所有下载任务
    func stopAllDownLoadTask(){
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            self.downloadManager?.stopAll(id, areaId: areaID ?? 0)
        }
    }
    //清楚所有下载完成记录
    func deleteAllDownloadRecode(){
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        GonetDelAllDownloadFinishRecode(id, areaID ?? 0, goCachePath)
    }
    
    //获取所有进行中任务的数量总和
    func getAllGoingTaskCount() -> String {
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        return GonetGetDownloadUploadAllGoingTaskNum(id, areaID ?? 0, goCachePath)
    }
    
    // MARK: - Upload
    
    /// 继续所有上传任务
    /// - Parameter isBackup: 0上传任务 1备份任务
    func startAllUploadTask(isBackup: Int){
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            self.uploadManager?.startAll(id, areaId: areaID ?? 0, isBackup: isBackup)
        }
        
    }
    
    /// 暂停所有上传任务
    /// - Parameter isBackup: 0上传任务 1备份任务
    func stopAllUploadTask(isBackup: Int){
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            self.uploadManager?.stopAll(id, areaId: areaID ?? 0, isBackup: isBackup)
        }
    }
    
    
    /// 清楚所有上传完成记录
    /// - Parameter isBackup: isBackup: 0上传任务 1备份任务
    func deleteAllUploadRecord(isBackup: Int){
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        GonetDelAllUploadFinishRecode(id, areaID ?? 0, goCachePath, isBackup)
    }
    
    
    
    /// 通过上传路径获取文件夹的密码
    /// - Parameter urlStr: 文件夹或文件夹路径
    /// - Parameter area: 家庭
    /// - Returns: 密码(无缓存 则为“”）
    func getDirUploadPwd(area: Area = AreaManager.shared.currentArea, by urlStr: String) -> String {
        guard let path = urlStr.components(separatedBy: "/wangpan/api/resources").last else { return "" }
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
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        
        guard let uploads = GoUploadListResponse.deserialize(from: GonetGetUploadList(goCachePath, id, areaID ?? 0)) else {
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
            let id = AreaManager.shared.currentArea.sa_user_id
            let areaID = Int(AreaManager.shared.currentArea.id)
            
            let urlString = urlPath + filename
            self.uploadManager?.iosCreateFileUploader(urlString, filePath: filePath, fileName: filename, headerStr: "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", pwd: pwd, userId: id, areaId: areaID ?? 0, isBackup: 0, identification: "")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            guard let self = self else {return}
            /// 发布者发布消息
            self.taskCountChangePublisher.send(())
        }
        
        
    }
    
    
    /// 获取备份列表
    /// - Returns: (进行中任务,成功任务,失败任务)
    func getBackupList() -> ([GoFileUploadInfoModel], [GoFileUploadInfoModel], [GoFileUploadInfoModel], Int) {
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id) ?? 0
        
        guard let backups = GoBackupListResponse.deserialize(from: uploadManager?.getUploadBackupList(goCachePath, userId: id, areaId: areaID)) else {
            return ([], [], [], 0)
        }
        return (backups.UploadOnGoingList, backups.UploadOnSuccessList, backups.UploadOnFailList, backups.OnGoingNum)
    }
    
    /// 重试全部失败的备份任务
    func retryAllBackups() {
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id) ?? 0
        uploadManager?.allFailReTry(id, areaId: areaID)
    }
    
    /// 关闭图片备份
    func closePhotoBackups() {
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id) ?? 0
        uploadManager?.iosCloseFileBackup(id, areaId: areaID, ty: 1)
        
    }
    
    /// 关闭视频备份
    func closeVideoBackups() {
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id) ?? 0
        uploadManager?.iosCloseFileBackup(id, areaId: areaID, ty: 2)
        
    }
    
    /// 获取已上传数据的唯一标识
    /// - Parameter complete: 标识model
    func getAlreadyUploadDatas(complete:((IdentificationModel)->())?){
        goOperationQueue.async {
            let modelJson = GonetGetIdentifications("{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", "iPhone")

            if let model = ApiServiceResponseModel<IdentificationModel>.deserialize(from: modelJson) {
                complete?(model.data)
            }
        }
    }
    
    
    /// 上传备份图片或视频
    /// - Parameters:
    ///   - urlPath: 文件位置(图片、视频为绝对路径  其他文件为沙盒tmp下相对路径)
    ///   - identification: 唯一标识
    ///   - phoneName: 设备名称
    ///   - isPic: 是否图片
    func uploadMediaData(urlPath: String, identification: String, phoneName: String, isPic: Bool, folderId: Int) {
        
        var filePath = urlPath
        if let path = urlPath.components(separatedBy: "file://").last {
            filePath = path
        }
        goOperationQueue.async { [weak self] in
            guard let self = self else { return }
            let id = AreaManager.shared.currentArea.sa_user_id
            let areaID = Int(AreaManager.shared.currentArea.id)
            
            self.uploadManager?.iosAddUploadFile(filePath, identification: identification, header: "{\"scope-token\":\"\(AreaManager.shared.currentArea.scope_token)\"}", phoneName: phoneName, userId: id, areaId: areaID ?? 0, folderId: folderId)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            guard let self = self else {return}
            /// 发布者发布消息
            self.taskCountChangePublisher.send(())
        }
        
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
        let id = AreaManager.shared.currentArea.sa_user_id
        let areaID = Int(AreaManager.shared.currentArea.id)
        
        guard let response = GoTaskNumResponse.deserialize(from: GonetGetOnGoingTaskNum(goCachePath, id, areaID ?? 0)) else {
            return 0
        }
        
        let (_, _, _, onGoingNum) = GoFileManager.shared.getBackupList()
        return response.AllNum + onGoingNum
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

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { [unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}

class IdentificationModel: BaseModel {
    var identifications = [String]()
    var private_file_id = 0
}

class UploadCallbackObj: NSObject, GonetUploadCallbackProtocol {
    func sendFailResult(_ p0: String?) {
//        print("UploadCallbackObj: \(p0 ?? "")")
    }
    
    func sendFinishBackupTaskFileInfo(_ p0: String?) {
//        print("UploadCallbackObj: \(p0 ?? "")")
    }
}
