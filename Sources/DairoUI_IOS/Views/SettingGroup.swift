//
//  SettingDividedVStack.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 A group of `Setting`s.
 */
public struct SettingGroup: Setting {
    public var id: AnyHashable?
    public var header: String?
    public var headerAction: (()->Void)?
    public var footer: String?
    public var allowAttributedFooter = true
    public var horizontalPadding: CGFloat?
    public var backgroundColor: Color?
    public var backgroundCornerRadius = CGFloat(12)
    public var dividerLeadingMargin = CGFloat(16)
    public var dividerTrailingMargin = CGFloat(0)
    public var dividerColor: Color?
    @SettingBuilder public var tuple: SettingTupleView

    public init(
        id: AnyHashable? = nil,
        header: String? = nil,
        headerAction: (()->Void)? = nil,
        footer: String? = nil,
        allowAttributedFooter: Bool = true,
        horizontalPadding: CGFloat? = nil,
        backgroundColor: Color? = nil,
        backgroundCornerRadius: CGFloat = CGFloat(12),
        dividerLeadingMargin: CGFloat = CGFloat(16),
        dividerTrailingMargin: CGFloat = CGFloat(0),
        dividerColor: Color? = nil,
        @SettingBuilder tuple: () -> SettingTupleView
    ) {
        self.id = id
        self.header = header
        self.headerAction = headerAction
        self.footer = footer
        self.allowAttributedFooter = allowAttributedFooter
        self.horizontalPadding = horizontalPadding
        self.backgroundColor = backgroundColor
        self.backgroundCornerRadius = backgroundCornerRadius
        self.dividerLeadingMargin = dividerLeadingMargin
        self.dividerTrailingMargin = dividerTrailingMargin
        self.dividerColor = dividerColor
        self.tuple = tuple()
    }
}

public struct SettingGroupView<Content: View>: View {
    @Environment(\.edgePadding) var edgePadding
    @Environment(\.settingSecondaryBackgroundColor) var settingSecondaryBackgroundColor
    @Environment(\.settingSecondaryColor) var settingSecondaryColor

    public var icon: SettingIcon?
    public var header: String?
    public var headerAction: (()->Void)?
    public var footer: String?
    public var allowAttributedFooter = true
    public var horizontalPadding: CGFloat?
    public var foregroundColor: Color?
    public var backgroundColor: Color?
    public var backgroundCornerRadius = CGFloat(12)
    public var dividerLeadingMargin = CGFloat(16)
    public var dividerTrailingMargin = CGFloat(0)
    public var dividerColor: Color?
    @ViewBuilder public var content: () -> Content

    public init(
        icon: SettingIcon? = nil,
        header: String? = nil,
        headerAction: (()->Void)? = nil,
        footer: String? = nil,
        allowAttributedFooter: Bool = true,
        horizontalPadding: CGFloat? = nil,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil,
        backgroundCornerRadius: CGFloat = CGFloat(12),
        dividerLeadingMargin: CGFloat = CGFloat(16),
        dividerTrailingMargin: CGFloat = CGFloat(0),
        dividerColor: Color? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.header = header
        self.headerAction = headerAction
        self.footer = footer
        self.allowAttributedFooter = allowAttributedFooter
        self.horizontalPadding = horizontalPadding
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.backgroundCornerRadius = backgroundCornerRadius
        self.dividerLeadingMargin = dividerLeadingMargin
        self.dividerTrailingMargin = dividerTrailingMargin
        self.dividerColor = dividerColor
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if icon != nil || header != nil {
                HStack(spacing: 2) {
                    if let icon {
                        SettingIconView(icon: icon)
                            .scaleEffect(0.6)
                    }
                    if let header{//如果header传递的是一个字符串
                        if let headerAction{
                            Button(action: headerAction){
                                Text(header)
                            }
                        }else{
                            Text(header).foregroundColor(foregroundColor ?? settingSecondaryColor)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, backgroundCornerRadius)
                .padding(.bottom, 6)
            }

            SettingDividedVStack(
                leadingMargin: dividerLeadingMargin,
                trailingMargin: dividerTrailingMargin,
                dividerColor: dividerColor
            ) {
                content()
            }
            .background(backgroundColor ?? settingSecondaryBackgroundColor)
            .mask {
                RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
            }
            
            //加载footer
            if let footer{//如果footer传递的是一个字符串
                VStack {
                    if allowAttributedFooter {
                        Text(.init(footer)) /// Support markdown.
                    } else {
                        Text(verbatim: footer)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(.subheadline))
                .foregroundColor(foregroundColor ?? settingSecondaryColor)
                .padding(.horizontal, backgroundCornerRadius)
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, horizontalPadding ?? edgePadding)
    }
}
