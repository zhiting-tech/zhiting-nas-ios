//
//  AreaManager.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/2.
//

import Foundation
import Combine

class AreaManager {
    static let shared = AreaManager()

    private init() {}
    
    lazy var fileManager = FileManager.default
    
    /// 家庭列表缓存的路径url
    var areaCachesFileURL: URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return url.appendingPathComponent("areaCaches")
    }
    
    /// 当前家庭
    var currentArea = Area() {
        didSet {
            if currentArea.bssid == nil {
                let bssid = NetworkStateManager.shared.getWifiBSSID()
                checkIfSAAvailable(area: currentArea) { [weak self] available in
                    guard let self = self else { return }
                    if available {
                        self.currentArea.bssid = bssid
                        let areas = self.getAreaList()
                        let existArea = areas.first(where: { $0.id == self.currentArea.id })
                        existArea?.bssid = self.currentArea.bssid
                        self.cacheAreas(areas: areas)
                    }
                    self.currentAreaPublisher.send(self.currentArea)
                }
            } else {
                currentAreaPublisher.send(currentArea)
            }
            
            
        }
    }
    /// 当前家庭切换时的发布者 类似rxswift的observable中的 publishSubject
    var currentAreaPublisher = PassthroughSubject<Area, Never>()

    
    /// 获取本地家庭列表
    /// - Returns: 存储的家庭
    func getAreaList() -> [Area] {
        guard
            let url = areaCachesFileURL,
            let jsonData = try? Data(contentsOf: url),
            let json = String(data: jsonData, encoding: .utf8),
            let areas = [Area].deserialize(from: json)
        else {
            return [Area]()
        }
        
        return areas.compactMap({ $0 })
    }
    
    
    /// 缓存家庭列表到本地
    /// - Parameter areas: 需要缓存的家庭
    func cacheAreas(areas: [Area]) {
        guard let url = areaCachesFileURL else { return }
        
        print("家庭列表缓存至\(url.absoluteString)")

        if !fileManager.fileExists(atPath: url.absoluteString) {
            fileManager.createFile(atPath: url.absoluteString, contents: nil, attributes: nil)
        }
        
        guard let jsonData = areas.toJSONString()?.data(using: .utf8) else { return }
        
        try? jsonData.write(to: url)

    }
    
    /// 清除本地家庭列表缓存
    func clearAreas() {
        cacheAreas(areas: [])
    }
    
    /// 家庭授权失效
    func areaAuthExpired(area: Area = AreaManager.shared.currentArea) {
        var areas = getAreaList()
        /// 若家庭已经不存在了，直接返回
        if areas.filter({ $0.scope_token == area.scope_token }).count == 0 || authExpiredAlert != nil {
            return
        }

        areas.removeAll(where: { $0.scope_token == area.scope_token })
        cacheAreas(areas: areas)
        
        authExpiredAlert = SingleTipsAlertView(detail: "提示\n\n无效的授权,请重新授权", detailColor: .custom(.black_3f4663), sureBtnTitle: "确认")
        authExpiredAlert?.sureCallback = { [weak self] in
            guard let self = self else { return }
            if let area = areas.first { // 切换家庭
                self.currentArea = area
            } else { // 若无家庭可切，则回到授权页面
                SceneDelegate.shared.window?.rootViewController = LoginViewController()
            }
            authExpiredAlert?.removeFromSuperview()
            authExpiredAlert = nil
        }
        SceneDelegate.shared.window?.addSubview(authExpiredAlert!)
    }

}


extension AreaManager {
    /// 检测家庭是否在对应的SA环境
    /// - Parameters:
    ///   - addr: 地址
    ///   - resultCallback: 结果回调
    func checkIfSAAvailable(area: Area, resultCallback: ((_ available: Bool) -> Void)?) {
        if let addr = area.sa_lan_address, let url = URL(string: "\(addr)/api/check") {
            var request = URLRequest(url: url)
            request.timeoutInterval = 0.5
            request.httpMethod = "POST"
            request.headers["scope-token"] = area.scope_token
            
            URLSession(configuration: .default)
                .dataTask(with: request) { (data, response, error) -> Void in
                    guard error == nil else {
                        DispatchQueue.main.async {
                            resultCallback?(false)
                        }
                        return
                    }
                    
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        DispatchQueue.main.async {
                            resultCallback?(false)
                        }
                        
                        return
                    }
                    
                    guard
                        let data = data,
                        let response = ApiServiceResponseModel<SAAccessResponse>.deserialize(from: String(data: data, encoding: .utf8)),
                        response.data.access_allow == true
                    else {
                        DispatchQueue.main.async {
                            resultCallback?(false)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        resultCallback?(true)
                    }
                }
                .resume()
        } else {
            DispatchQueue.main.async {
                resultCallback?(false)
            }
        }
    }
}

/// 授权失效弹窗
fileprivate var authExpiredAlert: SingleTipsAlertView?
