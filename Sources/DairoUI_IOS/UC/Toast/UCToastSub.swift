import SwiftUI

/**
 * Toast弹出式消息子视图
 */
struct UCToastSub: View {
    
    /**
     * 消息信息
     */
    private var mMessage: ToastMessage
    
    /**
     * 渐变时的透明度
     */
     @State private var mOpacity = 1.0
    
    init(_ message : ToastMessage){
        self.mMessage = message
    }
    
    var body: some View {
        VStack{
            Spacer()
            Text(self.mMessage.message)
                .padding(.all,8)
                .font(.subheadline)
                .foregroundColor(Color.gl.white)
                .background(Color("toast"))
                .cornerRadius(CGFloat(Int.max))
                .opacity(self.mOpacity)
                .animation(Animation.linear(duration: 1).repeatCount(1).delay(self.mMessage.delay),
                           value: self.mOpacity)// アニメーションの適用
                .onAppear {// ビューが表示された時の処理
                    self.mOpacity = 0
                }
            Spacer().frame(height: 50)
        }
    }
}

struct ToastSubUC_Previews: PreviewProvider {
    static var previews: some View {
        UCToastSub(ToastMessage(delay: Double(Int.max), message: "消息内容"))
    }
}
