import SwiftUI

/**
 A plain button.
 */
public struct SettingButton: View, @preconcurrency Setting {
    
    //控件ID
    public var id: AnyHashable?
    
    //图标
    public var icon: SettingIcon?
    
    //图标尺寸
    public var iconSize: CGFloat = 28
    
    //图标圆角大小
    public var iconRadius: CGFloat = 6
    
    //标题
    public var title: String
    
    //右边的指示图标
    public var indicator: String? = "chevron.forward"
    
    //提示文字内容
    public var tip:String?
    
    //横向间距
    public var horizontalSpacing = CGFloat(12)
    
    //竖向内边距
    public var verticalPadding = CGFloat(14)
    
    //横向内边距
    public var horizontalPadding: CGFloat? = nil
    
    //是否竖向显示
    public var isVertical: Bool = false
    
    //按钮事件
    public var action: () -> Void
    public init(
        id: AnyHashable? = nil,
        _ title: String,
        tip: String? = nil,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.tip = tip
        self.action = action
    }
    
    public var body: some View {
        Button(action: self.action){
            SettingLabel(
                icon: self.icon,
                iconSize: self.iconSize,
                iconRadius: self.iconRadius,
                title: self.title,
                indicator: self.indicator,
                tip: self.tip,
                horizontalSpacing: self.horizontalSpacing,
                verticalPadding: self.verticalPadding,
                horizontalPadding: self.horizontalPadding,
                isVertical: self.isVertical//是否竖向显示
            )
        }
        .buttonStyle(.row)
    }
}

public extension SettingButton {
    
    func icon(_ icon: String, color: Color = .blue) -> SettingButton {
        var view = self
        view.icon = .system(icon: icon, backgroundColor: color)
        return view
    }
    
    func icon(_ icon: String, foregroundColor: Color = .white, backgroundColor: Color = .blue) -> SettingButton {
        var view = self
        view.icon = .system(icon: icon, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
        return view
    }
    
    func icon(icon: SettingIcon) -> SettingButton {
        var view = self
        view.icon = icon
        return view
    }
    
    func iconSize(_ value: CGFloat) -> SettingButton{
        var view = self
        view.iconSize = value
        return view
    }
    
    func iconRadius(_ value: CGFloat) -> SettingButton{
        var view = self
        view.iconRadius = value
        return view
    }
    
    func indicator(_ value: String) -> SettingButton {
        var view = self
        view.indicator = value
        return view
    }
    
    func horizontalSpacing(_ value: CGFloat) -> SettingButton {
        var view = self
        view.horizontalSpacing = value
        return view
    }
    
    func verticalPadding(_ value: CGFloat) -> SettingButton {
        var view = self
        view.verticalPadding = value
        return view
    }
    
    func horizontalPadding(_ value: CGFloat) -> SettingButton {
        var view = self
        view.horizontalPadding = value
        return view
    }
    
    func isVertical(_ value: Bool) -> SettingButton {
        var view = self
        view.isVertical = value
        return view
    }
}

#Preview{
    SettingStack{
        SettingPage{
            SettingGroup{
                SettingButton("按钮", tip: "明细内容"){
                }.icon("chevron.forward", foregroundColor: .white, backgroundColor: .pink)
            }
        }
    }
}
