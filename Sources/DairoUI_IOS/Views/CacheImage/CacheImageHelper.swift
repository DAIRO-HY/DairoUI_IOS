//
//  CacheImageHelper.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//
import Foundation

struct DownloadWaiting{
    let url: String
    let folder: String
}

public class CacheImageHelper {
    
    /**
     * 最大下载上线
     */
    private static let maxDownloadingCount = 10
    
    /**
     * 当前url => 下载线程数
     */
    nonisolated(unsafe)  static var url2count = [String : Int]()
    
    /**
     * 当前url  =>  正在下载
     */
    nonisolated(unsafe)  static var url2downloading = [String : CacheImageDownloader]()
    
    /**
     * 单线程并发锁
     */
    private static let lock = NSLock()
    
    /**
     * 添加一个下载任务
     */
    public static func add(url: String, folder: String){
        
        //文件下载路径
        let filePath = CacheImageHelper.makeFilePath(url: url, folder: folder)
        
        //测试用
//        try? FileManager.default.removeItem(atPath: filepath)
//        if let path = CacheImageHelper.getDownloadedPath(url: url, folder: folder){
//            finishFunc(nil)
//            return
//        }
        debugPrint("文件下载目录:\(filePath)")
        CacheImageHelper.lock.lock()
        if let count = CacheImageHelper.url2count[url]{//如果url已经在下载中
            CacheImageHelper.url2count[url] = count + 1
        } else {
            
            //文件下载路径
            let path = CacheImageHelper.makeFilePath(url: url, folder: folder)
            let info = DownloadingInfo(url: url, savePath: path)
            let download = CacheImageDownloader(info)
            CacheImageHelper.url2count[url] = 1
            CacheImageHelper.url2downloading[url] = download
            download.download()
        }
        CacheImageHelper.lock.unlock()
    }
    
    /**
     * 取消下载
     */
    public static func cancel(_ url: String) {
        lock.lock()
        guard let count = CacheImageHelper.url2count[url] else{
            lock.unlock()
            return
        }
        if count == 1{//如果当前只有一个下载线程,则结束掉下载任务
            CacheImageHelper.url2downloading[url]?.cancel()
            CacheImageHelper.url2count.removeValue(forKey: url)
            CacheImageHelper.url2downloading.removeValue(forKey: url)
        } else {
            CacheImageHelper.url2count[url] = count - 1
        }
        lock.unlock()
    }
    
    /**
     * 某个url下载完成(不代表下载成功)
     */
    public static func finish(_ url: String) {
        lock.lock()
        CacheImageHelper.url2count.removeValue(forKey: url)
        CacheImageHelper.url2downloading.removeValue(forKey: url)
        lock.unlock()
    }
    
    /**
     * 获取已经下载了的文件
     */
    public static func getDownloadedPath(url: String, folder: String) -> String?{
        
        //拼接文件名
        let filepath = CacheImageHelper.makeFilePath(url: url, folder: folder)
        if FileManager.default.fileExists(atPath: filepath){
            return filepath
        }
        return nil
    }
    
    /**
     * 生成文件路径
     */
    private static func makeFilePath(url: String, folder: String) -> String{
        
        //获取下载文件的MD5
        let md5 = url.md5
        
        //拼接文件名
        return folder + "/" + md5
    }
}
