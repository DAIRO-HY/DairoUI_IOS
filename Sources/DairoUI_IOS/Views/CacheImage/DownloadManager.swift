//
//  DownloadManager.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/07.
//
import Foundation


/// 下载管理
public enum DownloadManager {
    
    /// 等待中的下载任务,用于临时缓存下载任务,如缓存图片等
    nonisolated(unsafe)  static var waitingId2url = [String : String]()
    
    /// 文件id => 下载请求数
    nonisolated(unsafe)  static var id2count = [String : Int]()
    
    /// 文件ID  =>  正在下载
    nonisolated(unsafe)  static var id2download = [String : Downloader]()
    
    /// 单线程并发锁
    private static let lock = NSLock()
    
    /// 添加一个缓存任务
    /// - Parameter id: 文件唯一id
    /// - Parameter url: 下载地址
    public static func cache(_ id: String, _ url: String){
        self.lock.lock()
        if let count = self.id2count[id]{//如果id已经在排队或者下载中
            self.id2count[id] = count + 1
        } else {//添加到排队下载
            self.id2count[id] = 1
            self.waitingId2url[id] = url
        }
        self.lock.unlock()
        
        //去下载等待中的任务
        self.loopDownloadByWaiting()
    }
    
    /// 添加一个下载任务(永久存储)
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter url: 下载地址
    public static func save(_ list: [(id: String, url: String)]) throws {
        self.lock.lock()
        for (id, _) in list{
            
            //防止下载被缓存操作取消
            self.id2count[id] = 999999999
        }
        self.lock.unlock()
        try DownloadDBUtil.addSave(list)
        
        //去下载等待中的任务
        self.loopDownloadByWaiting()
    }
    
    /// 循环下载排队中的任务
    private static func loopDownloadByWaiting(){
        self.lock.lock()
        for (id, url) in waitingId2url{
            if self.id2download.count >= DownloadConst.maxCachingCount{//当前下载并发数已到上限
                break
            }
            
            //县添加到数据库
            try? DownloadDBUtil.addCache(id, url)
            if self.id2download[id] == nil{//这里需要先判断一下是否正在下载中,有可能永久保存下载正在进行
                
                //创建一个下载任务
                self.id2download[id] = Downloader(id, url, finishFunc: self.finish)
                
                //开始下载
                self.id2download[id]!.download()
            }
            
            //从等待下载中移除该文件id
            self.waitingId2url.removeValue(forKey: id)
        }
        self.lock.unlock()
        
        /// 恢复数据库中准备下载的数据
        if self.waitingId2url.isEmpty{
            self.loopDownloadByDB()
        }
    }
    
    /// 循环下载数据库中需要下载的数据
    private static func loopDownloadByDB(){
            self.lock.lock()
            while true{
                guard let needDownload = DownloadDBUtil.selectOneForNeedDownload() else{//如果没有需要下载的文件
                    break
                }
                if self.id2download.count >= DownloadConst.maxSavingCount{//当前下载并发数已到上限
                    break
                }
                
                //防止下载被缓存操作取消
                self.id2count[needDownload.id] = 999999999
                
                //将文件标记为正在下载中
                DownloadDBUtil.updateState(needDownload.id, 1)
                if self.id2download[needDownload.id] == nil{//这里需要先判断一下是否正在下载中,有可能缓存正在进行
                    
                    //创建一个下载任务
                    self.id2download[needDownload.id] = Downloader(needDownload.id, needDownload.url, finishFunc: self.finish)
                    
                    //开始下载
                    self.id2download[needDownload.id]!.download()
                }
            }
            self.lock.unlock()
    }
    
    /// 取消下载
    /// 该函数只能取消临时缓存下载的任务,无法取消永久保存的下载任务
    public static func cancel(_ id: String) {
        self.lock.lock()
        guard let count = self.id2count[id] else{
            self.lock.unlock()
            return
        }
        if count == 1{//如果当前只有一个下载线程,则结束掉下载任务
            self.id2download[id]?.cancel()
            
            //已经在下载中的任务无需移除,Downloader的回调函数中会自动将其移除
            //self.id2download.removeValue(forKey: id)
            self.id2count.removeValue(forKey: id)
            self.waitingId2url.removeValue(forKey: id)
        } else {
            self.id2count[id] = count - 1
        }
        self.lock.unlock()
    }
    
    /// 某个id下载完成(不代表下载成功)
    private static func finish(_ id: String, _ err: Error?) {
        if let err = err as? DownloaderError{//如果发生错误
            if case let .error(msg) = err {
                DownloadDBUtil.updateState(id, 3, msg)
            }
        } else if let err {
            DownloadDBUtil.updateState(id, 3, err.localizedDescription)
        } else {//如果没有发生错误,则更新下载状态为下载完成
            DownloadDBUtil.updateState(id, 10)
        }
        self.lock.lock()
        self.id2count.removeValue(forKey: id)
        self.id2download.removeValue(forKey: id)
        self.lock.unlock()
        
        //去下载等待中的任务
        self.loopDownloadByWaiting()
    }
    
//    /// 获取已经下载了的文件
//    /// - Parameter id: 文件唯一id
//    /// - Returns 文件路径
//    public static func getDownloadedPath(_ id: String) -> String?{
//        guard let path = DownloadDBUtil.selectPathByCache(id) else{
//            return nil
//        }
//        if FileManager.default.fileExists(atPath: path){
//            return path
//        }
//        return nil
//    }
    
    /// 删除一个文件
    /// - Parameter id : 文件id
    public static func delete(_ id: String){
        DownloadDBUtil.delete(id)
    }
    
    /// 获取已经下载了的文件
    /// - Parameter id: 文件唯一id
    /// - Returns 文件路径
    public static func getDownloadedPath(_ id: String) -> String?{
        let path = Downloader.getPath(id)
        if FileManager.default.fileExists(atPath: path){
            return path
        }
        return nil
    }
}
