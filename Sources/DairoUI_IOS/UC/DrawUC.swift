import SwiftUI

/**
 * 拖拽操作
 */
struct DrawUC: View {
    @State var isResetting = false
    @State var circleCenter = CGPoint.zero
    @State var isCircleScaled = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center){
                Circle()
                    .frame(width: 50, height: 50)
                    .scaleEffect(isCircleScaled ? 2 : 1)
                    .animation(isResetting ? nil : .easeInOut, value: isCircleScaled)
                    .offset(x: circleCenter.x - 25, y: circleCenter.y - 25)
                    .animation(isResetting ? nil : .spring(response: 0.3, dampingFraction: 0.1), value: circleCenter)
                    .gesture(
                        DragGesture(minimumDistance: 0).onChanged { value in
                            circleCenter = value.location
                        }
                    )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct DrawUC_Previews: PreviewProvider {
    static var previews: some View {
        DrawUC()
    }
}
