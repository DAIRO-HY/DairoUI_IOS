import Foundation

/**
 * Http请求工具类
 */
final public class HttpUtil: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate, @unchecked Sendable {
    
    /**
     * 请求URL
     */
    private let url: String
    
    /**
     * 当前URLSession
     */
    private var mURLSession: URLSession? = nil
    
    /**
     * 下载任务
     */
    private var httpTask: URLSessionDataTask? = nil
    
    /**
     * 连接超时设置（毫秒）
     */
    var connectTimeout:Int = Int.max
    
    /**
     * 读取超时设置（毫秒）
     */
    var readTimeout:Int = Int.max
    
    /**
     * 请求方式
     */
    var method = "GET"
    
    /**
     * 状态码
     */
    var statusCode = -1
    
    /**
     * 是否一次性把数据读完
     */
    private var isReadToEnd = true
    
    /**
     * 返回头部信息
     */
    var resHeader:[AnyHashable : Any]?
    
    /**
     * 读取数据之前回调函数
     */
    private var beforeFunc: ((_ statusCode: Int) -> Bool)?
    
    /**
     * 读取数据回调函数
     */
    private var successFunc: ((_ data: Data) -> ())?
    
    /**
     * 请求完成回调函数
     */
    private var finishFunc: ((_ error:Error?) -> ())?
    
    /**
     * 请求的头部信息
     */
    private var header = [String:String]()
    
    /**
     * 请求数据
     */
    private var requestBody = ""
    
    /**
     * 获取数据长度
     */
    var contentLengthLong: Int64{
        if let contentLenthStr = self.getResponseHeader("Content-Length"){
            return Int64(contentLenthStr)!
        }
        return -1
    }
    
    /**
     * 所有数据
     */
    private lazy var data: Data = {
        return Data()
    }()
    
    /**
     * 初始化
     */
    init(_ url: String) {
        self.url = url
    }
    
    /**
     * 设置头部信息
     */
    func setHeader(_ key: String,_ value: String){
        self.header[key] = value
    }
    
    /**
     * 设置读取数据前的回调函数
     */
    func before(_ block: @escaping (_ statusCode: Int) -> Bool) -> HttpUtil{
        self.beforeFunc = block
        return self
    }
    
    /**
     * 请求成功的回调函数
     */
    func success(_ block: @escaping (_ data: Data) -> Void) -> HttpUtil{
        self.successFunc = block
        return self
    }
    
    /**
     * 设置最终回调函数
     */
    func finish(_ block: @escaping (_ error: Error?) -> Void) -> HttpUtil{
        self.finishFunc = block
        return self
    }
    
    /**
     * 添加请求数据参数
     */
    func addParam(_ key: String, _ value: Codable){
        if let encode = String(describing: value).urlEncode {
            self.requestBody += key + "=" + encode + "&"
        }
    }
    
    /**
     * 设置请求数据参数
     */
    func setRequestBody(requestBody: String){
        self.requestBody = requestBody
    }
    
    /**
     * 发起请求
     * isReadToEnd 是否一次性读完所有数据
     */
    func request(_ isReadToEnd: Bool = true) -> HttpUtil{
        debugPrint("-->url:\(self.url)")
        self.isReadToEnd = isReadToEnd
        let config = URLSessionConfiguration.default
        
        //请求链接超时设置
        config.timeoutIntervalForRequest = TimeInterval(Float(self.connectTimeout) / 1000)
        
        //这个参数表示在接收到服务器的第一个字节之后，从服务器接收到完整的响应数据的最大时间间隔。如果在该时间间隔内没有接收到完整的响应数据，会触发资源超时错误。默认值为 7 天（即 604800 秒）。你可以根据需要将其设置为适当的值，以便在接收响应数据花费过长时间时终止请求。
        config.timeoutIntervalForResource = TimeInterval(Float(self.readTimeout) / 1000)
        
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        var request = URLRequest(url: URL(string: self.url)!)
        request.httpMethod = method
        
        //添加请求头部信息
        self.header.forEach { item in
            request.setValue(item.value, forHTTPHeaderField: item.key)
        }
        if !self.requestBody.isEmpty{
            request.httpBody = self.requestBody.data(using: .utf8)
        }
        
        //开启新的回话
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.httpTask = urlSession.dataTask(with: request)
        self.mURLSession = urlSession
        
        //发起请求
        self.httpTask!.resume()
        return self
    }
    
    /**
     * 同返回数据中获取头部信息
     */
    func getResponseHeader(_ key: String)->String?{
        guard let header = self.resHeader else{
            return nil
        }
        guard let value = header[key] else{
            return nil
        }
        return String(describing: value)
    }
    
    /// 从响应请求头中获取视频文件总长度 contentLength
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        let httpResponse = response as! HTTPURLResponse
        
        //状态码
        self.statusCode = httpResponse.statusCode
        
        //返回头部信息
        self.resHeader = httpResponse.allHeaderFields
        
        //执行读取数据前的回调
        let isAllow = self.beforeFunc?(self.statusCode) ?? true
        if isAllow{//继续读取数据
            completionHandler(.allow)
        } else {
            completionHandler(.cancel)
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.isReadToEnd{//一次性把数据读完之后再回调
            self.data += data
        }else{//实时返回读取到的数据
            self.successFunc?(data)
        }
        //        if self.isCancel{//如果已经取消了
        //            self.httpTask?.cancel()
        //        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.mURLSession?.invalidateAndCancel()
        if let error = error{//如果有错误
            if let urlErr = error as? URLError{
                if urlErr.code.rawValue == -999{//用户已经取消
                    debugPrint(error)
                    self.finishFunc?(CancelError())
                    return
                }
            }
        }else{
            if self.isReadToEnd{//一次性把数据读完之后再回调
                self.successFunc?(self.data)
            }
        }
        self.finishFunc?(error)
    }
    
    /**
     * 取消下载任务
     */
    func close() {
        self.httpTask?.cancel()
        
        //这里一定要执行,否则导致该类的实例永远不会被回收,导致内存溢出
        self.mURLSession?.invalidateAndCancel()
    }
    
    deinit {
        debugPrint("-->HttpUtil.deinit")
    }
    
    /**
     * 任务被取消异常
     */
    struct CancelError : Error{
    }
}
