import Foundation

/**
 * 一个消息广播类
 * EnvenBus并不是什么高科技,只是简化NotificationCenter流程,目的是为了与其他平台(Android,WPF)风格统一,仅此而已
 */
class EventUtil{
    
    /**
     * 注册广播
     * @param observer 广播携带对象,及当该对象被销毁是,此广播也随之销毁
     * @param key 广播名,标记发送对象
     * @param callback 广播回调
     */
    static func regist(_ observer: Any, _ code: EventCode, _ callback: Selector){
        NotificationCenter.default.addObserver(observer, selector: callback, name: NSNotification.Name(rawValue: code.rawValue), object: nil)
    }
    
    /**
     * 注销广播
     * @param observer 广播携带对象
     */
    static func unregist(_ observer: Any){
        NotificationCenter.default.removeObserver(observer)
    }
    
    /**
     * 发送广播消息
     * @param key 广播名
     * @param data 广播数据
     */
    @MainActor
    static func post(_ code: EventCode, _ data: Any? = nil) async{
        await MainActor.run{
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: code.rawValue), object: data)
        }
    }
}
