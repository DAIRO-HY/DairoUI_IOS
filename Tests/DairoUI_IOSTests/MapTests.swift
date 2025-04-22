import Testing
import Foundation
@testable import DairoUI_IOS


actor MapLock {
    func sync(block: ()->Void) {
        block()
    }
}

let lock =  MapLock()

nonisolated(unsafe) var map = [String : Int]()
@Test func mapTest() async throws {
    Task {
        while true{
            await lock.sync {
                map["123"] = Int(Date().timeIntervalSince1970)
            }
        }
    }
    Task {
        while true{
            await lock.sync {
                map["1234"] = Int(Date().timeIntervalSince1970)
            }
        }
    }
    Task {
        while true{
            let value = map["123"]
            if value == 10{
                print(value)
            }
        }
    }
    try? await Task.sleep(nanoseconds: 100_000_000_000)
    print("-->end")
}
