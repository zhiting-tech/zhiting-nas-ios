//
//  NetworkManager.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/2.
//

import Foundation
import Moya


fileprivate let requestClosure = { (endpoint: Endpoint, closure: (Result<URLRequest, MoyaError>) -> Void)  -> Void in
    do {
        var  urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = 15
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.httpShouldHandleCookies = true
        closure(.success(urlRequest))
    } catch MoyaError.requestMapping(let url) {
        closure(.failure(MoyaError.requestMapping(url)))
    } catch MoyaError.parameterEncoding(let error) {
        closure(.failure(MoyaError.parameterEncoding(error)))
    } catch {
        closure(.failure(MoyaError.underlying(error, nil)))
    }
    
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private lazy var apiService = MoyaProvider<ApiService>(requestClosure: requestClosure, callbackQueue: DispatchQueue.main)

}

extension NetworkManager {
    /// 网络请求编写范例
    /// - Description: 详细说明
    /// - Parameters:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
//    func requestExample(successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
//
//        requestTemporaryIP(area: area) { [weak self] ip in
//            guard let self = self else { return }
//            //获取临时通道地址
//            if ip != "" {
//                area.temporaryIP = "http://" + ip
//            }
//            //请求结果
//            self.apiService.requestNetwork(.example,
//                                           modelType: ExampleResponse.self,
//                                           successCallback: successCallback,
//                                           failureCallback: failureCallback)
//        } failureCallback: { code, err in
//            failureCallback?(code,err)
//        }
//
//    }
    
    // MARK: - 用户相关
    
    /// 获取SA用户详情
    /// - Parameters:
    ///   - id: 用户id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func userDetail(area: Area = AreaManager.shared.currentArea, id: Int, successCallback: ((User) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.userDetail(area : area, id: id),
                                           modelType: User.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 获取sa用户列表
    /// - Parameters:
    ///   - area: 家庭
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func saUserList(area: Area = AreaManager.shared.currentArea, successCallback: ((SAUserListResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.userList(area: area),
                                           modelType: SAUserListResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    // MARK: - 文件操作
    
    /// 新建目录
    /// - Parameters:
    ///   - path: 路径
    ///   - name: 目录名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func createDirectory(area: Area = AreaManager.shared.currentArea, path: String, name: String, pwd: String = "", successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.createDirectory(area : area, path: path, name: name, pwd: pwd),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 删除文件或目录
    /// - Parameters:
    ///   - paths: 要删除的文件或目录 path数组
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func deleteFile(area: Area = AreaManager.shared.currentArea, paths: [String], successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.deleteFile(area : area, paths: paths),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 重命名文件或目录
    /// - Parameters:
    ///   - path: 文件或目录path
    ///   - name: 新的命名
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func renameFile(area: Area = AreaManager.shared.currentArea, path: String, name: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.renameFile(area : area, path: path, name: name),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 获取文件已上传的分片信息
    /// - Parameters:
    ///   - hash: 文件的hash
    ///   - successCallback: 成功回调 分片信息数组
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func fileChunks(area: Area = AreaManager.shared.currentArea, hash: String, successCallback: ((FileChunksResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.fileChunks(area : area, hash: hash),
                                           modelType: FileChunksResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }

    /// 目录下的文件/子目录列表
    /// - Parameters:
    ///   - path: 文件的路径
    ///   - successCallback: 成功回调 分片信息数组
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func fileList(area: Area = AreaManager.shared.currentArea, path: String, type: Int = 0, page: Int = 1, page_size: Int = 30, pwd: String = "", successCallback: ((FileListResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.fileList(area : area, path: path, type: type, page: page, page_size: page_size, pwd: pwd),
                                           modelType: FileListResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    
    }

    
    /// 获取别人共享给我的目录列表
    ///   - successCallback: 成功回调 分片信息数组
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func shareFileList(area: Area = AreaManager.shared.currentArea, page: Int = 1, page_size: Int = 30, successCallback: ((FileListResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.shareFileList(area : area, page: page, page_size: page_size),
                                           modelType: FileListResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    
    }
    
    /// 共享目录
    /// - Parameters:
    ///   - paths: 要共享的文件或目录 path数组
    ///   - usersId: 要共享给的用户数据
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    ///   - read: 读权限
    ///   - write: 写权限
    ///   - deleted: 删除权限
    ///   - fromUser: 共享者昵称
    /// - Returns: moya网络请求
    func shareFiles(area: Area = AreaManager.shared.currentArea, paths: [String], usersId: [Int], read: Bool, write: Bool, delete: Bool, fromUser: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
         
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.shareFiles(area : area, paths: paths, usersId: usersId, read: read, write: write, delete: delete, from_user: fromUser),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }

    /// 复制/移动文件/目录
    /// - Parameters:
    ///   - action: 拷贝、移动
    ///   - destination: 目标目录的完整路径
    ///   - sources: 源路径列表
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func moveFiles(area: Area = AreaManager.shared.currentArea, sources: [String], action: String, destination: String, destination_pwd: String = "", successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.moveFiles(area : area, sources: sources, action: action,  destination_pwd:destination_pwd,destination: destination),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    // MARK: - 文件夹管理
    /// 文件夹列表
    /// - Parameters:
    ///   - page: 当前页数 
    ///   - pageSize: 每页数量
    ///   - type: 文件夹类型
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func folderList(area: Area = AreaManager.shared.currentArea, page: Int, pageSize: Int = 30, successCallback: ((FolderListResposne) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.folderList(area : area, page: page, pageSize: pageSize),
                                           modelType: FolderListResposne.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 文件夹详情
    /// - Parameters:
    ///   - id: 文件夹id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func folderDetail(area: Area = AreaManager.shared.currentArea, id: Int, successCallback: ((FolderModel) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.folderDetail(area : area, id: id),
                                           modelType: FolderModel.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)


        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 添加文件夹
    /// - Parameters:
    ///   - name: 文件夹名称
    ///   - pool_name: 储存池名称
    ///   - partition_name: 储存池分区名称
    ///   - is_encrypt: 是否加密
    ///   - pwd: 密码
    ///   - confirm_pwd: 确认密码
    ///   - mode: 文件夹类型 1私人文件夹 2共享文件夹
    ///   - auth: 可访问成员
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func createFolder(
        area: Area = AreaManager.shared.currentArea,
        name: String,
        pool_name: String,
        partition_name: String,
        is_encrypt: Int,
        pwd: String,
        confirm_pwd: String,
        mode: FolderModel.FolderMode,
        auth: [User],
        successCallback: ((ExampleResponse) -> Void)?,
        failureCallback: ((Int, String) -> Void)?
    ) {
         
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.createFolder(
                                            area : area,
                                            name: name,
                                            pool_name: pool_name,
                                            partition_name: partition_name,
                                            is_encrypt: is_encrypt,
                                            pwd: pwd,
                                            confirm_pwd: confirm_pwd,
                                            mode: mode,
                                            auth: auth),
                                         modelType: ExampleResponse.self,
                                         successCallback: successCallback,
                                         failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
        

    }

    /// 编辑文件夹
    /// - Parameters:
    ///   - id: 文件夹id
    ///   - name: 文件夹名称
    ///   - pool_name: 储存池名称
    ///   - partition_name: 储存池分区名称
    ///   - is_encrypt: 是否加密
    ///   - oldPwd: 旧密码
    ///   - pwd: 密码
    ///   - confirm_pwd: 确认密码
    ///   - mode: 文件夹类型 1私人文件夹 2共享文件夹
    ///   - auth: 可访问成员
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func editFolder(
        area: Area = AreaManager.shared.currentArea,
        id: Int,
        name: String,
        pool_name: String,
        partition_name: String,
        is_encrypt: Int,
        mode: FolderModel.FolderMode,
        auth: [User],
        successCallback: ((ExampleResponse) -> Void)?,
        failureCallback: ((Int, String) -> Void)?
    ) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.editFolder(
                                            area : area,
                                            id: id,
                                            name: name,
                                            pool_name: pool_name,
                                            partition_name: partition_name,
                                            is_encrypt: is_encrypt,
                                            mode: mode,
                                            auth: auth),
                                         modelType: ExampleResponse.self,
                                         successCallback: successCallback,
                                         failureCallback: failureCallback)


        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 编辑文件夹密码
    /// - Parameters:
    ///   - id: 文件夹id
    ///   - oldPwd: 旧密码
    ///   - newPwd: 新密码
    ///   - confirmPwd: 确认密码
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: Moya网络请求
    func editFolderPwd(area: Area = AreaManager.shared.currentArea, id: Int, oldPwd: String, newPwd: String, confirmPwd: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.editFolderPwd(area : area,
                                                          id: id,
                                                          oldPwd: oldPwd,
                                                          newPwd: newPwd,
                                                          confrimPwd: confirmPwd),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }

    
    /// 删除文件夹
    /// - Parameters:
    ///   - id: 文件夹id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func deleteFolder(area: Area = AreaManager.shared.currentArea, id: Int, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.deleteFolder(area : area, id: id),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }


    /// 解密文件夹
    /// - Parameters:
    ///   - name: 文件夹名称
    ///   - password: 文件夹密码
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func decryptFolder(area: Area = AreaManager.shared.currentArea, name: String, password: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {

        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.decryptFolder(area : area, name: name, password: password),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    // MARK: - 硬盘管理
    /// 闲置硬盘列表
    /// - Parameters:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func hardDiskList(area: Area = AreaManager.shared.currentArea, successCallback: ((HardDiskListResposne) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.hardDiskList(area : area), modelType: HardDiskListResposne.self, successCallback: successCallback, failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 添加到存储池
    /// - Parameters:
    ///   - pool_ids: 存储池id
    ///   - disk_name: 硬盘名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func addHardDiskToPool(area: Area = AreaManager.shared.currentArea, pool_name: String, disk_name: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {

        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.addDiskToPool(area : area, pool_name: pool_name, disk_name: disk_name), modelType: ExampleResponse.self, successCallback: successCallback, failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    // MARK: - 存储池管理
    
    /// 存储池列表
    /// - Parameters:
    ///   - page: 请求页数
    ///   - pageSize: 每页大小
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func storagePoolList(area: Area = AreaManager.shared.currentArea, page: Int, pageSize: Int = 30, successCallback: ((StoragePoolListResposne) -> Void)?, failureCallback: ((Int, String) -> Void)?)  {

        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.storagePoolList(area : area, page: page, pageSize: pageSize),
                                           modelType: StoragePoolListResposne.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 存储池详情
    /// - Parameters:
    ///   - name: 存储池名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func storagePoolDetail(area: Area = AreaManager.shared.currentArea, name: String, successCallback: ((StoragePoolModel) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.storagePoolDetail(area : area, name: name),
                                           modelType: StoragePoolModel.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 编辑存储池
    /// - Parameters:
    ///   - name: 存储池名称
    ///   - new_name: 修改后名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func editStoragePool(area: Area = AreaManager.shared.currentArea, name: String, new_name: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {

        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.editStoragePool(area : area, name: name, new_name: new_name),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 删除存储池
    /// - Parameters:
    ///   - name: 存储池名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func deleteStoragePool(area: Area = AreaManager.shared.currentArea, name: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
                                  
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.deleteStoragePool(area : area, name: name),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 选择硬盘创建存储池
    /// - Parameters:
    ///   - name: 存储池名称
    ///   - disk_name: 闲置硬盘名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func addStoragePool(area: Area = AreaManager.shared.currentArea, name: String, disk_name: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {

        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.addStoragePool(area : area, name: name, disk_name: disk_name),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }

    
    /// 编辑存储池分区
    /// - Parameters:
    ///   - name: 分区原名称
    ///   - new_name: 修改后名称
    ///   - pool_name：存储池名称
    ///   - capacity：分区分配容量
    ///   - unit: 单位
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func editPartition(area: Area = AreaManager.shared.currentArea, name: String, new_name: String, pool_name:String, capacity: Float, unit: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {

        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.editPartition(area : area, name: name, new_name: new_name, pool_name: pool_name, capacity: capacity, unit: unit),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }

    /// 删除存储池分区
    /// - Parameters:
    ///   - name: 存储池名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func deletePartition(area: Area = AreaManager.shared.currentArea, name: String, pool_name: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.deletePartition(area : area, name: name, pool_name: pool_name),
                                           modelType: ExampleResponse.self,
                                           successCallback: successCallback,
                                           failureCallback: failureCallback)
            
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }

    /// 添加存储池分区
    /// - Parameters:
    ///   - pool_name: 存储池名称
    ///   - disk_name: 硬盘名称
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func addPartition(area: Area = AreaManager.shared.currentArea, name: String, capacity: Float, unit: String, pool_name: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?){
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.addPartition(area : area, name: name, capacity: capacity, unit: unit, pool_name: pool_name), modelType: ExampleResponse.self, successCallback: successCallback, failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }

    
    /// 文件夹设置详情
    /// - Parameters:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func getFolderSettings(area: Area = AreaManager.shared.currentArea, successCallback: ((FolderSettingModel) -> Void)?, failureCallback: ((Int, String) -> Void)?){
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.folderSettings(area : area), modelType: FolderSettingModel.self, successCallback: successCallback, failureCallback: failureCallback)
        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 文件夹设置详情
    /// - Parameters:
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    ///   - poolName: 存储池名称
    ///   - partitionName: 分区名称
    ///   - autoDel: 成员退出是否自动删除
    /// - Returns: moya网络请求
    func setFolderSettings(area: Area = AreaManager.shared.currentArea, poolName: String, partitionName: String, autoDel: Bool, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
            
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.editFolderSettings(area : area, pool_name: poolName, partition_name: partitionName, is_auto_del: autoDel), modelType: ExampleResponse.self, successCallback: successCallback, failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }
    }
    
    /// 重新开始异步任务
    /// - Parameters:
    ///   - task_id: 异步任务id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    func restartAsyncTask(area: Area = AreaManager.shared.currentArea, task_id: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) {
        requestTemporaryIP(area: area) { [weak self] ip in
            guard let self = self else { return }
            //获取临时通道地址
            if ip != "" {
                area.temporaryIP = "http://" + ip
            }
            //请求结果
            self.apiService.requestNetwork(.restartAsyncTask(area : area, task_id: task_id), modelType: ExampleResponse.self, successCallback: successCallback, failureCallback: failureCallback)

        } failureCallback: { code, err in
            failureCallback?(code,err)
        }

    }
    
    /// 删除异步任务
    /// - Parameters:
    ///   - task_id: 异步任务id
    ///   - successCallback: 成功回调
    ///   - failureCallback: 失败回调
    /// - Returns: moya网络请求
    @discardableResult
    func deleteAsyncTask(area: Area = AreaManager.shared.currentArea, task_id: String, successCallback: ((ExampleResponse) -> Void)?, failureCallback: ((Int, String) -> Void)?) -> Moya.Cancellable? {
        return apiService.requestNetwork(.deleteAsyncTask(area : area, task_id: task_id), modelType: ExampleResponse.self, successCallback: successCallback, failureCallback: failureCallback)
    }
    
}

extension NetworkManager{
    //获取临时通道地址
    private func requestTemporaryIP(area: Area = AreaManager.shared.currentArea, complete:((String)->())?, failureCallback: ((Int, String) -> ())?) {
        //在局域网内则直接连接局域网
        if area.bssid == NetworkStateManager.shared.getWifiBSSID() && area.bssid != nil || !UserManager.shared.isCloudUser {//局域网
            complete?("")
            GoFileNewManager.shared.updateHost(host: "\(AreaManager.shared.currentArea.sa_lan_address ?? "")/api")
            return
        }
        
        //不在SA局域网内且不是云端授权的情况，提示用户云端授权才可在外网使用
        if area.bssid != NetworkStateManager.shared.getWifiBSSID() && area.bssid != nil && !UserManager.shared.isCloudUser {
            failureCallback?(-1, "智慧中心连接失败，请在智汀家庭云登录后重新授权连接或在局域网内连接")
            return
        }

        //获取本地存储的临时通道地址
        let key = area.sa_user_token
        let temporaryJsonStr:String = UserDefaults.standard.value(forKey: key) as? String ?? ""
        let temporary = TemporaryResponse.deserialize(from: temporaryJsonStr)
        //验证是否过期，直接返回IP地址
        if let temporary = temporary {//有存储信息
            if timeInterval(fromTime: temporary.saveTime , second: temporary.expires_time) {
                //地址并未过期
                GoFileNewManager.shared.updateHost(host: "http://\(temporary.host)/api")
                complete?(temporary.host)
                return
            }
        }
        
        //过期，请求服务器获取临时通道地址
        apiService.requestNetwork(.temporaryIP(area: AreaManager.shared.currentArea, scheme: "http"), modelType: TemporaryResponse.self) { response in
            //获取临时通道地址及有效时间,存储在本地
            //更新时间和密码
            let temporaryModel = TemporaryResponse()
            temporaryModel.host = response.host
            temporaryModel.expires_time = response.expires_time
            //当前时间
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            temporaryModel.saveTime = dateFormatter.string(from: Date())
            UserDefaults.standard.setValue(temporaryModel.toJSONString(prettyPrint:true), forKey: key)
            
            //返回ip地址
            complete?(response.host)
            GoFileNewManager.shared.updateHost(host: "http://\(response.host)/api")

        } failureCallback: { code, error in
            failureCallback?(code,error)
        }

    }
    
    // 时间间隔
    private func timeInterval(fromTime: String , second: Int) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //当前时间
        let time = dateFormatter.string(from: Date())
        //计算时间差
        let timeNumber = Int(dateFormatter.date(from: time)!.timeIntervalSince1970-dateFormatter.date(from: fromTime)!.timeIntervalSince1970)
        
        //        let timeInterval:CGFloat = CGFloat(timeNumber)/3600.0
        
        return second > timeNumber
    }
    
    
}

