//
//  AppDelegate.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import UIKit
import Toast_Swift
import Kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        FileUploadManager.shared.setup()
        
        // toast
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.position = .center
        ToastManager.shared.duration = 1
        ToastManager.shared.isQueueEnabled = true
        
        // kingfisher
        KingfisherManager.shared.downloader.downloadTimeout = 30
        KingfisherManager.shared.downloader.authenticationChallengeResponder = KFCerAuthenticationChallenge.shared

        // networkStateManager
        NetworkStateManager.shared.setup()
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        OpenUrlManager.shared.open(url: url)
        return true
    }

    //app进行终止时
    func applicationWillTerminate(_ application: UIApplication) {
//        GoFileNewManager.shared.quitApp()
    }
}

