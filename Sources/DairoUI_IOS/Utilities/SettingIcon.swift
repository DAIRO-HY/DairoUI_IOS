//
//  SettingIcon.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 An general purpose icon view.
 */
public enum SettingIcon {
    case system(icon: String, foregroundColor: Color = .white, backgroundColor: Color)
    
    /// Pass in a `foregroundColor` to render and recolor the image as a template.
    case image(name: String, inset: CGFloat, foregroundColor: Color?, backgroundColor: Color)
    case custom(view: AnyView)
}

/**
 A view for displaying a `SettingIcon`.
 */
public struct SettingIconView: View {
    
    //左边的图标
    public var icon: SettingIcon
    
    //图标尺寸
    public let iconSize:CGFloat
    
    //图标圆角大小
    public let iconRadius:CGFloat
    
    public init(icon: SettingIcon,iconSize: CGFloat = 28,iconRadius: CGFloat = 6) {
        self.icon = icon
        self.iconSize = iconSize
        self.iconRadius = iconRadius
    }
    
    public var body: some View {
        switch icon {
        case .system(let icon, let foregroundColor, let backgroundColor):
            Image(systemName: icon)
                .foregroundColor(foregroundColor)
                .font(.footnote)
                .frame(width: self.iconSize, height: self.iconSize)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: self.iconRadius))
            
        case .image(let name, let inset, let foregroundColor, let backgroundColor):
            if let foregroundColor {
                Image(name)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(foregroundColor)
                    .aspectRatio(contentMode: .fit)
                    .padding(inset)
                    .frame(width: self.iconSize, height: self.iconSize)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: self.iconRadius))
            } else {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(inset)
                    .frame(width: self.iconSize, height: self.iconSize)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: self.iconRadius))
            }
            
        case .custom(let anyView):
            anyView
        }
    }
}
