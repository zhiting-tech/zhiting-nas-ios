//
//  FixedTZImagePickerController.swift
//  ZhiTingCloud
//
//  Created by iMac on 2021/6/28.
//

import UIKit
import TZImagePickerController

class FixedTZImagePickerController: TZImagePickerController {
    
    override func showAlert(withTitle title: String!) -> UIAlertController! {
        var newTitle = title
        if title == "你最多只能选择 9 张照片" && self.allowPickingVideo == true && self.allowPickingImage == false {
            newTitle = "你最多只能选择 9 个视频"
        }
        return super.showAlert(withTitle: newTitle)
    }
}
