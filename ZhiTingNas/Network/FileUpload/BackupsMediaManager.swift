//
//  BackupsMediaManager.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/12/16.
//

import Foundation
import Photos
import TZImagePickerController

class BackupsMediaManager {
    
    //备份相册
    static func backupPhotos(){
        getAllPhotos { groupPhotoAssetArr, identifierModel in
            DispatchQueue.global().async {
                groupPhotoAssetArr.forEach { assetsGroup in
                    assetsGroup.forEach { asset in
                            asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { editingInput, info in
                                GoFileManager.shared.uploadMediaData(urlPath: editingInput?.fullSizeImageURL?.absoluteString ?? "", identification: asset.localIdentifier, phoneName: "iPhone", isPic: true, folderId: identifierModel.private_file_id)
                                print("图片备份成功")
                            }
                    }

                }
            }
        }
    }
    
    
    //获取所有需要上传的图片（筛选已上传的图片）
    static func getAllPhotos(_ customTypealias: @escaping (_ groupPhotoAssetArr: [[PHAsset]], _ identifierModel: IdentificationModel) -> Void) {
        AlbumManager.shared.getAllPhoto { assetArr in
            //拆分每组50张
            print("获取所有图片成功")
            GoFileManager.shared.getAlreadyUploadDatas { identifierModel in//获取已上传的唯一标识
                //筛选未上传的图片集
                var uploadAssetArr: [PHAsset] = []//真正需要上传的数组
                for i in 0 ..< assetArr.count {
                    //获取文件名称，并判断是否已上传
                    let identifile = assetArr[i].localIdentifier
                    if !identifierModel.identifications.contains(identifile) {
                        uploadAssetArr.append(assetArr[i])
                    }
                }

                //开始上传分组成50张为一组，异步执行上传。
                //将要上传的文件数组分隔成等份的子数组
                var groupPhotoAssetArr = [[PHAsset]]()
                let groupPhotoAssetNum = 50
                var currentStart: Int = 0
                var currentEnd: Int = groupPhotoAssetNum
                while currentStart < uploadAssetArr.count {
                     currentEnd = min(currentStart + groupPhotoAssetNum, uploadAssetArr.count)
                     let subArr = Array(uploadAssetArr[currentStart ..< currentEnd]) as [PHAsset]
                     groupPhotoAssetArr.append(subArr)
                     currentStart = currentEnd
                 }
                
                customTypealias(groupPhotoAssetArr, identifierModel)
            }
        }
    }
    
    //备份视频
    static func backupVideo(){
        getAllVideo { groupPhotoAssetArr, identifierModel in
            DispatchQueue.global().async {
                groupPhotoAssetArr.forEach { assetsGroup in
                    assetsGroup.forEach { asset in
                        let options: PHVideoRequestOptions = PHVideoRequestOptions ()
                        options.deliveryMode = .highQualityFormat
                        options.version = .original
                        
                        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, audioMix, info in
                            if let  avAsset = avAsset as? AVURLAsset{
                                GoFileManager.shared.uploadMediaData(urlPath: avAsset.url.absoluteString , identification: asset.localIdentifier, phoneName: "iPhone", isPic: false, folderId: identifierModel.private_file_id)
                            }

                        }
                        
                    }

                }
            }
        }
    }
    
    static func getAllVideo(_ customTypealias: @escaping (_ groupVideoAssetArr: [[PHAsset]], _ identifierModel: IdentificationModel) -> Void) {
        
        AlbumManager.shared.getAllVideo { assetArr in
            //拆分每组50张
            print("获取所有视频成功")
            GoFileManager.shared.getAlreadyUploadDatas { identifierModel in//获取已上传的唯一标识
                //筛选未上传的图片集
                var uploadAssetArr: [PHAsset] = []//真正需要上传的数组
                for i in 0 ..< assetArr.count {
                    //获取文件名称，并判断是否已上传
                    let identifile = assetArr[i].localIdentifier
                    if !identifierModel.identifications.contains(identifile) {
                        uploadAssetArr.append(assetArr[i])
                    }
                }

                //开始上传分组成50张为一组，异步执行上传。
                //将要上传的文件数组分隔成等份的子数组
                var groupVideoAssetArr = [[PHAsset]]()
                let groupVideoAssetNum = 50
                var currentStart: Int = 0
                var currentEnd: Int = groupVideoAssetNum
                while currentStart < uploadAssetArr.count {
                     currentEnd = min(currentStart + groupVideoAssetNum, uploadAssetArr.count)
                     let subArr = Array(uploadAssetArr[currentStart ..< currentEnd]) as [PHAsset]
                     groupVideoAssetArr.append(subArr)
                     currentStart = currentEnd
                 }
                
                customTypealias(groupVideoAssetArr, identifierModel)
            }
        }
    }

}


extension BackupsMediaManager {
    static func getAllPhotos() async -> ([[PHAsset]], IdentificationModel) {
        await withCheckedContinuation { continuation in
            getAllPhotos { groupPhotoAssetArr, identifierModel in
                continuation.resume(returning: (groupPhotoAssetArr, identifierModel))
            }
        }
    }
    
    static func backupPhotos() async {
        /// 拿到待备份照片的分组
        let (groupPhotoAssetArr, identifierModel) = await getAllPhotos()
        

    }
    
}
