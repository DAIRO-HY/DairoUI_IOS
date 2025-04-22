//
//  DownloadThread.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//
import Foundation

///文件下载任务
///`TODO:是否需要判断同名文件已经在下载中
public class DownloadThread{
    
    public static let DOWNLOADING_FILE_EXT = ".downloading"
    
    /**
     * 进度回调函数类型别名
     */
    public typealias DownloadThreadProgressFuncType = ((_ total: Int64, _ downloaded: Int64, _ speed: Int64) -> ())
    
    /**
     * 同步锁
     */
    private let lock = NSLock()
    
    ///下载中的文件信息
    let info: DownloadingInfo
    
    /**
     * 失败重试最大次数
     */
    private let ERROR_TRY_MAX_TIMES = 10
    
    /**
     * 文件大小总大小
     */
    var total: Int64 = -1
    
    /**
     * 请求URL
     */
    //    private let url: String
    
    /**
     * 已经下载大小
     */
    private var downloadedSize: Int64 = 0
    
    /**
     * 下载任务
     */
    private var httpUtil: HttpUtil? = nil
    
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
    
    /**
     * 读取数据之前回调函数
     */
    private var beforeFunc: ((_ statusCode: Int) -> Bool)?
    
    /**
     * 进度回调函数
     */
    private var progressFunc: DownloadThreadProgressFuncType?
    
    /**
     * 下载完成回调函数
     */
    private let finishFunc: (_ info: DownloadingInfo, _ error: Error?) -> ()
    
    init(_ info: DownloadingInfo, finishFunc: @escaping (_ info: DownloadingInfo, _ error: Error?) -> ()) {
        self.info = info
        self.finishFunc = finishFunc
    }
    
    /**
     * 设置下载进度回调函数
     */
    func setProgressFunc(_ progressFunc: DownloadThreadProgressFuncType?) {
        self.progressFunc = progressFunc
    }
    
    /**
     * 停止下载进度监听
     */
    func stopProgress(){
        
        //@TODO: 高并发模式会不会导致调用的地方发生空指针异常,待测试
        self.progressFunc = nil
    }
    
    ///接收到消息时的回调
    //  Future<void> _receive(Object? msg) async {
    //    if (msg == "PAUSE") {
    //      //强行停止
    //      this.isBreak = true;
    //      this._client?.close(force: true);
    //    }
    //  }
    
    ///开始上传任务
    func download(){
        self.start()
        //    try {
        //      await this._start();
        //
        //      //上传完成
        //      this.sendPort.send(DownloadMessage(DownloadCode.OK));
        //    } catch (e) {
        //      if (this.isBreak) {
        //        //被强行停止
        //        this.sendPort.send(DownloadMessage(DownloadCode.FAIL, "PAUSE"));
        //        return;
        //      }
        //      //上传出错
        //      final String error;
        //      if (e is SocketException) {
        //        error = "网络连接失败";
        //      } else if (e is HttpException) {
        //        error = "网络连接中断";
        //      } else {
        //        error = e.toString();
        //      }
        //      final message = DownloadMessage(DownloadCode.FAIL, error);
        //      this.sendPort.send(message);
        //    } finally {
        //      this.receivePort.close();
        //    }
    }
    
    ///开始下载
    private func start() {
        if FileManager.default.fileExists(atPath: self.info.savePath) {//文件已经下载完成,无需重新下载
            
            //回调下载结束函数
            self.finishFunc(self.info, nil)
            return
        }
        
        if FileManager.default.fileExists(atPath: self.info.downloadingPath) {//下载临时文件已经存在,读取已经下载的大小继续下载
            
            //得到已下载大小
            self.downloadedSize = FileUtil.getFileSize(self.info.downloadingPath)!
        } else {
            self.downloadedSize = 0
        }
        
        let http = HttpUtil(self.info.url)
            .before(self.before)
            .success(self.success)
            .finish(self.finish)
        http.method = "GET"
        
        //从指定位置开始下载
        http.setHeader("Range", "bytes=\(self.downloadedSize)-")
        
        //设置超时
        //        http.connectTimeout = 3000
        //        http.readTimeout = 10 * 1000
        
        lock.lock()
        if self.isCancel{//并发操作时,有可能cancel函数被先调用
            lock.unlock()
            http.close()
            self.finish(HttpUtil.CancelError())
            return
        }
        self.httpUtil = http
        http.request(false)
        lock.unlock()
    }
    
    /// 从响应请求头中获取视频文件总长度 contentLength
    private func before(_ statusCode:Int)-> Bool {
        if statusCode == 416 {//文件可能已经下载完成
            //            self.size = self.downloadedSize
            return false
        }
        if (statusCode != 200 && statusCode != 206) {//206代表部分数据,头部指定位置
            //@TODO: 下载失败,这里应该记录具体错误信息
            return false
        }
        
        //获取到文件总大小
        self.total = self.httpUtil!.contentLengthLong + self.downloadedSize
        if !FileManager.default.fileExists(atPath: self.info.downloadingPath) {//文件不存在
            let parentPath = FileUtil.getParentPath(self.info.downloadingPath)
            if !FileManager.default.fileExists(atPath: parentPath){//创建文件夹
                FileUtil.mkdirs(parentPath)
            }
            
            //创建文件,在写入文件之前必须要先创建一个空文件
            FileManager.default.createFile(atPath: self.info.downloadingPath, contents: nil)
        }
        
        //初始化一个可以写文件时工具
        self.writeFileHandle = FileHandle(forWritingAtPath: self.info.downloadingPath)
        
        //将指针移动到文件末尾
        try! self.writeFileHandle?.seekToEnd()
        return true
    }
    
    /**
     * 保存数据
     */
    private func success(_ data: Data) {
        
        //写入文件
        self.writeFileHandle?.write(data)
        
        //记录已经下载数据大小
        self.downloadedSize += Int64(data.count)
        
        //得到毫秒数
        let nowTime = Int64(Date().timeIntervalSince1970 * 1000)
        if nowTime - self.lastWriteDataTime >= 500 {//0.5秒的间隔广播一次
            
            //广播当前下载进度
            //            EventUtil.post(EventCode.DOWNLOAD_PROGRESS, (self.downloadedSize, self.size))
            
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
            
            //回调下载进度
            self.progressFunc?(self.total, self.downloadedSize, speed)
        }
    }
    
    /**
     * 最终执行
     */
    private func finish(_ err: Error?) {
        var err = err
        if err == nil{
            
            //当前下载的文件大小
            let downloadedFileSize = FileUtil.getFileSize(self.info.downloadingPath)!
            if self.total != downloadedFileSize{//如果下载的文件不是一个完成的文件,则删除文件
                try? FileManager.default.removeItem(atPath: self.info.downloadingPath)
                err = DownloadError.incomplete
            } else {
                
                //文件重命名
                FileUtil.rename(source: self.info.downloadingPath, target: self.info.savePath)
            }
        }
        self.isFinish = true
        
        //完成之后回调下载进度,避免出现下载进度无法100%
        self.progressFunc?(self.total, self.downloadedSize, 0)
        
        //关闭文件操作
        try? self.writeFileHandle?.close()
        self.writeFileHandle = nil
        
        //关闭请求资源
        self.httpUtil?.close()
        
        self.httpUtil = nil
        
        //回调下载结束函数
        self.finishFunc(self.info, err)
    }
    
    /**
     * 取消下载
     */
    func cancel(){
        lock.lock()
        self.isCancel = true
        self.httpUtil?.close()
        lock.unlock()
    }
    
    deinit {
        debugPrint("-->DownloadThread.deinit")
    }
}
