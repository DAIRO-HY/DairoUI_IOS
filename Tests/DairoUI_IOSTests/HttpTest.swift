import Foundation

import Testing
@testable import DairoUI_IOS

@Test func httpTest() async throws {
    print("-->start")
    req(0)
    try? await Task.sleep(nanoseconds: 100000_000_000_000)
    print("-->end")
}

private let COUNT = 10000

private func req(_ count: Int){
    if count >= COUNT{
        return
    }
    print(count)
    let url = "http://localhost:8031/d/oq8221/WechatIMG2.jpg?wait=1"
    
    let http = HttpTest(url)
    http.finish{ [weak http] err in
        if err != nil{
            print(err)
        }
        Task.detached{
            //            try? await Task.sleep(nanoseconds: 1_000_000)
            req(count + 1)
        }
    }
    http.request()
    withExtendedLifetime(http) {}
}

final class HttpTest: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate, @unchecked Sendable {
    private let url: String
    private var mURLSession: URLSession? = nil
    private var httpTask: URLSessionDataTask? = nil
    private var successFunc: ((_ data: Data) -> ())?
    private var finishFunc: ((_ error:Error?) -> ())?
    init(_ url: String) {
        self.url = url
    }
    func finish(_ block: @escaping (_ error: Error?) -> Void){
        self.finishFunc = block
        
    }
    func request(_ isReadToEnd: Bool = true){
        let config = URLSessionConfiguration.default
        
        //禁用缓存
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        var request = URLRequest(url: URL(string: self.url)!)
        
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: delegateQueue)
        self.httpTask = urlSession.dataTask(with: request)
        self.mURLSession = urlSession
        self.httpTask!.resume()
    }
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        completionHandler(.allow)
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.successFunc?(data)
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.mURLSession?.invalidateAndCancel()
        self.finishFunc?(error)
        self.mURLSession = nil
        self.httpTask = nil
    }
    deinit {
        debugPrint("-->HttpTest.deinit")
    }
}
