import Foundation

/**
 * 分组线程锁
 */
class GroupSyncLock{
    
    /**
     * lockMap增/删/判断 同步锁
     */
    private let lock = NSObject()
    
    /**
     * 分组key
     */
    private var groupKeyMap = Dictionary<String,DispatchSemaphore>()
    
    /**
     * 分组同步线程锁
     */
    func synclock(_ key: String, _ block: () throws -> Void) throws{
        var waitLock = DispatchSemaphore(value: 0)
        objc_sync_enter(self.lock)
        if self.groupKeyMap[key] != nil {//该key正在执行,休眠一段时间在时
            
            //获取上一次的锁
            waitLock = self.groupKeyMap[key]!
            objc_sync_exit(self.lock)//解除线程锁定,让其他线程继续执行
            
            //等待上一个线程执行完毕
            waitLock.wait()
            
            objc_sync_enter(self.lock)
            self.groupKeyMap[key] = waitLock
            objc_sync_exit(self.lock)
        } else {
            
            //该key空闲,加入到正在执行Map,并结束线程等待
            self.groupKeyMap[key] = waitLock
            objc_sync_exit(self.lock)//解除线程锁定,让其他线程继续执行
        }
        
        //被执行的代码块是否异常
        var blockError: Error? = nil
        do{
            try block()
        }catch let error{
            blockError = error
        }
        objc_sync_enter(self.lock)
        
        //解锁下一个线程
        self.groupKeyMap[key]!.signal()
        
        //将key从正在处理的Map移除,让其他线程继续执行
        self.groupKeyMap.removeValue(forKey: key)
        objc_sync_exit(self.lock)
        if let error = blockError {
            throw error
        }
    }
    
    deinit{
        debugPrint("-->deinit:GroupSyncLock")
    }
}
