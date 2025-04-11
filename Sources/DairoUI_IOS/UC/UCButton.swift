import SwiftUI

/**
 * GL按钮
 */
public struct UCButton: View {
    
    // 按钮显示内容
    let mContent:String
    
    //点击后执行函数
    let mAction: ()->Void
    
    /**
     * 文字颜色
     */
    @State
    private var textColor:Color
    
    /**
     * 背景颜色
     */
    @State
    private var bgColor:Color
    
    /**
     * 边框颜色
     */
    @State
    private var borderColor: Color
    
    /** 初始化
     * parameter content:按钮显示文本
     * parameter action:按钮点击后执行事件
     */
    public init(_ content: String, textColor: Color, bgColor: Color, borderColor: Color, action: @escaping ()->Void){
        self.mContent = content
        self.mAction = action
        self.textColor = textColor
        self.bgColor = bgColor
        self.borderColor = borderColor
    }
    
    public var body: some View {
        Button(action:mAction){
            Text(mContent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .font(.body)
                .foregroundColor(self.textColor)
        }
        .background(self.bgColor)
        .cornerRadius(6)
        .overlay(// 设置边框样式
            RoundedRectangle(cornerRadius: 6).stroke(self.borderColor, lineWidth: 1)
        )
    }
    
    /**
     * 主调色按钮
     * parameter content 按钮文字
     * parameter action 按钮事件
     */
    public static func primary(_ content: String, action: @escaping ()->Void) -> UCButton{
        return UCButton(
            content,
            textColor: Color.gl.btnTextPrimary,
            bgColor: Color.gl.bgPrimary,
            borderColor: Color.gl.borderPrimary,
            action: action
        )
    }
    
    /**
     * 次要按钮
     * parameter content 按钮文字
     * parameter action 按钮事件
     */
    public static func secondary(_ content: String, action: @escaping ()->Void) -> UCButton{
        return UCButton(
            content,
            textColor: Color.gl.btnTextSecondary,
            bgColor: Color.gl.bgSecondary,
            borderColor: Color.gl.borderSecondary,
            action: action
        )
    }
}

struct GLButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            UCButton.primary("按钮",action: {})
            UCButton.secondary("按钮",action: {})
        }.padding()
    }
}

