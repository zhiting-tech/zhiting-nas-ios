//
//  SceneDelegate.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit
import Combine
import Photos

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    static var shared: SceneDelegate {
        return (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate)
    }
    
    
    var window: UIWindow?
    
    lazy var cancellables = [AnyCancellable]()



    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.frame = scene.coordinateSpace.bounds
        
        setupWindow()
        
    }
    
    func setupWindow() {
        
        
        if AreaManager.shared.getAreaList().count > 0 {
            if let area = AreaManager.shared.getAreaList().first {
                AreaManager.shared.currentArea = area
                UDPDeviceTool.updateAreaSAAddress()
            }
            
            if let user = UserManager.shared.getUserFromCache() {
                UserManager.shared.currentUser = user
            }
            // gomobile
            // gomobile db文件
            GoFileManager.shared.setup()
            GoFileManager.shared.gomobileRun()
            networkChange()
            backupMedia()
            window?.rootViewController = TabbarController()
        } else {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            window?.rootViewController = nav
        }
        
        
        window?.makeKeyAndVisible()
    }
    
    //根据权限判断获取相册图片或视频进行备份
    func backupMedia(){
        if UserManager.shared.allowPhotoBackups {
            BackupsMediaManager.backupPhotos()
        }
        
        if UserManager.shared.allowVideoBackups {
            BackupsMediaManager.backupVideo()
        }
    }
    

        
    //监听全局网络变化
    private func networkChange(){
        NetworkStateManager.shared.networkStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { states in
            //检测网络变化，更新gomobileHost
            NetworkManager.shared.requestTemporaryIP(area: AreaManager.shared.currentArea) { ip in
                //获取临时通道地址
                if ip != "" {
                    AreaManager.shared.currentArea.temporaryIP = "https://" + ip
                }
                
            } failureCallback: { code, err in
                print(err)
            }
            
            switch states {
            case .noNetwork:
                break
            case .reachable(let type):
                switch type {
                case .wifi:
                    break
                case .cellular:
                    if GoFileManager.shared.getTotalonGoingCount() != 0 && !UserManager.shared.allowCellular {
                        GoFileManager.shared.stopAllUploadTask(isBackup: 0)
                        GoFileManager.shared.stopAllUploadTask(isBackup: 1)
                        GoFileManager.shared.stopAllDownLoadTask()
                        NormalAlertView.show(title: "提示", message: "当前正在使用移动流量，使用会消耗较多流量，是否继续上传/下载", leftTap: "暂停", rightTap: "继续", clickCallback: { tap in
                            switch tap {
                            case 0:
                                print("暂停")
                                break
                            case 1:
                                print("继续")
                                //请求结果
                                GoFileManager.shared.startAllUploadTask(isBackup: 0)
                                GoFileManager.shared.startAllUploadTask(isBackup: 1)
                                GoFileManager.shared.startAllDownLoadTask()
                                break
                            default:
                                break
                            }
                        }, removeWithSure: false)
                        
                    }
                    
                default :
                    break
                    
                }
                
            }
        }
        .store(in: &cancellables)
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach {
            OpenUrlManager.shared.open(url: $0.url)
            
        }
        
    }
}
