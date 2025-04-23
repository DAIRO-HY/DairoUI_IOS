import SwiftUI

/**
 * Toast弹出式消息视图
 */
@available(iOS 14.0, *)
struct UCToast: View {
    @StateObject var model = ToastViewModel()
    var body: some View {
        if self.model.mIsShowToast{
            ToastView()
                .onAppear {// ビューが表示された時の処理
                    Task{
                        await Task.sleep(1_000_000_000)
                        await self.model.next()
                    }
                }
        } else {
            EmptyView()
        }
    }
}

@available(iOS 14.0, *)
struct UCToast_Previews: PreviewProvider {
    static var previews: some View {
        UCToast()
    }
}
