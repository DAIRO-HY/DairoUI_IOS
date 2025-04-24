import SwiftUI

class UCRootViewModel : ObservableObject{
    
    /**
     * 根视图ViewModel静态实例,方便全局控制
     */
    nonisolated(unsafe) static var mRootUCModel: UCRootViewModel? = nil
    init(){
        UCRootViewModel.mRootUCModel = self
    }
}

/**
 * 根视图
 */
@available(iOS 14.0, *)
struct UCRoot<T>: View where T : View {
    
    /**
     * 根视图ViewModel
     */
    @StateObject var mModel = UCRootViewModel()
    
    @ViewBuilder private var mContent: () -> T
    init(@ViewBuilder content: @escaping () -> T) {
        self.mContent = content
    }
    var body: some View {
        ZStack {
            Group(content: self.mContent)
            
            //加载中等待框
//            LoadingView()
            
            //Toast弹出式消息
            UCToast()
        }
    }
}


@available(iOS 14.0, *)
struct UCRoot_Previews: PreviewProvider {
    static var previews: some View {
        UCRoot {
            VStack {
                UCItemLabel("一条数据",subTitle:"这里是说明1235678")
                UCItemLabel("一条数据",subTitle:"这里是说明1235678")
                UCItemLabel("一条数据",subTitle:"这里是说明1235678",showLine: false)
            }
        }
    }
}
