import Foundation
/**
 * Toast弹出式消息工具类
 */
class Toast{
    
    /**
     * Toast弹出式消息ViewModel静态实例,方便全局控制
     */
    nonisolated(unsafe) static var mToastModel: ToastViewModel?
    
    /**
     * 短时间显示的消息
     */
    static func show(_ msg: String){
        DispatchQueue.main.async{
            Toast.mToastModel?.show(ToastMessage(delay: 1.5, message: msg))
        }
    }
}
