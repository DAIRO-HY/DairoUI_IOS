import SwiftUI

/**
 * 正在加载中动画
 */
struct UCLoadingSub: View {
    
    /**
     * 动画显示表示
     */
    @State private var isAnimation = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center){
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)//忽略安全区域
                HStack(spacing: 2) {
                    ForEach(0 ..< 4) { index in
                        Circle()
                            .fill(Color.gl.textPrimary)
                            .frame(width: 20, height: 20)
                            .opacity(self.isAnimation ? 1.0 : 0.1)//透明度控制
                            .scaleEffect(self.isAnimation ? 1.0 : 0.1)//大小控制
                            .animation(
                                Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(index) * 0.5 / 2),
                                value: self.isAnimation
                            )
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear(){
                self.isAnimation.toggle()
            }
        }
    }
}

struct UCLoadingSub_Previews: PreviewProvider {
    static var previews: some View {
        UCLoadingSub()
    }
}
