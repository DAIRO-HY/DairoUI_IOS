//
//  SettingTextField.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/24/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 A text field.
 */
public struct SettingTextField: View, @preconcurrency Setting {
    public var id: AnyHashable?
    public var icon: SettingIcon?
    
    //图标尺寸
    public let iconSize: CGFloat
    
    //图标圆角大小
    public let iconRadius: CGFloat
    public var title: String
    @Binding public var text: String
    
    //提示文字内容
    public var placeholder: String
    
    // 输入类型
    public let type: SettingTextFieldType
    public var verticalPadding = CGFloat(14)
    public var horizontalPadding: CGFloat? = nil
    
    public init(
        id: AnyHashable? = nil,
        icon: SettingIcon? = nil,
        iconSize: CGFloat = 28,
        iconRadius: CGFloat = 6,
        title: String,
        text: Binding<String>,
        placeholder:String = "",
        type: SettingTextFieldType = .text,
        verticalPadding: CGFloat = CGFloat(14),
        horizontalPadding: CGFloat? = nil
    ) {
        self.id = id
        self.icon = icon
        self.iconSize = iconSize
        self.iconRadius = iconRadius
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.type = type
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
    }
    
    public var body: some View {
        SettingTextFieldView(
            icon: self.icon,
            iconSize: self.iconSize,
            iconRadius: self.iconRadius,
            title: self.title,
            text: $text,
            placeholder: self.placeholder,
            type: self.type,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding
        )
    }
}

struct SettingTextFieldView: View {
    @Environment(\.edgePadding) var edgePadding
    
    @Environment(\.settingSecondaryColor) var settingSecondaryColor
    
    //左边的图标
    var icon: SettingIcon?
    
    //图标尺寸
    let iconSize:CGFloat
    
    //图标圆角大小
    let iconRadius:CGFloat
    let title: String
    
    @Binding var text: String
    
    //提示文字内容
    let placeholder: String
    
    // 输入类型
    let type: SettingTextFieldType
    var horizontalSpacing = CGFloat(12)
    
    var verticalPadding = CGFloat(14)
    var horizontalPadding: CGFloat? = nil
    
    var body: some View {
        HStack(spacing: horizontalSpacing) {
            if let icon {
                SettingIconView(icon: icon, iconSize: self.iconSize, iconRadius: self.iconRadius)
            }
            
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, verticalPadding)
            
            if self.type == .text{
                TextField(self.placeholder, text: $text)
#if os(iOS)
                    .keyboardType(.emailAddress) // 确保输入法切换
                    .autocapitalization(.none) // 可选：关闭自动大写
#endif
                    .disableAutocorrection(true) // 可选：关闭自动校正
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, verticalPadding)
                    .padding(.horizontal, horizontalPadding ?? edgePadding)
                    .accessibilityElement(children: .combine)
            }else{
                SecureField(self.placeholder, text: $text)
#if os(iOS)
                    .keyboardType(.emailAddress) // 确保输入法切换
                    .autocapitalization(.none) // 可选：关闭自动大写
#endif
                    .disableAutocorrection(true) // 可选：关闭自动校正
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, verticalPadding)
                    .padding(.horizontal, horizontalPadding ?? edgePadding)
                    .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, horizontalPadding ?? edgePadding)
        .accessibilityElement(children: .combine)
        
    }
}


public extension SettingTextField {
    func icon(_ icon: String, color: Color = .blue) -> SettingTextField {
        var button = self
        button.icon = .system(icon: icon, backgroundColor: color)
        return button
    }
    
    func icon(_ icon: String, foregroundColor: Color = .white, backgroundColor: Color = .blue) -> SettingTextField {
        var button = self
        button.icon = .system(icon: icon, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
        return button
    }
    
    func icon(icon: SettingIcon) -> SettingTextField {
        var button = self
        button.icon = icon
        return button
    }
}



// 带图片的输入框类型
public enum SettingTextFieldType{
    case text //普通文本输入框
    case password //密码输入框
}
