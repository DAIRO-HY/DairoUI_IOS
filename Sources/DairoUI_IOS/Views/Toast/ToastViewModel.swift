import SwiftUI

/**
 * Toast弹出式消息ViewModel
 */
@MainActor
class ToastViewModel : ObservableObject{
    
    /**
     * 标记是否显示Toast
     */
    @Published var mIsShowToast = false
    
    /**
     * 本次要显示的消息
     */
    @Published var mToastMessage = ToastMessage(delay: 0, message: "")
    
    /**
     * 要显示的消息列表
     */
    private var mToastMessageList = [ToastMessage]()
    
    init(){
        objc_sync_enter(ToastViewModel.self)
        if Toast.mToastModel != nil{//上次没显示完的消息,这次继续显示,避免页面跳转时消息被清空
            self.mToastMessageList = Toast.mToastModel!.mToastMessageList
        }
        if !self.mToastMessageList.isEmpty{
            self.mToastMessage = self.mToastMessageList.first!
            self.mIsShowToast = true
        }
        Toast.mToastModel = self
        objc_sync_exit(ToastViewModel.self)
    }
    
    /**
     * 添加并显示消息
     */
    func show(_ message:ToastMessage){
        objc_sync_enter(ToastViewModel.self)
        self.mToastMessageList.append(message)
        if !self.mIsShowToast{
            self.mToastMessage = self.mToastMessageList.first!
            self.mIsShowToast = true
        }
        objc_sync_exit(ToastViewModel.self)
    }
    
    /**
     * 显示吓一跳消息
     */
    func next() async{
        objc_sync_enter(ToastViewModel.self)
        self.mToastMessageList.removeFirst()
        self.mIsShowToast = false
        if !self.mToastMessageList.isEmpty{
            await Task.sleep(1)
            await MainActor.run{
                objc_sync_enter(ToastViewModel.self)
                self.mToastMessage = self.mToastMessageList.first!
                self.mIsShowToast = true
                objc_sync_exit(ToastViewModel.self)
            }
        }
        objc_sync_exit(ToastViewModel.self)
        
    }
}
