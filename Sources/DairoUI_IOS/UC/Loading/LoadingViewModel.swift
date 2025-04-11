import SwiftUI


class LoadingViewModel : ObservableObject{
    
    /**
     * 控制加载动画显示状态
     */
    @Published var mIsLoading = false
    
    init(){
        Loading.mLoadingViewModel = self
    }
}
