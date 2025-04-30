import SwiftUI

/**
 A plain button.
 */
public struct SettingLabel: View, @preconcurrency Setting {
    
    @Environment(\.edgePadding) var edgePadding
    @Environment(\.settingSecondaryColor) var settingSecondaryColor
    
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
    
    public init(
        id: AnyHashable? = nil,
        icon: SettingIcon? = nil,
        iconSize: CGFloat = 28,
        iconRadius: CGFloat = 6,
        title: String,
        indicator: String? = nil,
        tip:String?=nil,
        horizontalSpacing: CGFloat = CGFloat(12),
        verticalPadding: CGFloat = CGFloat(14),
        horizontalPadding: CGFloat? = nil,
        isVertical:Bool = false//是否竖向显示
    ) {
        self.id = id
        self.icon = icon
        self.iconSize = iconSize
        self.iconRadius = iconRadius
        self.title = title
        self.indicator = indicator
        self.tip = tip
        self.horizontalSpacing = horizontalSpacing
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.isVertical = isVertical
    }
    
    public var body: some View {
        HStack(spacing: self.horizontalSpacing) {
            if let icon = self.icon {
                SettingIconView(icon: icon, iconSize:  self.iconSize, iconRadius:  self.iconRadius)
            }
            
            if  self.isVertical{//次要文字竖向显示
                VStack{
                    Text( self.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if  self.tip != nil && !self.tip!.isEmpty {//提示文字
                        Text( self.tip!).font(.subheadline).foregroundColor(settingSecondaryColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical,  self.verticalPadding)
            }else{//次要文字横向显示
                Text( self.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical,  self.verticalPadding)
                
                if  self.tip != nil && !self.tip!.isEmpty {//提示文字
                    Text(self.tip!).font(.subheadline).foregroundColor(self.settingSecondaryColor)
                }
            }
            
            if let indicator =  self.indicator {
                Image(systemName: indicator)
                    .foregroundColor( self.settingSecondaryColor)
            }
        }
        .padding(.horizontal,  self.horizontalPadding ??  self.edgePadding)
        .accessibilityElement(children: .combine)
    }
}
