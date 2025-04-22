import Testing
import Foundation
@testable import DairoUI_IOS


nonisolated(unsafe) var str:String? = "sf"

private let strLock = NSLock()

func setValue(){
    while true{
        strLock.lock()
        str = "\(Date().timeIntervalSince1970)"
        strLock.unlock()
    }
}

func setNil(){
    while true{
        strLock.lock()
        str = nil
        strLock.unlock()
    }
}

func handle(){
    while true{
        strLock.lock()
        
        //如果不加锁,这里有可能会报错
        str?.append("234")
        strLock.unlock()
    }
}

@Test func nilTest() async throws {
    Task {
        setValue()
    }
    Task {
        setNil()
    }
    Task {
        handle()
    }
    try? await Task.sleep(nanoseconds: 100_000_000_000)
    print("-->end")
}
