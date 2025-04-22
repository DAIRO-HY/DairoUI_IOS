import Testing
import Foundation
@testable import DairoUI_IOS


@Test func nsLockTest() async throws {
    for _ in 1...5{
        Task {
            out1()
        }
    }

    try? await Task.sleep(nanoseconds: 100_000_000_000)
    print("-->end")
}

private let nslock = NSLock()
func out1() {
    nslock.lock()
    let start = Date()
    
    //模拟耗时任务,这里不能使用Task.sleep,因为这会释放执行权,并释放actor锁,无法真正模拟耗时任务
    while Date().timeIntervalSince(start) < 1.0 {
        // busy-wait 1 秒
    }
    print("out1-->\(Date())")
    nslock.unlock()
}
