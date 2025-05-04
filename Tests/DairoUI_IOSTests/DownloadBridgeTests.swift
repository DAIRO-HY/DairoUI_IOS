import Testing
@testable import DairoUI_IOS

@Test func DownloadBridgeDownloadTest() async throws {
    print("-->start")
    
    let url = "http://localhost:8031/d/oq8221/WechatIMG2.jpg?wait=1000"
    let folder = "/Users/zhoulq/Documents/11"
    
    if let path = DownloadBridge.getDownloadedPath(url: url, folder: folder){
        print("文件已经被下载:\(path)")
    }
    for i in 1...1{
        //try? await Task.sleep(nanoseconds: 1_0_000_000)
        let bridge = DownloadBridge.add(uid: "uid\(i)", url: url + "&" + String(i), folder: folder, progressFunc: {
            print("\(i):当前下载进度:\($1.fileSize)/\($0.fileSize)  \($2.fileSize)")
        }){ err in
            if err != nil{
                debugPrint("\(i):下载出错:\(err)")
            } else {
                debugPrint("\(i):下载完成")
            }
        }
//        bridge.download()
        
        //设置下载进度
//        bridge.setProgressFunc{
//            print("当前下载进度:\($1.fileSize)/\($0.fileSize)  \($2.fileSize)")
//        }
    }
    
    try? await Task.sleep(nanoseconds: 100000_000_000_000)
    print("-->end")
}
