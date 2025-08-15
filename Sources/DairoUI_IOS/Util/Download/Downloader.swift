//
//  CacheImageDownloader.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//
import Foundation

///文件下载失败错误
public enum DownloaderError: Error {
    case error(_ msg: String)
}

/// 下载通知状态
public enum DownloadNotify: Sendable{
    
    /// 下载暂停
    case pause
    
    /// 下载完成
    case finish
    
    /// 下载进度
    case progress
}

///文件下载任务
public class Downloader: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate,@unchecked Sendable{
    
    /// 下载中的文件后缀
    public static let DOWNLOADING_FILE_EXT = ".downloading"
    
    //当前正在下载的id,防止同一个文件重复下载
    nonisolated(unsafe)  static var downloading = Set<String>()
    private static let downloadingLock = NSLock()
    
    /// 下载任务
    private var httpTask: URLSessionDataTask? = nil
    
    /// 文件id
    private let id: String
    
    /// 下载url
    private let url: String
    
    /// 文件保存路径
    private let path: String
    
    /// 完成之后的回调函数
    private let finishFunc: (String, Error?) -> Void
    
    /**
     * 失败重试最大次数
     */
    private let ERROR_TRY_MAX_TIMES = 10
    
    /// 网络请求但会状态
    private var httpStatusCode = -1
    
    /**
     * 文件大小总大小
     */
    var total: Int64 = -1
    
    /**
     * 已经下载大小
     */
    private var downloadedSize: Int64 = 0
    
    /**
     * 标记是否已经被取消
     */
    private var isCancel = false
    
    /**
     * 保存文件操作
     */
    private var writeFileHandle: FileHandle? = nil
    
    /**
     * 下载失败重试次数
     */
    //    private var errorTryTimes: Int
    
    /**
     * 下载错误信息
     */
    //    var error: Error? = nil
    
    /**
     * 用来记录最后一次写入数据的时间
     */
    private var lastWriteDataTime: Int64 = 0
    
    //上回统计的下载大小,用来计算网速
    private var preDownloadedSize:Int64 = 0
    
    /**
     * 是否已经完成(有可能是报错了结束的)
     */
    var isFinish = false
    
    //记录请求次数
    private var repeatCount = 0
    
    //记录错误次数
    private var errorCount = 0
    
    /// 初始化函数
    /// - Parameter id: 文件唯一id
    /// - Parameter url: 下载地址
    public init(_ id: String,_ url: String, finishFunc: @escaping (String, Error?) -> Void) {
        self.id = id
        self.url = url
        self.finishFunc = finishFunc
        self.path = Downloader.getPath(id)
    }
    
    /// 开始下载
    public func download(){
        if FileManager.default.fileExists(atPath: self.path) {//文件已经下载完成,无需重新下载
            
            //回调下载结束函数
            self.notify(.finish)
            Task.detached{//这里一定要异步,否则会造成死锁
                self.finishFunc(self.id, nil)
            }
            return
        }
        Downloader.downloadingLock.lock()
        if Downloader.downloading.contains(self.id){//已经在下载
            Downloader.downloadingLock.unlock()
            self.notify(.finish, DownloaderError.error("防止重复下载"))
            Task.detached{//这里一定要异步,否则会造成死锁
                self.finishFunc(self.id, DownloaderError.error("禁止重复下载"))
            }
            return
        }
        Downloader.downloading.insert(self.id)
        Downloader.downloadingLock.unlock()
        //        if let path = DownloadDBUtil.selectPathById(id){//该下载文件已经存在,继续下载
        //            self.path = path
        //        } else {//文件不存在,添加文件
        //            self.path = Downloader.savePath
        //            try! DownloadDBUtil.insert(id, self.path)
        //        }
        if FileManager.default.fileExists(atPath: self.path + Downloader.DOWNLOADING_FILE_EXT) {//临时文件已经存在,读取已经下载的大小继续下载
            
            //得到已下载大小
            self.downloadedSize = FileUtil.getFileSize(self.path + Downloader.DOWNLOADING_FILE_EXT)!
        } else {
            self.downloadedSize = 0
        }
        self.request()
    }
    
    
    /// 发起请求
    private func request(){
        let config = URLSessionConfiguration.default
        
        //请求链接超时设置
        config.timeoutIntervalForRequest = TimeInterval(30)
        
        //这个参数表示在接收到服务器的第一个字节之后，从服务器接收到完整的响应数据的最大时间间隔。如果在该时间间隔内没有接收到完整的响应数据，会触发资源超时错误。默认值为 7 天（即 604800 秒）。你可以根据需要将其设置为适当的值，以便在接收响应数据花费过长时间时终止请求。
        config.timeoutIntervalForResource = TimeInterval(30)
        
        //警用缓存
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        var request = URLRequest(url: URL(string: self.url)!)
        request.httpMethod = "GET"
        
        //添加请求头部信息
        request.setValue("bytes=\(self.downloadedSize)-", forHTTPHeaderField: "Range")
        
        //开启新的回话
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.httpTask = urlSession.dataTask(with: request)
        
        //发起请求
        self.httpTask!.resume()
    }
    
    
    /// 从响应请求头中获取视频文件总长度 contentLength
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let httpResponse = response as? HTTPURLResponse else{
            completionHandler(.cancel)
            return
        }
        
        //状态码
        self.httpStatusCode = httpResponse.statusCode
        if self.httpStatusCode == 416 {//文件已经下载完成,无需继续
            self.total = self.downloadedSize
            completionHandler(.cancel)
            return
        }
        if (self.httpStatusCode != 200 && self.httpStatusCode != 206) {//206代表部分数据,头部指定位置
            //@TODO: 下载失败,这里应该记录具体错误信息
            completionHandler(.cancel)
            return
        }
        guard let contentLengthStr = httpResponse.allHeaderFields["Content-Length"] else{//头部信息中没有配置内容长度
            completionHandler(.cancel)
            return
        }
        
        //获取到文件总大小
        self.total = Int64(String(describing: contentLengthStr))! + self.downloadedSize
        if !FileManager.default.fileExists(atPath: self.path + Downloader.DOWNLOADING_FILE_EXT) {//文件不存在
            
            //创建文件,在写入文件之前必须要先创建一个空文件
            FileManager.default.createFile(atPath: self.path + Downloader.DOWNLOADING_FILE_EXT, contents: nil)
            
            //设置文件大小
            DownloadDBUtil.setSize(self.id, self.total)
        }
        
        //初始化一个可以写文件工具
        self.writeFileHandle = FileHandle(forWritingAtPath: self.path + Downloader.DOWNLOADING_FILE_EXT)
        
        //将指针移动到文件末尾
        try! self.writeFileHandle?.seekToEnd()
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        //写入文件
        self.writeFileHandle!.write(data)
        
        //记录已经下载数据大小
        self.downloadedSize += Int64(data.count)
        
        //得到毫秒数
        let nowTime = Int64(Date().timeIntervalSince1970 * 1000)
        if nowTime - self.lastWriteDataTime >= 500 {//0.5秒的间隔广播一次
            
            //本次下载的大小
            let currentDownloadSize = self.downloadedSize - self.preDownloadedSize
            
            //本次下载花费时间
            let currentDownloadTime = nowTime - self.lastWriteDataTime
            
            //下载速度
            let speed = currentDownloadSize / currentDownloadTime * 1000
            
            //下载百分比
            //            let downloadPersent = Int(Double(self.downloadedSize) / Double(self.size) * 100.0)
            //            EventUtil.post(EventCode.PLAYER_MSG,"缓冲:\(downloadPersent)%(\(speed.fileSize)/S)")
            self.lastWriteDataTime = nowTime
            self.preDownloadedSize = self.downloadedSize
            
//            let progressData:[Int64] = [self.total, self.downloadedSize, speed]
            
            //回调下载进度
            self.notify(.progress, [self.total, self.downloadedSize, speed])
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        task.cancel()
        session.invalidateAndCancel()
        self.httpTask = nil
        
        //        if let error = error{//如果有错误
        //            if let urlErr = error as? URLError{
        //                if urlErr.code.rawValue == -999{//用户已经取消
        //                    debugPrint(error)
        //                    self.finishFunc?(CancelError())
        //                    return
        //                }
        //            }
        //        }else{
        //            if self.isReadToEnd{//一次性把数据读完之后再回调
        //                self.successFunc?(self.data)
        //            }
        //        }
        //        self.finishFunc?(error)
        
        //关闭文件操作
        try? self.writeFileHandle?.close()
        self.writeFileHandle = nil
        
        var err = error
        if err != nil && self.httpStatusCode == 416{//代表这个文件已经下载完成
            err = nil
        }
        if err == nil{
            
            //当前下载的文件大小
            let downloadedFileSize = FileUtil.getFileSize(self.path + Downloader.DOWNLOADING_FILE_EXT)!
            if self.total != downloadedFileSize{//如果下载的文件不是一个完成的文件
                err = DownloaderError.error("文件不完整,已下载文件大小:\(downloadedFileSize.fileSize), 服务端文件大小:\(self.total.fileSize)")
            }
        }
        if err == nil{//如果没有下载错误,则将文件重命名
            
            //文件重命名
            try? FileManager.default.moveItem(at: URL(fileURLWithPath: self.path + Downloader.DOWNLOADING_FILE_EXT), to: URL(fileURLWithPath: self.path))
        }
        
        //移除正在下载
        Downloader.downloadingLock.lock()
        Downloader.downloading.remove(self.id)
        Downloader.downloadingLock.unlock()
        self.isFinish = true
        
        //完成之后回调下载进度,避免出现下载进度无法100%
        self.notify(.progress, [self.total, self.downloadedSize, 0])
        if let err = err as? URLError, err.code == .cancelled {//用户主动取消了请求
            
            //回调下载结束函数
            self.notify(.pause)
        } else {
            
            //回调下载结束函数
            self.notify(.finish, err)
        }
        self.finishFunc(self.id, err)
    }
    
    /// 发送通知
    ///
    /// - Parameter type:通知类型
    /// - Parameter value:参数值
    private func notify(_ type: DownloadNotify, _ value: Sendable? = nil){
        Task{ @MainActor in
            NotificationCenter.default.post(
                name: Notification.Name(self.id),
                object: nil,
                userInfo: ["key": type, "value": value]
            )
        }
    }
    
    /// 取消下载
    func cancel(){
        self.isCancel = true
        self.httpTask?.cancel()
    }
    
    //文件路径
    public static func getPath(_ id: String) -> String{
        return DownloadConst.saveFolder + "/" + id
    }
    
    //文件路径
    public static func getDownloadingPath(_ id: String) -> String{
        return DownloadConst.saveFolder + "/" + id + Downloader.DOWNLOADING_FILE_EXT
    }
    
    deinit {
        debugPrint("-->Downloader.deinit")
    }
}

//struct MyData: Sendable {
//    let type: DownloadNotify
//}
