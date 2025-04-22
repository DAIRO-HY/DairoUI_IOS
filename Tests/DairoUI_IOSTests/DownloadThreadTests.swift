import Testing
@testable import DairoUI_IOS

@Test func download() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    print("-->start")
    downloadThreaddownload()
    try? await Task.sleep(nanoseconds: 100_000_000_000)
    print("-->end")
}

func downloadThreaddownload(){
    let info = DownloadingInfo(path: "/Users/zhoulq/Documents/IMG_2307.jpg", url: "http://localhost:8031/d/oq8221/IMG_2307.jpg?wait=0")
    let dt = DownloadThread(info){ err in
        if err != nil{
            debugPrint("下载出错:\(err)")
        } else {
            debugPrint("下载完成")
        }
    }
    
    //设置下载进度
    dt.setProgressFunc{
        print("当前下载进度:\($1)/\($0)  \($2)")
    }
    dt.download()
}
