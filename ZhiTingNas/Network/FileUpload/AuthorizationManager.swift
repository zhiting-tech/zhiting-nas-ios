//
//  AuthorizationManager.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/12/14.
//

import Foundation
import Photos
import UIKit

class AuthorizationManager {
    /// 相机权限
        public static func camera(authorizedBlock: (()->())?) {
            
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            // .notDetermined  .authorized  .restricted  .denied
            if authStatus == .notDetermined {
                // 第一次触发授权 alert
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    self.camera(authorizedBlock: authorizedBlock)
                })
                
            //打开相机
            } else if authStatus == .authorized {
                if authorizedBlock != nil {
                    authorizedBlock!()
                }
                
            //没有权限使用相机
            } else {
                DispatchQueue.main.async {
                    
                    NormalAlertView.show(title: "权限未开启", message: "请在系统定位中开启相机权限", leftTap: "取消", rightTap: "去设置", clickCallback: { tap in
                        if tap == 1 {
                            let url = URL(string: UIApplication.openSettingsURLString)
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    }, removeWithSure: true)
                    
                }
            }
        }
    
    /// 相册权限
       public static func photoAlbum(authorizedBlock: (()->())?) {
           
           let authStatus = PHPhotoLibrary.authorizationStatus()
           
           // .notDetermined  .authorized  .restricted  .denied
           if authStatus == .notDetermined {
               // 第一次触发授权 alert
               PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                   self.photoAlbum(authorizedBlock: authorizedBlock)
               }
               
           //打开相册
           } else if authStatus == .authorized  {
               if authorizedBlock != nil {
                   authorizedBlock!()
               }
               
           //没有权限打开相册
           } else {
               DispatchQueue.main.async {
                   
                   NormalAlertView.show(title: "权限未开启", message: "请在系统定位中开启相机权限", leftTap: "取消", rightTap: "去设置", clickCallback: { tap in
                       if tap == 1 {
                           let url = URL(string: UIApplication.openSettingsURLString)
                           UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                       }
                   }, removeWithSure: true)
               }
           }
       }
}
