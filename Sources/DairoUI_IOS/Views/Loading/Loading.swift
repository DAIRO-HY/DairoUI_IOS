import SwiftUI

public enum Loading{
    private static let lock = NSLock()
    
    /**
     * 记录显示次数
     */
    nonisolated(unsafe) private static var count = 0
    
    /**
     * 显示次数+1
     */
    public static func show(){
        lock.lock()
        count += 1
        Task{
            await notifyUI(Loading.count > 0)
        }
        lock.unlock()
    }
    
    /**
     * 显示次数-1
     */
    public static func hide(){
        lock.lock()
        count -= 1
        Task{
            await notifyUI(Loading.count > 0)
        }
        lock.unlock()
    }
    
    /**
     通知UI刷新
     */
    @MainActor
    private static func notifyUI(_ flag: Bool) {
        RootViewManager.top.showWaiting = flag
    }
}
