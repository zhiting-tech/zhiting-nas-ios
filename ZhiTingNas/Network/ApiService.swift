//
//  ApiService.swift
//  ZhiTingNas
//
//  Created by iMac on 2021/6/2.
//

import Moya
import HandyJSON

/// if print the debug info
fileprivate let printDebugInfo = true

/// 网络请求分类
enum ApiService {
    case example
    /// 创建目录
    case createDirectory(area: Area, path: String, name: String, pwd: String = "")
    /// 删除文件/目录
    case deleteFile(area: Area, paths: [String])
    /// 文件/目录重命名
    case renameFile(area: Area, path: String, name: String)
    /// 获取文件已上传的分块信息
    case fileChunks(area: Area, hash: String)
    /// 目录下的文件/子目录列表
    case fileList(area: Area, path: String, type:Int, page: Int = 1, page_size: Int = 30, pwd: String = "")
    /// SA成员列表
    case userList(area: Area)
    /// SA用户详情
    case userDetail(area: Area, id: Int)
    ///获取别人共享给我的目录列表
    case shareFileList(area: Area, page: Int = 1, page_size: Int = 30)
    ///共享目录
    case shareFiles(area: Area, paths:[String], usersId:[Int], read: Bool, write: Bool, delete: Bool, from_user: String)
    ///共享/移动文件/目录
    /*
     sources: 源路径列表
     action: 拷贝、移动 mock: copy|move
     destination: 目标目录的完整路径
    */
    case moveFiles(area: Area, sources:[String], action:String, destination_pwd: String = "", destination:String)

    /// 文件夹列表
    case folderList(area: Area, page: Int, pageSize: Int)
    
    /// 文件夹详情
    case folderDetail(area: Area, id: Int)
    
    /// 创建文件夹
    case createFolder(area: Area, name: String, pool_name: String, partition_name: String, is_encrypt: Int, pwd: String, confirm_pwd: String, mode: FolderModel.FolderMode, auth: [User])
    
    /// 编辑文件夹
    case editFolder(area: Area, id: Int, name: String, pool_name: String, partition_name: String, is_encrypt: Int, mode: FolderModel.FolderMode, auth: [User])
    
    /// 修改文件夹密码
    case editFolderPwd(area: Area, id: Int, oldPwd: String, newPwd: String, confrimPwd: String)
    
    /// 删除文件夹
    case deleteFolder(area: Area, id: Int)
    
    /// 解密文件夹
    case decryptFolder(area: Area, name: String, password: String)
    
    /// 闲置硬盘列表
    case hardDiskList(area: Area)
    
    /// 添加闲置硬盘到存储池
    case addDiskToPool(area: Area, pool_name: String, disk_name: String)
    
    /// 存储池列表
    case storagePoolList(area: Area, page: Int, pageSize: Int)
    
    /// 存储池详情
    case storagePoolDetail(area: Area, name: String)
    
    /// 编辑存储池
    case editStoragePool(area: Area, name: String, new_name: String)
    
    /// 删除存储池
    case deleteStoragePool(area: Area, name: String)
    
    /// 添加存储池
    case addStoragePool(area: Area, name: String, disk_name: String)
    
    /// 编辑存储池分区
    case editPartition(area: Area, name:String, new_name: String, pool_name: String, capacity:Float, unit:String)
    
    /// 删除存储池分区
    case deletePartition(area: Area, name:String, pool_name: String)
    
    /// 添加存储池分区
    case addPartition(area: Area, name: String, capacity: Float, unit:String, pool_name:String)
    
    /// 文件夹设置
    case folderSettings(area: Area)
    
    /// 修改文件夹设置
    case editFolderSettings(area: Area, pool_name: String, partition_name: String, is_auto_del: Bool)
    
    /// 重新开始异步任务
    case restartAsyncTask(area: Area, task_id: String)
    
    /// 删除异步任务
    case deleteAsyncTask(area: Area, task_id: String)
    
    //获取数据通道
    case temporaryIP(area: Area, scheme: String = "http")

}


extension ApiService: TargetType {
    var baseURL: URL {
        
        switch self {
        case .deleteFile(let area, _),
             .renameFile(let area, _, _),
             .fileChunks(let area, _),
             .fileList(let area, _, _, _, _, _),
             .userList(let area),
             .userDetail(let area, _),
             .shareFileList(let area, _, _),
             .createDirectory(let area, _, _, _),
             .shareFiles(let area, _, _, _, _, _, _),
             .moveFiles(let area, _, _, _, _),
             .folderList(let area, _, _),
             .folderDetail(let area, _),
             .deleteFolder(let area, _),
             .decryptFolder(let area, _, _),
             .createFolder(let area, _, _, _, _, _, _, _, _),
             .editFolder(let area, _, _, _, _, _, _, _),
             .hardDiskList(let area),
             .addDiskToPool(let area, _, _),
             .storagePoolList(let area, _, _),
             .storagePoolDetail(let area, _),
             .editStoragePool(let area, _, _),
             .deleteStoragePool(let area, _),
             .addStoragePool(let area, _, _),
             .editFolderPwd(let area, _, _, _, _),
             .editPartition(let area, _, _, _, _, _),
             .deletePartition(let area, _, _),
             .addPartition(let area, _, _, _, _),
             .folderSettings(let area),
             .editFolderSettings(let area, _, _, _),
             .restartAsyncTask(let area, _),
             .deleteAsyncTask(let area, _):
            
            return URL(string: "\(area.requestURL)")!

        case .temporaryIP:
            return URL(string:"https://scgz.zhitingtech.com/api")!

        case .example:
            return URL(string:"http://192.168.0.1")!
        }
        
        
    }
    
    var path: String {
        switch self { 
        case .example:
            return ""
            
        case .deleteFile:
            return "/plugin/wangpan/resources"
            
        case .renameFile(_, let path, _):
            return "/plugin/wangpan/resources/\(path)"
            
        case .fileChunks(_, let hash):
            return "/plugin/wangpan/chunks/\(hash)"
            
        case .fileList(_, let path, _, _, _, _):
            return "/plugin/wangpan/resources/\(path)"
            
        case .userList:
            return "/users"
            
        case .userDetail(_, let id):
            return "/users/\(id)"
            
        case .shareFileList:
            return "/plugin/wangpan/shares"
            
        case .createDirectory(_, let path, let name, _):
            return "/plugin/wangpan/resources/\(path)/\(name)/"
            
        case .shareFiles:
            return "/plugin/wangpan/shares"
            
        case .moveFiles:
            return "/plugin/wangpan/resources"
            
        case .folderList:
            return "/plugin/wangpan/folders"
            
        case .folderDetail(_, let id):
            return "/plugin/wangpan/folders/\(id)"
            
        case .deleteFolder(_, let id):
            return "/plugin/wangpan/folders/\(id)"
            
        case .decryptFolder(_, let name, _):
            return "/plugin/wangpan/folders/\(name)"
            
        case .createFolder:
            return "/plugin/wangpan/folders"
            
        case .editFolder(_, let id, _, _, _, _, _, _):
            return "/plugin/wangpan/folders/\(id)"
            
        case .hardDiskList:
            return "/plugin/wangpan/disks"
            
        case .addDiskToPool:
            return "/plugin/wangpan/disks"
            
        case .storagePoolList:
            return "/plugin/wangpan/pools"
            
        case .storagePoolDetail(_, let name):
            return "/plugin/wangpan/pools/\(name)"
            
        case .editStoragePool(_, let name, _):
            return "/plugin/wangpan/pools/\(name)"
            
        case .deleteStoragePool(_, let name):
            return "/plugin/wangpan/pools/\(name)"
            
        case .addStoragePool:
            return "/plugin/wangpan/pools/"
            
        case .editFolderPwd:
            return "/plugin/wangpan/updateFolderPwd"
            
        case .editPartition(_, let name, _, _, _, _):
            return "/plugin/wangpan/partitions/\(name)"
            
        case .deletePartition(_, let name, _):
            return "/plugin/wangpan/partitions/\(name)"
            
        case .addPartition:
            return "/plugin/wangpan/partitions"
            
        case .folderSettings:
            return "/plugin/wangpan/settings"
            
        case .editFolderSettings:
            return "/plugin/wangpan/settings"
            
        case .restartAsyncTask(_, let task_id):
            return "/plugin/wangpan/tasks/\(task_id)"
            
        case .deleteAsyncTask(_, let task_id):
            return "/plugin/wangpan/tasks/\(task_id)"
            
        case .temporaryIP:
            return "/datatunnel"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .example:
            return .get
            
        case .deleteFile:
            return .delete
            
        case .renameFile:
            return .put
            
        case .fileChunks:
            return .get
            
        case .fileList:
            return .get
            
        case .userList:
            return .get
            
        case .userDetail:
            return .get
            
        case .shareFileList:
            return .get
            
        case .createDirectory:
            return .post
            
        case .shareFiles:
            return .post
            
        case .moveFiles:
            return .patch
            
        case .folderList:
            return .get
            
        case .folderDetail:
            return .get
            
        case .deleteFolder:
            return .delete
            
        case .decryptFolder:
            return .patch
            
        case .createFolder:
            return .post
            
        case .editFolder:
            return .put
            
        case .hardDiskList:
            return .get
            
        case .addDiskToPool:
            return .post
            
        case .storagePoolList:
            return .get
            
        case .storagePoolDetail:
            return .get
            
        case .editStoragePool:
            return .put
            
        case .deleteStoragePool:
            return .delete
            
        case .addStoragePool:
            return .post
            
        case .editFolderPwd:
            return .post
            
        case .editPartition:
            return .put
            
        case .deletePartition:
            return .delete
            
        case .addPartition:
            return .post
            
        case .folderSettings:
            return .get
            
        case .editFolderSettings:
            return .post
            
        case .restartAsyncTask:
            return .put
            
        case .deleteAsyncTask:
            return .delete
            
        case .temporaryIP:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .example:
            return .requestPlain
            
        case .deleteFile(_, let paths):
            return .requestParameters(parameters: ["paths" : paths], encoding: JSONEncoding.default)
            
        case .renameFile(_, _, let name):
            return .requestParameters(parameters: ["name": name], encoding: JSONEncoding.default)
            
        case .fileChunks:
            return .requestPlain
            
        case .fileList(_, _, let type, let page ,let page_size, _):
            return .requestParameters(parameters: ["type": type,
                                                   "page": page,
                                                   "page_size": page_size], encoding: URLEncoding.default)
            
        case .userList:
            return .requestPlain
            
        case .userDetail:
            return .requestPlain
            
        case .shareFileList(_, let page, let page_size):
            return .requestParameters(parameters: ["page": page,
                                                   "page_size": page_size], encoding: URLEncoding.default)
            
        case .createDirectory:
            return .uploadMultipart([MultipartFormData.init(provider: .stream(InputStream(data: Data()), UInt64(Data().count)), name: "uploadfile")])
            
        case .shareFiles(_, let paths, let usersId, let read, let write, let delete, let fromUser):
            return .requestParameters(parameters: ["paths" : paths ,
                                                   "to_users": usersId,
                                                   "read": read ? 1 : 0,
                                                   "write": write ? 1 : 0,
                                                   "deleted": delete ? 1 : 0,
                                                   "from_user": fromUser
                                                    ],
                                      encoding: JSONEncoding.default)
        
        case .moveFiles(_, let sources,let action, let destination_pwd,let destination):
            return .requestParameters(parameters: ["action" : action ,
                                                   "destination": destination,
                                                   "destination_pwd": destination_pwd,
                                                   "sources" : sources],
                                      encoding: JSONEncoding.default)
            
        case .folderList(_, let page, let pageSize):
            return .requestParameters(parameters: ["page": page,
                                                   "pageSize": pageSize],
                                      encoding: URLEncoding.default)
            
        case .folderDetail:
            return .requestPlain
            
        case .deleteFolder:
            return .requestPlain
            
        case .decryptFolder(_, _, let password):
            return .requestParameters(parameters: ["password" : password],
                                      encoding: JSONEncoding.default)
            
        case .createFolder(_, let name, let poolName, let partitionName, let isEncrypt, let pwd, let confirmPwd, let mode, let users):
            
            let auth = users.map { user -> FolderAuthModel in
                let model = FolderAuthModel()
                model.nickname = user.nickname
                model.face = user.icon_url
                model.u_id = user.user_id
                model.read = user.read
                model.write = user.write
                model.deleted = user.deleted
                return model
            }
            
            
            let authJson = auth.toJSON().compactMap({ $0 })
            
            var parameters: [String: Any] = [
                "name": name,
                "pool_name": poolName,
                "partition_name": partitionName,
                "is_encrypt": isEncrypt,
                "mode": mode.intValue,
                "auth": authJson
                
            ]
            
            
            
            if !pwd.isEmpty && !confirmPwd.isEmpty {
                parameters["pwd"] = pwd
                parameters["confirm_pwd"] = confirmPwd
            }
            
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default)
            
        case .editFolder(_, let id, let name, let poolName, let partitionName, let isEncrypt, let mode, let users):
            
            let auth = users.map { user -> FolderAuthModel in
                let model = FolderAuthModel()
                model.nickname = user.nickname
                model.face = user.icon_url
                model.u_id = user.user_id
                model.read = user.read
                model.write = user.write
                model.deleted = user.deleted
                return model
            }
            
            let authJson = auth.toJSON().compactMap({ $0 })
            
            return .requestParameters(
                parameters: [
                    "id": id,
                    "name": name,
                    "pool_name": poolName,
                    "partition_name": partitionName,
                    "is_encrypt": isEncrypt,
                    "mode": mode.intValue,
                    "auth": authJson
                ],
                encoding: JSONEncoding.default)
            
        case .hardDiskList:
            return .requestPlain
            
        case .addDiskToPool(_, let pool_name, let disk_name):
            return .requestParameters(parameters: ["pool_name": pool_name, "disk_name": disk_name],
                                      encoding: JSONEncoding.default)
            
        case .storagePoolList(_, let page, let pageSize):
            return .requestParameters(parameters: ["page": page, "page_size": pageSize], encoding: URLEncoding.default)
            
        case .storagePoolDetail:
            return .requestPlain
            
        case .editStoragePool(_, _, let new_name):
            return .requestParameters(parameters: ["new_name": new_name], encoding: JSONEncoding.default)
            
        case .deleteStoragePool:
            return .requestPlain
            
        case .addStoragePool(_, let name, let disk_name):
            return .requestParameters(parameters: ["name": name, "disk_name": disk_name], encoding: JSONEncoding.default)
            
        case .editFolderPwd(_, let id, let oldPwd, let newPwd, let confrimPwd):
            return .requestParameters(parameters: ["id": id, "old_pwd": oldPwd, "new_pwd": newPwd, "confirm_pwd": confrimPwd], encoding: JSONEncoding.default)
            
        case .editPartition(_, _, let new_name, let pool_name, let capacity, let unit):
            return .requestParameters(parameters: ["new_name": new_name,
                                                   "pool_name": pool_name,
                                                   "capacity": capacity,
                                                   "unit": unit],
                                      encoding: JSONEncoding.default)
        case .deletePartition(_, _, let pool_name):
            return .requestParameters(parameters: ["pool_name": pool_name],
                                      encoding: JSONEncoding.default)
            
        case .addPartition(_, let name, let capacity, let unit, let pool_name):
            return .requestParameters(parameters: ["name": name,
                                                   "capacity": capacity,
                                                   "unit": unit,
                                                   "pool_name": pool_name],
                                      encoding: JSONEncoding.default)
            
        case .folderSettings:
            return .requestPlain
            
        case .editFolderSettings(_, let pool_name, let partition_name, let is_auto_del):
            return .requestParameters(parameters: ["pool_name": pool_name,
                                                   "partition_name": partition_name,
                                                   "is_auto_del": is_auto_del ? 1 : 0],
                                      encoding: JSONEncoding.default)
            
        case .restartAsyncTask:
            return .requestPlain
            
        case .deleteAsyncTask:
            return.requestPlain
            
        case .temporaryIP(_, let scheme):
            return .requestParameters(
                parameters:
                    [
                        "scheme": scheme
                    ],
                encoding: URLEncoding.default
            )
        }
    }
    
    var headers: [String : String]? {
        var headers = [String: String]()
       //        headers["scope-token"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MzA3MjA3NjMsInNhX2lkIjoiaXZya3FjLXNhIiwic2NvcGVzIjoidXNlcixhcmVhIiwidWlkIjo2OH0.CfACCQFui2ciqkruo_r8zEwxN2b85lBQ0ehmwhi1miQ"

        headers["scope-token"] = AreaManager.shared.currentArea.scope_token


        headers["Area-ID"] = "\(AreaManager.shared.currentArea.id)"
        
        switch self {
        case .fileList(_, _, _ , _, _, let pwd), .createDirectory(_, _, _, let pwd):
            headers["pwd"] = pwd
        default:
            break
        }
        
        return headers
    }
    
    
}

extension MoyaProvider {
    /// 进行网络请求
    /// - Parameters:
    ///   - target: 请求的target
    ///   - modelType: response解析的model
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: 请求
    @discardableResult
    func requestNetwork<T: BaseModel>(_ target: Target, modelType: T.Type, successCallback: ((_ response: T) -> Void)?, failureCallback: ((_ code: Int, _ errorMessage: String) -> Void)? = nil) -> Moya.Cancellable? {
        return request(target) { (result) in
            switch result {
            case .success(let response):
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    
                }
                
                guard response.statusCode == 200, let model = response.data.map(ApiServiceResponseModel<T>.self) else {
                    failureCallback?(response.statusCode, "error: \(String(data: response.data, encoding: .utf8) ?? "unknown") code: \(response.statusCode)")
                    print("---------------------------------------------------------------------------")
                    print("error: \(String(data: response.data, encoding: .utf8) ?? "unknown")")
                    print("---------------------------------------------------------------------------\n\n")
                    return
                }
                
                if printDebugInfo {
                    print("---------------------------------------------------------------------------")
                    print(model.toJSONString(prettyPrint: true) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }
                
                if model.status == 0 {
                    successCallback?(model.data)
                } else {
                    if model.status == 10016 { /// 无效的授权，请重新授权
                        AreaManager.shared.areaAuthExpired()
                    } else if model.status == 2008 || model.status == 2009 {//用户未登录//登录账号已过期，请重新登录
                        AreaManager.shared.areaAuthExpired()
                    } else {
                        failureCallback?(model.status, model.reason)
                    }

                    
                }
                
            case .failure(let error):
                let moyaError = error as MoyaError
                let statusCode = moyaError.response?.statusCode ?? -1
                let errorMessage = "error"
                
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    print("---------------------------------------------------------------------------")
                    print("Error: \(error.localizedDescription) ErrorCode: \(statusCode)")
                    print("---------------------------------------------------------------------------\n\n")
                }
                
                failureCallback?(statusCode, errorMessage)
                return
            }
            
        }
    }
}


extension MoyaProvider {
    /// 进行网络请求返回列表时
    /// - Parameters:
    ///   - target: 请求的target
    ///   - modelType: response解析的model
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: 请求
    @discardableResult
    func requestListNetwork<T: BaseModel>(_ target: Target, modelType: T.Type, successCallback: ((_ response: [T]) -> Void)?, failureCallback: ((_ code: Int, _ errorMessage: String) -> Void)? = nil) -> Moya.Cancellable? {
        return request(target) { (result) in
            switch result {
            case .success(let response):
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    
                }
                
                guard response.statusCode == 200, let model = response.data.map(ApiServiceListResponseModel<T>.self) else {
                    failureCallback?(response.statusCode, "error: \(String(data: response.data, encoding: .utf8) ?? "unknown") code: \(response.statusCode)")
                    print("---------------------------------------------------------------------------")
                    print("error: \(String(data: response.data, encoding: .utf8) ?? "unknown")")
                    print("---------------------------------------------------------------------------\n\n")
                    return
                }
                
                if printDebugInfo {
                    print("---------------------------------------------------------------------------")
                    print(model.toJSONString(prettyPrint: true) ?? "")
                    print("---------------------------------------------------------------------------\n\n")
                }
                
                if model.status == 0 {
                    successCallback?(model.data)
                } else {
                    if model.status == 10016 { /// 无效的授权，请重新授权
                        AreaManager.shared.areaAuthExpired()
                    } else if model.status == 2008 || model.status == 2009 {//用户未登录//登录账号已过期，请重新登录
                        AreaManager.shared.areaAuthExpired()
                    } else {
                        failureCallback?(model.status, model.reason)
                    }

                    
                }
                
            case .failure(let error):
                let moyaError = error as MoyaError
                let statusCode = moyaError.response?.statusCode ?? -1
                let errorMessage = "error"
                
                if printDebugInfo {
                    print("-----------------------------< ApiService >--------------------------------")
                    print(Date())
                    print("---------------------------------------------------------------------------")
                    print("header: \(target.headers ?? [:])")
                    print("---------------------------------------------------------------------------")
                    print("method: \(target.method.rawValue)")
                    print("---------------------------------------------------------------------------")
                    print("baseUrl: \(target.baseURL)")
                    print("---------------------------------------------------------------------------")
                    print("target: \(target.path)")
                    print("---------------------------------------------------------------------------")
                    print("parameters: \(target.task)")
                    print("---------------------------------------------------------------------------")
                    print("Error: \(error.localizedDescription) ErrorCode: \(statusCode)")
                    print("---------------------------------------------------------------------------\n\n")
                }
                
                failureCallback?(statusCode, errorMessage)
                return
            }
            
        }
    }
}

extension Data {
    func map<T: HandyJSON>(_ type: T.Type) -> T? {
        let jsonString = String(data: self, encoding: .utf8)
        let model = T.deserialize(from: jsonString)
        return model
    }
}


