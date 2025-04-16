//
//  DownloadThread.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//
import Foundation

///文件下载任务
class DownloadThread{
    
    /**
     * 进度回调函数类型别名
     */
    typealias progressFuncType = ((_ total: Int64, _ downloaded: Int64, _ speed: Int64) -> ())
    
    ///下载中的文件信息
    private let info: DownloadingInfo
    
    ///是否被强制中断
    var isBreak = false;
    
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
    var error: Error? = nil
    
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
    private var progressFunc: progressFuncType?

    /**
     * 下载完成回调函数
     */
    private let finishFunc: ((_ error:Error?) -> ())
    
    init(_ info: DownloadingInfo, finishFunc: @escaping ((_ error:Error?) -> ())) {
        self.info = info
        self.finishFunc = finishFunc
    }
    
    /**
     * 设置下载进度回调函数
     */
    func setProgressFunc(progressFunc: @escaping progressFuncType) {
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
    func download() {
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
        
        //当前下载文件
        //        let file = DownloadFile.getFilePath(self.info.url)
        
        if FileManager.default.fileExists(atPath: self.info.path) {//文件存在
            
            //得到已下载大小
            self.downloadedSize = FileUtil.getFileSize(self.info.path)!
        } else {
            self.downloadedSize = 0
        }
        
        //        //初始化一个可以写文件时工具
        //        self.writeFileHandle = FileHandle(forWritingAtPath: self.info.path)
        //
        //        //将指针移动到文件末尾
        //        try! self.writeFileHandle?.seekToEnd()
        
        //设置消息为正在下载
        //    final connctionMessage = DownloadMessage(DownloadCode.MESSAGE, "网络连接中");
        //    this.sendPort.send(connctionMessage);
        
        
        
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
        
        self.httpUtil = http
        http.request(false)
        
        //    var url = this.info.url;
        //    if(!url.startsWith("http")){
        //      url = this.domain + this.info.url;
        //    }
        //    final uri = Uri.parse(url);
        //    final client = HttpClient();
        //    this._client = client;
        
        //    IOSink? sink;
        //    try {
        //      final request = await client.openUrl("GET", uri);
        //
        //      //禁止重定向
        //      request.followRedirects = false;
        //      request.headers.set(HttpHeaders.rangeHeader, "bytes=${downloadedSize}-");
        //      if(this.info.token.isNotEmpty){//添加认证Token
        //        request.headers.set(HttpHeaders.cookieHeader, "token=${this.info.token}");
        //      }
        //      final response = await request.close();
        //      if (response.statusCode == 416) { //文件应该是已经下载完成
        //        //文件已经下载完成
        //        return;
        //      }
        //
        //      if (response.statusCode != 200 && response.statusCode != 206) {
        //        final body = await response.transform(utf8.decoder).join();
        //        //上传报错了
        //        throw Exception(body);
        //      }
        //
        //      //得到文件大小
        //      final size = response.contentLength + downloadedSize;
        //
        //      //当前时间戳
        //      var lastTime = DateTime
        //          .now()
        //          .millisecondsSinceEpoch;
        //
        //
        //      if (!file.existsSync()) { //文件不存在则创建文件
        //        file.createSync(recursive: true);
        //      }
        //
        //      //文件输出流
        //      sink = file.openWrite(mode: FileMode.append);
        //
        //      //最后一次记录的上传大小（用来计算网速）
        //      var lastDownloadSize = downloadedSize;
        //      await response.forEach((data) {
        //        sink!.add(data);
        //        downloadedSize += data.length;
        //        final curTime = DateTime
        //            .now()
        //            .millisecondsSinceEpoch;
        //        if (curTime - lastTime > 500) {
        //          //计算下载速度(Byte)
        //          final speed = (downloadedSize - lastDownloadSize) / (curTime - lastTime) * 1000;
        //
        //          //剩余时间(毫秒)
        //          final needTime = (size - downloadedSize) / speed * 1000;
        //
        //          //发送上传进度消息
        //          final message = DownloadMessage(DownloadCode.PROGRESS, [size, downloadedSize, speed.toInt(), needTime.toInt()]);
        //
        //          this.sendPort.send(message);
        //          lastDownloadSize = downloadedSize;
        //          lastTime = DateTime.now().millisecondsSinceEpoch;
        //          // print("${downloadedSize.dataSize}/${size.dataSize}");
        //        }
        //        if (this.isBreak) {
        //          //上传被强行停止了
        //          throw Exception();
        //        }
        //      });
        //
        //    } finally {
        //      await sink?.flush();
        //      await sink?.close();
        //      client.close();
        //    }
    }
    
    
    /// 从响应请求头中获取视频文件总长度 contentLength
    private func before(_ statusCode:Int)-> Bool {
        if statusCode == 416 {//文件可能已经下载完成
            //            self.size = self.downloadedSize
            self.isFinish = true
            return false
        }
        if (statusCode != 200 && statusCode != 206) {//206代表部分数据,头部指定位置
            //            EventUtil.post(EventCode.PLAYER_MSG, "采集出错:服务器状态码:\(statusCode)")
            //            self.error = DwonloadError.error("采集出错:服务器状态码:\(statusCode)")
            self.isFinish = true
            return false
        }
        self.total = self.httpUtil!.contentLengthLong
        //        self.errorTryTimes = 0
        //        if self.size == 0 {//文件大小未知,从头部获取文件文件大小
        //            let resRange = self.httpUtil!.getResponseHeader("Content-Range")
        //            if(resRange == nil){//文件可能已经下载完成,也可能该下载连接不支持断点下载,这里我们先按照下载完成来处理
        //                self.size = self.downloadedSize
        //                return false
        //            }
        //
        //            //文件大小 = 已经下载的大小 + 本次要下载的大小
        //            self.size = self.httpUtil!.contentLengthLong + self.downloadedSize
        //        }
        if (self.isCancel) {//下载被取消
            return false
        }
        if !FileManager.default.fileExists(atPath: self.info.path) {//文件不存在
            let parentPath = FileUtil.getParentPath(self.info.path)
            if !FileManager.default.fileExists(atPath: parentPath){//创建文件夹
                FileUtil.mkdirs(parentPath)
            }
            
            //创建文件,在写入文件之前必须要先创建一个空文件
            FileManager.default.createFile(atPath: self.info.path, contents: nil)
        }
        
        if (self.writeFileHandle == nil) {//初始化文件写入流
            
            //初始化一个可以写文件时工具
            self.writeFileHandle = FileHandle(forWritingAtPath: self.info.path)
            
            //将指针移动到文件末尾
            try! self.writeFileHandle?.seekToEnd()
        }
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
    private func finish(error: Error?) {
        
        //完成之后回调下载进度,避免出现下载进度无法100%
        self.progressFunc?(self.total, self.downloadedSize, 0)
        if error != nil{
            debugPrint(error)
        }
        
        //        if error is HttpUtil.CancelError {//下载被取消异常,什么也不做
        //            return
        //        }
        //        if !self.isCancel && error != nil && self.errorTryTimes < self.ERROR_TRY_MAX_TIMES{//允许重试
        //            self.errorTryTimes += 1
        //
        //            //间隔一段时间之后重试
        //            usleep(500000)//0.5秒
        //            EventUtil.post(EventCode.PLAYER_MSG, "网络连接失败,正在第\(self.errorTryTimes)次尝试")
        //            self.checkDownload()
        //            return
        //        }
        //        self.error = error
        //        if (error == nil) {
        //
        //            //广播当前下载进度
        //            EventUtil.post(EventCode.DOWNLOAD_PROGRESS, (self.downloadedSize, self.size))
        //            EventUtil.post(EventCode.PLAYER_MSG, "")//清除播放器信息
        //        } else {
        //            EventUtil.post(EventCode.PLAYER_MSG, "网络连接失败")
        //        }
        
        //关闭文件操作
        try? self.writeFileHandle?.close()
        self.isFinish = true
        
        //回调下载结束函数
        self.finishFunc(error)
    }
    
    /**
     * 取消下载
     */
    func cancel(){
        self.isBreak = true
        self.httpUtil?.cancel()
    }
}
