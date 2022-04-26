//
//  AlbumManager.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/12/14.
//

import UIKit
import Photos

class AlbumManager {
    //单例
    static let shared = AlbumManager()
    
    //MARK:-获取相册所有图片
    func getAllPhoto(photoHandler: @escaping (_ assetArr: [PHAsset]) -> Void) {
        weak var weakSelf = self
        AuthorizationManager.photoAlbum {
            let assetArr: [PHAsset] = weakSelf!.getCameraRoll()
            photoHandler(assetArr)
        }
    }
    
    //MARK:-获取相册所有视频
    func getAllVideo(videoHandler: @escaping (_ assetArr: [PHAsset]) -> Void) {
        weak var weakSelf = self
        AuthorizationManager.photoAlbum {
            let assetArr: [PHAsset] = weakSelf!.getAlbumVideos()
            videoHandler(assetArr)
        }
    }
}

//MARK:*******************获取相册所有图片相关代码*******************
extension AlbumManager {
    //MARK:-先获取所有相册，然后获取相机胶卷
        private func getCameraRoll() -> [PHAsset] {
            // 所有智能相册集合(系统自动创建的相册)
            let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            
            //遍历得到每一个相册
            var photoAlbum: PHAssetCollection?
            for i in 0 ..< smartAlbums.count {
                //相册的名字是相机交卷，这里面包含了所有的资源，包括照片、视频、gif。 注意相册名字中英文
                if smartAlbums[i].localizedTitle == "相机胶卷" ||
                    smartAlbums[i].localizedTitle == "Camera Roll" ||
                    smartAlbums[i].localizedTitle == "最近项目" ||
                    smartAlbums[i].localizedTitle == "Recents"{
                    photoAlbum = smartAlbums[i]
                }
            }
            if photoAlbum == nil { return [PHAsset]() }
            
            return getPHAssetsFromAlbum(photoAlbum!)
        }
    
    //MARK:-获取相机胶卷的PHAsset集合(只选照片)
       private func getPHAssetsFromAlbum(_ collection: PHAssetCollection) -> [PHAsset] {
           // 存放所有图片对象
           var assetArr: [PHAsset] = []
           
           //时间排序、只选照片
           let options = PHFetchOptions.init()
           options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
           options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
           
           // 获取所有图片资源对象
           let results: PHFetchResult = PHAsset.fetchAssets(in: collection, options: options)
           
           // 遍历，得到每一个图片资源asset，然后放到集合中
           results.enumerateObjects { (asset, index, stop) in
               assetArr.append(asset)
           }
           
           return assetArr
       }
       
       //MARK:-根据PHAsset获取原图片信息
       func getImageDataFromPHAsset(_ asset: PHAsset, photoHandler: @escaping (_ imageData: Data?) -> Void) {
           
           let option: PHImageRequestOptions = PHImageRequestOptions.init()
           option.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
           option.resizeMode = PHImageRequestOptionsResizeMode.fast
           
           PHImageManager.default().requestImageData(for: asset, options: option) { (imageData, imageName, info, parameter) in
               photoHandler(imageData)
           }
       }
}

//MARK:*******************获取相册所有视频相关代码*******************
extension AlbumManager {
    //MARK:-先获取所有相册，然后获取视频相册
        private func getAlbumVideos() -> [PHAsset] {
            // 所有智能相册集合(系统自动创建的相册)
            let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumVideos, options: nil)
            
            //遍历得到每一个相册
            var photoAlbum: PHAssetCollection?
            for i in 0 ..< smartAlbums.count {
                //相册的名字是相机交卷，这里面包含了所有的资源，包括照片、视频、gif。 注意相册名字中英文
                if smartAlbums[i].localizedTitle == "视频" || smartAlbums[i].localizedTitle == "Videos" {
                    photoAlbum = smartAlbums[i]
                }
            }
            if photoAlbum == nil { return [PHAsset]() }
            
            return getVideosFromAlbum(photoAlbum!)
        }
        
        //MARK:-获取视频相册的PHAsset集合(只选视频)
        private func getVideosFromAlbum(_ collection: PHAssetCollection) -> [PHAsset] {
            // 存放所有图片对象
            var assetArr: [PHAsset] = []
            
            //时间排序、只选照片
            let options = PHFetchOptions.init()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
            
            // 获取所有图片资源对象
            let results: PHFetchResult = PHAsset.fetchAssets(in: collection, options: options)
            
            // 遍历，得到每一个图片资源asset，然后放到集合中
            results.enumerateObjects { (asset, index, stop) in
                assetArr.append(asset)
            }
            
            return assetArr
        }
    
    //MARK:-根据PHAsset获取视频信息
        func getVideoDataFromPHAsset(_ asset: PHAsset, videoHandler: @escaping (_ videoData: Data) -> Void) {
            
            let option: PHVideoRequestOptions = PHVideoRequestOptions.init()
            option.deliveryMode = .automatic
            option.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { (avasset, audioMix, info) in

                guard let avURLAsset = avasset as? AVURLAsset else {
                    return
                }
                guard let data = try? Data.init(contentsOf: avURLAsset.url) else {
                    return
                }
                videoHandler(data)
            }
        }
}
