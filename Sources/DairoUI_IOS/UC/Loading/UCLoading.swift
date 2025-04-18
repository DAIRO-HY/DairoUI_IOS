import SwiftUI

/**
 * 正在加载中动画
 */
@available(iOS 14.0, *)
struct UCLoading: View {
    
    /**
     * ViewModel
     */
    @StateObject var model = LoadingViewModel()
    var body: some View {
        if self.model.mIsLoading{
            UCLoadingSub()
        }else{
            EmptyView()
        }
    }
}


@available(iOS 14.0, *)
struct UCLoading_Previews: PreviewProvider {
    static var previews: some View {
        UCLoading()
    }
}
