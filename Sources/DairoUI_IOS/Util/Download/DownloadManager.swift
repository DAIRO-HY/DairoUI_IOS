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
    nonisolated(unsafe) static var waitingId2url = [String : String]()
    
    /// 文件id => 下载请求数
    nonisolated(unsafe) static var id2count = [String : Int]()
    
    /// 文件ID  =>  正在下载
    nonisolated(unsafe) static var id2download = [String : Downloader]()
    
    /// 单线程并发锁
    private static let lock = NSLock()
    
    /// 记录本次打开app是否已经清理过缓存,控制缓存清理频率
    nonisolated(unsafe) private static var isClear = false
    
    /// 记录要更新最后使用时间的文件id
    nonisolated(unsafe) static var updateUseDateIds = Set<String>()
    
    ///最后一次更新文件使用时间的时间
    nonisolated(unsafe) private static var lastUpdateUseDate = Date()
    
    ///缓存需要更新最后使用时间的文件id数的最大件数
    private static let MAX_UPDATE_USE_DATE_COUNT = 500
    
    ///缓存需要更新最后使用时间的文件id的最大j间隔时间
    private static let MAX_UPDATE_USE_DATE_TIME = 1 * 60.0
    
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
    
    /// 添加下载,如果文件在缓存中,则将缓存标记为永久保存
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter url: 下载地址
    public static func save(_ list: [(id: String, url: String)]) {
        self.lock.lock()
        for (id, _) in list{
            
            //防止下载被缓存操作取消
            self.id2count[id] = 999999999
        }
        self.lock.unlock()
        try? DownloadDBUtil.addSave(list)
        
        //去下载等待中的任务
        self.loopDownloadByWaiting()
    }
    
    /// 循环下载排队中的任务
    public static func loopDownloadByWaiting(){
        self.lock.lock()
        for (id, url) in waitingId2url{
            if self.id2download.count >= DownloadConfig.maxCachingCount{//当前下载并发数已到上限
                break
            }
            
            //县添加到数据库
            try? DownloadDBUtil.addCache(id, url)
            if self.id2download[id] == nil{//这里需要先判断一下是否正在下载中,有可能永久保存下载正在进行
                
                //创建一个下载任务
                self.id2download[id] = Downloader(id, url)
                
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
            if self.id2download.count >= DownloadConfig.maxSavingCount{//当前下载并发数已到上限
                break
            }
            
            //防止下载被缓存操作取消
            self.id2count[needDownload.id] = 999999999
            
            //将文件标记为正在下载中
            DownloadDBUtil.setState(needDownload.id, 1)
            if self.id2download[needDownload.id] == nil{//这里需要先判断一下是否正在下载中,有可能缓存正在进行
                
                //创建一个下载任务
                self.id2download[needDownload.id] = Downloader(needDownload.id, needDownload.url)
                
                //开始下载
                self.id2download[needDownload.id]!.download()
            }
        }
        self.lock.unlock()
    }
    
    /// 取消下载
    /// 该函数只能取消临时缓存下载的任务,无法取消永久保存的下载任务
    /// - Parameter id: 文件id
    /// - Parameter isForce: 是否强制取消下载,忽略掉排队的任务
    public static func cancel(_ id: String, isForce: Bool = false) {
        self.lock.lock()
        guard let count = self.id2count[id] else{
            self.lock.unlock()
            return
        }
        if count == 1 || isForce{//如果当前只有一个下载线程或者强制取消,则结束掉下载任务
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
    
    /// 取消所有下载
    public static func cancelAll() {
        self.lock.lock()
        
        //将数据标记为暂停
        DownloadDBUtil.pauseAll()
        self.id2download.forEach{
            $0.value.cancel()
        }
        self.id2count.removeAll()
        self.waitingId2url.removeAll()
        self.lock.unlock()
    }
    
    /// 开始所有下载
    public static func startAll() {
        DownloadDBUtil.startAll()
    }
    
    /// 某个id下载完成(不代表下载成功)
    static func finish(_ id: String) {
        self.lock.lock()
        self.id2count.removeValue(forKey: id)
        self.id2download.removeValue(forKey: id)
        self.lock.unlock()
        
        //去下载等待中的任务
        self.loopDownloadByWaiting()
    }
    
    /// 删除一个文件
    /// - Parameter id : 文件id
    public static func delete(_ ids: [String]){
        if ids.isEmpty{
            return
        }
        
        //从数据库中删除数据
        DownloadDBUtil.delete(ids)
        ids.forEach{//取消下载
            self.cancel($0, isForce: true)
        }
        //取消网络请求需要一点时间,防止下载中的文件被占用导致删除失败
        Thread.sleep(forTimeInterval: 0.01)
        self.lock.lock()
        ids.forEach{
            
            //删除文件
            Downloader.delete($0)
        }
        self.lock.unlock()
    }
    
    /// 获取已经下载了的文件
    /// - Parameter id: 文件唯一id
    /// - Returns 文件路径
    public static func getDownloadedPath(_ id: String) -> String?{
        guard let path = Downloader.getFilePath(id) else{
            return nil
        }
        
        //设置最后使用时间
        self.setUseDate(id)
        
        //清理缓存
        self.clearCache()
        return path
    }
    
    /// 设置最后使用时间
    /// - Parameter id: 文件唯一id
    private static func setUseDate(_ id: String){
        self.lock.lock()
        if !self.updateUseDateIds.contains(id){//若文件id已经存在
            self.updateUseDateIds.insert(id)
        }
        if self.updateUseDateIds.count >= self.MAX_UPDATE_USE_DATE_COUNT || Date().timeIntervalSince(self.lastUpdateUseDate) > self.MAX_UPDATE_USE_DATE_TIME{//要更新的数量达到一定数量时,更新DB数据,控制更新频率
            
            //去更新
            DownloadDBUtil.updateUseDate(Array(self.updateUseDateIds))
            self.updateUseDateIds.removeAll()
            self.lastUpdateUseDate = Date()
        }
        self.lock.unlock()
    }
    
    /// 清除缓存
    private static func clearCache(){
        if self.isClear{// 每次打开APP清理一次
            return
        }
        self.isClear = true
        
        //得到配置的缓存保存期限
        let cacheSaveDay = DownloadConfig.cacheSaveDay
        let ids = DownloadDBUtil.selectIdByUsedDate(cacheSaveDay)
        
        //删除这些文件
        self.delete(ids)
    }
}
