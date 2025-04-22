import Testing
import Foundation
@testable import DairoUI_IOS


@Test func deinitTest() async throws {
    callDeinitTest3()
    try? await Task.sleep(nanoseconds: 10_000_000_000)
    print("-->end")
}

func callDeinitTest1(){
    print("-->call1:start")
    var dt = DeinitTest()
    print("-->call1:\(dt.i)")
    print("-->call1:end")
}

func callDeinitTest2(){
    print("-->call2:start")
    var dt: DeinitTest? = DeinitTest()
    print("-->call2:\(dt!.i)")
    dt = nil
    print("-->call2:end")
}

func callDeinitTest3(){
    print("-->call3:start")
    let info = DownloadingInfo(path: "/Users/zhoulq/Documents/WechatIMG2.jpg", url: "http://localhost:8031/d/oq8221/WechatIMG2.jpg?wait=0")
    var dt: DownloadThread? = DownloadThread(info){err in}
    dt?.download()
    print("-->call3:\(dt!)")
//    dt?.cancel()
    dt = nil
    print("-->call3:end")
}

func callDeinitTest4(){
    print("-->call3:start")
    var http:HttpUtil? = HttpUtil("http://localhost:8031/d/oq8221/IMG_2307.jpg?wait=0")
//        .before{ code in
//            true
//        }
//        .success{data in
//            
//        }
//        .finish{err in
//            
//        }
        .request(false)
    
    let start = Date()
    while Date().timeIntervalSince(start) < 1.0 {
        // busy-wait 1 秒
    }
    http?.close()
    print("-->call3:\(http)")
    http = nil
    print("-->call3:end")
}

class DeinitTest{
    let i = 0
    
    deinit{
        print("-->DeinitTest:deinit")
    }
}
