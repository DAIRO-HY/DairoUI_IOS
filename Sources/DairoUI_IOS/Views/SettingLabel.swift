//
//  SettingLabel.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI


public struct SettingProperty: Setting {
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
    
    /**
     A unique identifier for the view.
     */
    var identifier: AnyHashable? {
        if let id = self.id {
            return id
        }
        return self.title
    }

    /**
     Text for searching.
     */
    var text: String? {
        return self.title
    }
}

/**
 A plain button.
 */
public struct SettingLabel: View, @preconcurrency Setting {
    public var id: AnyHashable?
    
    public var property: SettingProperty
    public init(property: SettingProperty) {
        self.property = property
    }
    
    public var body: some View {
        SettingLabelView(property: self.property)
    }
}

struct SettingLabelView: View {
    @Environment(\.edgePadding) var edgePadding
    @Environment(\.settingSecondaryColor) var settingSecondaryColor
    var property: SettingProperty
    var body: some View {
        HStack(spacing: self.property.horizontalSpacing) {
            if let icon = self.property.icon {
                SettingIconView(icon: icon, iconSize:  self.property.iconSize, iconRadius:  self.property.iconRadius)
            }
            
            if  self.property.isVertical{//次要文字竖向显示
                VStack{
                    Text( self.property.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if  self.property.tip != nil && !self.property.tip!.isEmpty {//提示文字
                        Text( self.property.tip!).font(.subheadline).foregroundColor(settingSecondaryColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical,  self.property.verticalPadding)
            }else{//次要文字横向显示
                Text( self.property.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical,  self.property.verticalPadding)
                
                if  self.property.tip != nil && !self.property.tip!.isEmpty {//提示文字
                    Text(self.property.tip!).font(.subheadline).foregroundColor(self.settingSecondaryColor)
                }
            }
            
            if let indicator =  self.property.indicator {
                Image(systemName: indicator)
                    .foregroundColor( self.settingSecondaryColor)
            }
        }
        .padding(.horizontal,  self.property.horizontalPadding ??  self.edgePadding)
        .accessibilityElement(children: .combine)
    }
}
