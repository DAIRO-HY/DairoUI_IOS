import Foundation
/**
 * Toast弹出式消息工具类
 */
public enum Toast{
    
    ///Toast框逐渐消失的时间
    static let ANIMATION_LINEAR_TIME = 1
    
    /**
     * Toast弹出式消息ViewModel静态实例,方便全局控制
     */
    nonisolated(unsafe) static var mToastModel: ToastViewModel?
    
    /**
     * 本次要显示的消息
     */
    nonisolated(unsafe) static var toastMessage: ToastMessage?
    
    /**
     * 要显示的消息列表
     */
    nonisolated(unsafe) private static var toastMessageList = [ToastMessage]()
    
    private static let lock = NSLock()
    
    /**
     * 添加并显示消息
     */
    public static func show(_ msg: String, delay: Double = 1){
        lock.lock()
        Toast.toastMessageList.append(ToastMessage(delay: delay, message: msg))
        lock.unlock()
        if Toast.toastMessage != nil{
            return
        }
        next()
    }
    
    /**
     * 显示吓一跳消息
     */
    private static func next(){
        lock.lock()
        if Toast.toastMessageList.isEmpty{
            Toast.toastMessage = nil
            lock.unlock()
            Task.detached{
                await notifyUI()
            }
            return
        }
        let toastMessage = Toast.toastMessageList.first!
        Toast.toastMessage = toastMessage
        Toast.toastMessageList.removeFirst()
        lock.unlock()
        Task.detached{
            await notifyUI()
            await Task.sleep(UInt64(toastMessage.delay * 1_000_000_000) + UInt64(Toast.ANIMATION_LINEAR_TIME * 1_000_000_000))
            next()
        }
    }
    
    /**
     通知UI刷新
     */
    @MainActor
    private static func notifyUI() {
        RootViewManager.top.toastFlag = !RootViewManager.top.toastFlag
    }
}
