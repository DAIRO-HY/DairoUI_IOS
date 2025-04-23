import SwiftUI

/**
 * Toast弹出式消息子视图
 */
struct ToastView: View {
    
    /**
     * 渐变时的透明度
     */
    @State private var opacity = 1.0
    
    @EnvironmentObject private var rootVm: RootViewModel
    
    var body: some View {
        if let toastMessage = Toast.toastMessage {
            if self.rootVm.toastFlag{
                SubToastView(delay: toastMessage.delay, message: toastMessage.message)
            } else {
                SubToastView(delay: toastMessage.delay, message: toastMessage.message)
            }
        } else {
            EmptyView()
        }
    }
}


/**
 * Toast弹出式消息子视图
 */
struct SubToastView: View {
    
    /**
     * 渐变时的透明度
     */
    @State private var opacity = 1.0
    private let delay: Double
    private let message: String
    init(delay: Double, message: String) {
        self.delay = delay
        self.message = message
    }
    
    var body: some View {
        VStack{
            Spacer()
            Text(self.message)
                .font(.subheadline)
                .foregroundColor(Color.gl.white)
                .padding(.vertical,8)
                .padding(.horizontal,15)
                .background(.primary)
                .cornerRadius(CGFloat(Int.max))
                .opacity(self.opacity)
            
            // 应用动画
                .animation(
                    Animation.linear(duration: TimeInterval(Toast.ANIMATION_LINEAR_TIME))
                        .repeatCount(1)
                        .delay(self.delay),
                    value: self.opacity)
                .onAppear {
                    self.opacity = 0
                }
            Spacer().frame(height: 80)
        }
    }
}

#Preview{
    SubToastView(delay: Double(Int.max), message: "消息内容")
}
