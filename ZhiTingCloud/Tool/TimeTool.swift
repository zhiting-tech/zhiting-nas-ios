//
//  TimeTool.swift
//  ZhiTingCloud
//
//  Created by zy on 2021/6/9.
//

import UIKit

class TimeTool: NSObject {
    
    //时间戳转成字符串
    static func timeIntervalChangeToTimeStr(timeInterval:Double, _ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let date:Date = Date.init(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: date as Date)
    }
    
    //MARK:- 字符串转时间戳
    static func timeStrChangeTotimeInterval(time:String ,_ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> String {
           if time.isEmpty {
               return ""
           }
           let format = DateFormatter.init()
           format.dateStyle = .medium
           format.timeStyle = .short
           if dateFormat == nil {
               format.dateFormat = "yyyy-MM-dd HH:mm:ss"
           }else{
               format.dateFormat = dateFormat
           }
           let date = format.date(from: time)
           return String(date!.timeIntervalSince1970)
       }
    
    // 时间间隔
    static func TimeInterval(FromTime:String) -> CGFloat{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //当前时间
        let time = dateFormatter.string(from: Date())
        //计算时间差
        let timeNumber = Int(dateFormatter.date(from: time)!.timeIntervalSince1970-dateFormatter.date(from: FromTime)!.timeIntervalSince1970)
        
        let timeInterval:CGFloat = CGFloat(timeNumber)/3600.0
        
        return timeInterval
    }
}

class ZTCTool: NSObject {
    
    static func convertFileSize(size:Int) -> String{
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["B", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue >= 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
    static func fileImageBy(fileName:String) -> UIImage {
        let fileTypeStrs = fileName.components(separatedBy: ".")
        switch fileTypeStrs.last?.lowercased() {
        
        case "doc","docx" :
            
            return UIImage.assets(.document_icon) ?? UIImage()
            
        case "ppt", "pptx" :
            
            return UIImage.assets(.ppt_icon) ?? UIImage()
            
        case "aac", "ac3", "aif", "aifc", "aiff", "amr", "caf", "cda", "fiv", "flac", "m4a", "m4b", "oga", "ogg", "sf2", "sfark", "voc", "wav", "weba", "mp3", "mid", "wma", "ra" :
            
            return UIImage.assets(.music_icon) ?? UIImage()
            
        case "psd", "pdd", "psdt", "psb", "bmp", "rle", "dib", "gif", "dcm", "dc3", "dic", "eps", "iff", "tdi", "jpg", "jpeg", "jpf", "jpx", "jp2", "j2c", "j2k", "jpc", "jps", "pcx", "pdp", "raw", "pxr", "png", "pbm", "pgm", "ppm", "pnm", "pfm", "pam", "sct", "tga", "vda", "icb", "vst", "tif", "tiff", "mpo", "heic" :
            
            return UIImage.assets(.picture_icon) ?? UIImage()
            
        case "mp4", "m4v", "avi", "mkv", "mov", "mpg", "mpeg", "vob", "ram", "rm", "rmvb", "asf", "wmv", "webm", "m2ts", "movie" :
            
            return UIImage.assets(.video_icon) ?? UIImage()
            
        case "rar", "zip", "0", "000", "001", "7z", "ace", "ain", "alz", "apz", "ar", "arc", "ari", "arj", "axx", "bh", "bhx", "boo", "bz", "bza", "bz2", "c00", "c01", "c02", "cab", "car", "cbr", "cbz", "cp9", "cpgz", "cpt", "dar", "dd", "dgc", "efw", "f", "gca", "gz", "ha", "hbc", "hbc2", "hbe", "hki", "hki1", "hki2", "hki3", "hpk", "hyp", "ice", "imp", "ipk", "ish", "jar", "jgz", "jic", "kgb", "kz", "lbr", "lha", "lnx", "lqr", "lz4", "lzh", "lzm", "lzma", "lzo", "lzx", "md", "mint", "mou", "mpkg", "mzp", "nz", "p7m", "package", "pae", "pak", "paq6", "paq7", "paq8", "par", "par2", "pbi", "pcv", "pea", "pf", "pim", "pit", "piz", "puz", "pwa", "qda", "r00", "r01", "r02", "r03", "rk", "rnc", "rpm", "rte", "rz", "rzs", "s00", "s01", "s02", "s7z", "sar", "sdn", "sea", "sfs", "sfx", "sh", "shar", "shk", "shr", "sit", "sitx", "spt", "sqx", "sqz", "tar", "taz", "tbz", "tbz2", "tgz", "tlz", "tlz4", "txz", "uc2":
            
            return UIImage.assets(.zip_icon) ?? UIImage()
            
        case "pdf" :
            
            return UIImage.assets(.pdf_icon) ?? UIImage()
            
        case "txt" :
            
            return UIImage.assets(.txt_icon) ?? UIImage()
            
        case "xls", "xlsx" :
            
            return UIImage.assets(.excel_icon) ?? UIImage()
            
        default:
            
            return UIImage.assets(.unFindFile_icon) ?? UIImage()
        }
        
        
    }
}

