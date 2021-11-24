//
//  ZTFileManager.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/5/26.
//

import UIKit

class ZTFileManager: NSObject {
    /*
     Documents：这个目录存放用户数据。存放用户可以管理的文件；iTunes备份和恢复的时候会包括此目录。
     Library:主要使用它的子文件夹,我们熟悉的NSUserDefaults就存在于它的子目录中。
     Library/Caches:存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除,“删除缓存”一般指的就是清除此目录下的文件。
     Library/Preferences:NSUserDefaults的数据存放于此目录下。
     tmp:App应当负责在不需要使用的时候清理这些文件，系统在App不运行的时候也可能清理这个目录。

     */
    
    
    /** 获取Document路径 */

    static func getDocumentPath() -> String{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }
    /** 获取Cache路径 */

    static func getCachePath() -> String{
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
    }
    /** 获取Library路径 */

    static func getLibraryPath() -> String{
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last!
    }
    /** 获取Tem路径 */

    static func getTemPath() -> String{
        return NSTemporaryDirectory()
    }
    
    /** 判断文件是否存在 */
    
    static func fileExists(path:String) -> Bool{
        if path.count == 0 {
            return false
        }
        return FileManager.default.fileExists(atPath: path)
    }
    
    /**
     *  创建文件夹
     *  @param fileName 文件名
     *  @param path 文件目录
    */
    
    static func createFolder(fileName:String, path:String){
        let manager = FileManager.default
        let folder = path + "/" + fileName
        print("文件夹:\(folder)")
        let exist = manager.fileExists(atPath: folder)
        if !exist {
            try! manager.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
        }
    }
        
        
    /**
     *  创建目录下文件
     *  @param fileName 文件名
     *  @param path 文件目录
     *
     *  @return 文件路径
     */
    static func createFile(fileName:String, path:String ){
        
    }
    
    /**
     写入文件

     @param filePath 文件路径
     @param textData 内容
     @return 是否成功
     */
    
    static func writeToFile(fileName:String,path: String, context:NSData){
        
    }
    
    /**
     根据路径删除对应文件

     @param filePath 文件路径
     @return 是否成功
     */
    static func deleteFromPath(path:String){
        
    }
    
    
}
