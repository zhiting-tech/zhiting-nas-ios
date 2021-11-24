//
//  Assets.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/14.
//

import Foundation
import UIKit

enum AssetsName: String {
    case myFile_tab
    case shareFile_tab
    case mine_tab
    case myFile_tab_sel
    case shareFile_tab_sel
    case mine_tab_sel
    case navigation_back
    case arrow_right
    
    case close_button
    case family_sel
    case family_unsel
    case unselected_tick
    case selected_tick

    case arrow_down
    case arrow_up
    case transferList_icon
    case newFolder_icon
    case upload_icon
    
    case fileSelected_normal
    case fileSelected_selected
    
    case zip_icon
    case video_icon
    case txt_icon
    case share_folder_icon
    case ppt_icon
    case picture_icon
    case pdf_icon
    case music_icon
    case unFindFile_icon
    case folder_icon
    case excel_icon
    case document_icon
    case encrypt_icon
    case encrypt_bg_icon
    
    case resetName_icon
    case resetName_not_icon
    case delete_icon
    case delete_not_icon
    case copy_icon
    case copy_not_icon
    case download_icon
    case download_not_icon
    case move_icon
    case move_not_icon
    case share_icon
    case share_not_icon
    case login_icon

    case otherApp_open
    case download_black
    case move_black
    case copy_black
    case resetName_black
    case delete_black
    
    case folder_big
    
    case logout
    case user_default
    case setting_icon
    
    case shareSelected_normal
    case shareSelected_selected
    
    case folder_middle
    case share_folder_middle
    
    case update_folder
    case update_file
    case update_picture
    case update_video
    
    case path_arrow
    
    case btn_stop
    case btn_download
    case btn_reDownload
    
    case mine_storage
    case mine_doc
    
    case storage_add
    case storagePool_resetName
    case icon_menu
    case icon_storagePool
    case icon_storagePoolPartition
    case icon_hardDrive
    case icon_hardDrive_purple
    case hardDrive_bg1
    case hardDrive_bg2
    case hardDrive_bg3
    case hardDrive_bg4
    case selected_whiteBG
    case member_icon
    case partition_icon
    
    case back_white
    case empty_member
    case empty_partition
    case empty_file

    case btn_delete
    case btn_edit
    case icon_capacityArrow

    case icon_deletable_selected
    case icon_deletable_unselected
    case icon_writable_selected
    case icon_writable_unselected
    case icon_readable_selected
    case icon_readable_unselected
    case icon_auth_selected
    case icon_more
    case arrow_down_double
    case icon_close_blue
    case icon_selected_orange
    case icon_lock
    case icon_menu_blue

    case icon_warning
    case icon_editing
    case icon_deleting
    case icon_adding

    case circle_add

    case error_info
    
    case selected_blueBG

    var assetName: String {
        return self.rawValue
    }
}

extension UIImage {
    static func assets(_ asset: AssetsName) -> UIImage? {
        return UIImage(named: asset.assetName)
    }
}
