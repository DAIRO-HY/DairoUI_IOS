import Foundation

import Testing
@testable import DairoUI_IOS

@Test func httpTest2() async throws {
    print("-->start")
    call()
    try? await Task.sleep(nanoseconds: 100000_000_000_000)
    print("-->end")
}

private func call(){
    HttpTaskClass().req(0)
}

class HttpTaskClass{
    
    private let COUNT = 10000

    func req(_ count: Int){
        if count >= COUNT{
            return
        }
        print(count)
        let url = "http://localhost:8031/d/oq8221/WechatIMG2.jpg?wait=0&count=\(count)"
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            Task.detached{[self] in
                //            try? await Task.sleep(nanoseconds: 1_000_000)
                self.req(count + 1)
            }
        }.resume()
    }
    
    deinit{
        print("-->HttpTaskClass.deinit")
    }
}
