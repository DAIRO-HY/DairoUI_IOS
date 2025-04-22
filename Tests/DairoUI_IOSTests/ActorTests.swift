import Testing
import Foundation
@testable import DairoUI_IOS


actor ActorLock {
    func out1() {
        let start = Date()
        
        //模拟耗时任务,这里不能使用Task.sleep,因为这会释放执行权,并释放actor锁,无法真正模拟耗时任务
        while Date().timeIntervalSince(start) < 1.0 {
            // busy-wait 1 秒
        }
        print("out1-->\(Date())")
    }
    func out2() {
        let start = Date()
        
        //模拟耗时任务,这里不能使用Task.sleep,因为这会释放执行权,并释放actor锁,无法真正模拟耗时任务
        while Date().timeIntervalSince(start) < 1.0 {
            // busy-wait 1 秒
        }
        print("out2-->\(Date())")
    }
    static func out3() {
        let start = Date()
        
        //模拟耗时任务,这里不能使用Task.sleep,因为这会释放执行权,并释放actor锁,无法真正模拟耗时任务
        while Date().timeIntervalSince(start) < 1.0 {
            // busy-wait 1 秒
        }
        print("out3-->\(Date())")
    }
}


@Test func anyTest() async throws {
    let lock1 = ActorLock()
    let lock2 = ActorLock()
    for _ in 1...5{
        Task {
            await lock1.out1()
        }
    }
    for _ in 1...5{
        Task {
            await lock2.out2()
        }
    }
    for _ in 1...5{
        Task {
            await ActorLock.out3()
        }
    }
    try? await Task.sleep(nanoseconds: 100_000_000_000)
    print("-->end")
}
