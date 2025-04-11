import SwiftUI

class Loading{
    
    /**
     * 加载等待框ViewModel静态实例,方便全局操作
     */
    nonisolated(unsafe) static var mLoadingViewModel:LoadingViewModel? = nil
    
    /**
     * 记录显示次数
     */
    nonisolated(unsafe) private static var showCount = 0
    
    /**
     * 显示次数+1
     */
    static func show(){
        objc_sync_enter(Loading.self)
        Loading.showCount += 1
        Loading.setLoadingShowStatus()
        objc_sync_exit(Loading.self)
    }
    
    /**
     * 显示次数-1
     */
    static func hide(){
        objc_sync_enter(Loading.self)
        Loading.showCount -= 1
        Loading.setLoadingShowStatus()
        objc_sync_exit(Loading.self)
    }
    
    /**
     * 强制隐藏加载框
     */
    static func hideAll(){
        objc_sync_enter(Loading.self)
        Loading.showCount = 0
        Loading.setLoadingShowStatus()
        objc_sync_exit(Loading.self)
    }
    
    /**
     * 设置正在加载的视图显示状态
     */
    private static func setLoadingShowStatus(){
        if Loading.showCount <= 0{
            Loading.mLoadingViewModel?.mIsLoading = false
            Loading.showCount = 0
        }else{
            Loading.mLoadingViewModel?.mIsLoading = true
        }
    }
}
