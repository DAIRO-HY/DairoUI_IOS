//
//  SettingButton.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 A plain button.
 */
public struct SettingNavigationLink: View, @preconcurrency Setting {
    public var id: AnyHashable?
    public var icon: SettingIcon?
    
    //图标尺寸
    public let iconSize:CGFloat
    
    //图标圆角大小
    public let iconRadius:CGFloat
    public var title: String
    public var indicator: String?
    
    //提示文字内容
    public var tip:String?
    public var horizontalSpacing = CGFloat(12)
    public var verticalPadding = CGFloat(14)
    public var horizontalPadding: CGFloat? = nil
    
    //是否竖向显示
    public let isVertical:Bool
    let destination: AnyView
    public init(
        id: AnyHashable? = nil,
        destination: AnyView,
        icon: SettingIcon? = nil,
        iconSize: CGFloat = 28,
        iconRadius: CGFloat = 6,
        title: String,
        indicator: String? = "chevron.forward",
        tip:String?=nil,
        horizontalSpacing: CGFloat = CGFloat(12),
        verticalPadding: CGFloat = CGFloat(14),
        horizontalPadding: CGFloat? = nil,
        isVertical:Bool = false//是否竖向显示
    ) {
        self.id = id
        self.destination = destination
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
        SettingNavigationLinkView(
            icon: self.icon,
            iconSize: self.iconSize,
            iconRadius: self.iconRadius,
            title: self.title,
            indicator: self.indicator,
            tip: self.tip,
            horizontalSpacing: self.horizontalSpacing,
            verticalPadding: self.verticalPadding,
            horizontalPadding: self.horizontalPadding,
            isVertical: self.isVertical,//是否竖向显示
            destination: self.destination
        )
    }
}

struct SettingNavigationLinkView: View {
    @Environment(\.edgePadding) var edgePadding
    @Environment(\.settingSecondaryColor) var settingSecondaryColor
    
    //左边的图标
    var icon: SettingIcon?
    
    //图标尺寸
    let iconSize:CGFloat
    
    //图标圆角大小
    let iconRadius:CGFloat
    let title: String
    
    //指示器图标
    var indicator: String?
    
    //提示文字内容
    var tip:String?
    var horizontalSpacing = CGFloat(12)
    var verticalPadding = CGFloat(14)
    var horizontalPadding: CGFloat? = nil
    
    //是否竖向显示
    let isVertical:Bool
    
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: self.destination) {
            HStack(spacing: horizontalSpacing) {
                if let icon {
                    SettingIconView(icon: icon, iconSize: self.iconSize, iconRadius: self.iconRadius)
                }
                
                if self.isVertical{//次要文字竖向显示
                    VStack{
                        Text(title)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if self.tip != nil && !self.tip!.isEmpty {//提示文字
                            Text(self.tip!) .foregroundColor(settingSecondaryColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, verticalPadding)
                }else{//次要文字横向显示
                    Text(title)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, verticalPadding)
                    
                    if self.tip != nil && !self.tip!.isEmpty {//提示文字
                        Text(self.tip!) .foregroundColor(settingSecondaryColor)
                    }
                }
                
                if let indicator {
                    Image(systemName: indicator)
                        .foregroundColor(settingSecondaryColor)
                }
            }
            .padding(.horizontal, horizontalPadding ?? edgePadding)
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.row)
    }
}

public extension SettingNavigationLink {
    func icon(_ icon: String, color: Color = .blue) -> SettingNavigationLink {
        var button = self
        button.icon = .system(icon: icon, backgroundColor: color)
        return button
    }
    
    func icon(_ icon: String, foregroundColor: Color = .white, backgroundColor: Color = .blue) -> SettingNavigationLink {
        var button = self
        button.icon = .system(icon: icon, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
        return button
    }
    
    func icon(icon: SettingIcon) -> SettingNavigationLink {
        var button = self
        button.icon = icon
        return button
    }
    
    func indicator(_ indicator: String) -> SettingNavigationLink {
        var button = self
        button.indicator = indicator
        return button
    }
}
