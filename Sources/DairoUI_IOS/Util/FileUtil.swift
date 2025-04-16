//
// Created by user on 2023/07/28.
//

import Foundation
class FileUtil{
    
    /**
     * 程序启动时,先把需要的文件夹全部创建好
     */
    //    static func createFolder(){
    //
    //           //保存文件夹
    //           let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    //        guard let root = documentsDirectory?.path() else{
    //            return
    //        }
    //        self.mkdirs(root + "/music")
    //    }
    
    /**
     * 获取歌曲存储目录
     */
    static var musicFolderPath: String {
        
        //保存保存根目录
        let rootDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        //文件保存路径
        let musicDirectoryURL = rootDirectoryURL!.appendingPathComponent("music")
        return musicDirectoryURL.path
    }
    
    /**
     * 获取图片存储目录
     */
    static var imageFolderPath: String {
        
        //保存保存根目录
        let rootDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        //文件保存路径
        let musicDirectoryURL = rootDirectoryURL!.appendingPathComponent("image")
        return musicDirectoryURL.path
    }
    
    /**
     * 同文件的下载地址获取本地存储路径
     */
    static func getMusicURLByUrl(_ url: String) -> String{
        
        //设置保存文件目录
        return self.musicFolderPath + "/" + url.md5
    }
    
    /**
     * 创建多级目录
     */
    static func mkdirs(_ path: String) -> Bool{
        let url = URL(string: "file://" + path)!
        
        // 如果文件夹不存在，则创建
        do{
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }
    
    /**
     * 获取文件名
     * paramter path 当前文件路径
     */
    static func getFileName(_ path: String) -> String{
        
        //查找最后一个斜杠所在位置
        guard let lastSepIndex = path.lastIndex(of: "/") else {
            return ""
        }
        let substringAfterLastSlash = path[path.index(after: lastSepIndex)...]
        return String(substringAfterLastSlash)
    }
    
    /**
     * 获取文件上级目录
     * paramter path 当前文件路径
     */
    static func getParentPath(_ path: String) -> String{
        
        //查找最后一个斜杠所在位置
        guard let lastSepIndex = path.lastIndex(of: "/") else {
            return ""
        }
        let substringAfterLastSlash = path[...path.index(before: lastSepIndex)]
        return String(substringAfterLastSlash)
    }
    
    /**
     * 获取文件后缀
     * paramter path 当前文件路径
     */
    static func getExt(_ path: String) -> String{
        let filename = self.getFileName(path)
        
        //查找最后一个点所在位置
        guard let lastDotIndex = filename.lastIndex(of: ".") else {
            return ""
        }
        let substringAfterLastSlash = filename[filename.index(before: lastDotIndex)...]
        return String(substringAfterLastSlash)
    }
    
    /**
     * 获取文件大小
     */
    static func getFileSize(_ path: String) -> Int64?{
        guard let attr = try? FileManager.default.attributesOfItem(atPath: path) else{
            return nil
        }
        guard let fileSize = attr[FileAttributeKey.size] as? Int64 else{
            return nil
        }
        return fileSize
    }
    
    /**
     * 删除某个文件夹
     */
    static func deleteFolder(_ path: String) {
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: path)
    }
    
    /**
     * 歌曲文件缓存大小
     */
    static var musicCacheSize: UInt64 {
        
        //当前歌曲存储目录
        let path = self.musicFolderPath
        let total = self.calculateFolderSize(path)
        return total
    }
    
    /**
     * 图片缓存大小
     */
    static var imageCacheSize: UInt64 {
        
        //当前歌曲存储目录
        let path = self.imageFolderPath
        let total = self.calculateFolderSize(path)
        return total
    }
    
    /**
     * 递归获取文件夹大小
     */
    private static func calculateFolderSize(_ dirPath: String) -> UInt64 {
        let fileManager = FileManager.default
        var folderSize: UInt64 = 0
        
        //子目录(文件/及文件夹)
        guard let subList = try? fileManager.contentsOfDirectory(atPath: dirPath) else{
            return 0
        }
        for content in subList {
            
            //拼接子目录路径
            let contentPath = (dirPath as NSString).appendingPathComponent(content)
            var isDirectory: ObjCBool = false
            
            if fileManager.fileExists(atPath: contentPath, isDirectory: &isDirectory) {
                if isDirectory.boolValue {//如果是一个文件夹,则递归循环
                    folderSize += self.calculateFolderSize(contentPath)
                } else {//如果是文件,则累计文件大小
                    if let fileSize = try? fileManager.attributesOfItem(atPath: contentPath)[.size] as? UInt64 {
                        folderSize += fileSize
                    }
                }
            }
        }
        return folderSize
    }
    
    /**
     * 获取绝对路径
     */
    public static func getAbsPath(_ path: String) -> String?{
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsPath.appendingPathComponent(path)
            return fileURL.path
        }
        return nil
    }
}
