//
//  SettingView.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

public struct SettingView: View {
    public var setting: Setting
    public var isInitialPage = false
    public var isPagePreview = true

    @State var isActive = false

    public init(setting: Setting, isInitialPage: Bool = false, isPagePreview: Bool = true) {
        self.setting = setting
        self.isInitialPage = isInitialPage
        self.isPagePreview = isPagePreview
    }

    public var body: some View {
        switch setting {
        case let v as SettingText:
            v
        case let v as SettingLabel:
            v
        case let v as SettingButton:
            v
        case let v as SettingButtonSingle:
            v
        case let v as SettingNavigationLink<AnyView>:
            v
        case let v as SettingToggle:
            v
        case let v as SettingSlider:
            v
        case let v as SettingPicker<Int>:
            v
        case let v as SettingPicker<Int64>:
            v
        case let v as SettingPicker<String>:
            v
        case let v as SettingPicker<Float>:
            v
        case let v as SettingPicker<Float64>:
            v
        case let v as SettingTextField:
            v
        case let page as SettingPage:

            if isPagePreview {
                Button {
                    isActive = true
                } label: {
                    SettingPagePreviewView(
                        title: page.title,
                        selectedChoice: page.selectedChoice,
                        icon: page.previewConfiguration.icon,
                        indicator: page.previewConfiguration.indicator,
                        horizontalSpacing: page.previewConfiguration.horizontalSpacing,
                        verticalPadding: page.previewConfiguration.verticalPadding,
                        horizontalPadding: page.previewConfiguration.horizontalPadding
                    )
                }
                .buttonStyle(.row)
                .background {
                    NavigationLink(isActive: $isActive) {
                        #if os(iOS)
                            if #available(iOS 16.0, *) {
                                SettingView(setting: page, isPagePreview: false)
                                    .toolbar(.hidden, for: .tabBar)
                            } else {
                                SettingView(setting: page, isPagePreview: false)
                            }
                        #else
                            SettingView(setting: page, isPagePreview: false)
                        #endif
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                }
                
            } else {
                SettingPageView(
                    title: page.title,
                    spacing: page.spacing,
                    verticalPadding: page.verticalPadding,
                    backgroundColor: page.backgroundColor,
                    navigationTitleDisplayMode: page.navigationTitleDisplayMode,
                    isInitialPage: isInitialPage
                ) {
                    ForEach(page.tuple.settings, id: \.identifier) { setting in
                        SettingView(setting: setting, isPagePreview: true)
                    }
                }
            }
        case let group as SettingGroup:
            SettingGroupView(
                header: group.header,
                headerAction:group.headerAction,
                footer: group.footer,
                allowAttributedFooter: group.allowAttributedFooter,
                horizontalPadding: group.horizontalPadding,
                backgroundColor: group.backgroundColor,
                backgroundCornerRadius: group.backgroundCornerRadius,
                dividerLeadingMargin: group.dividerLeadingMargin,
                dividerTrailingMargin: group.dividerTrailingMargin,
                dividerColor: group.dividerColor
            ) {
                ForEach(group.tuple.settings, id: \.identifier) { setting in
                    SettingView(setting: setting)
                }
            }
        case let tuple as SettingTupleView:
            ForEach(tuple.settings, id: \.identifier) { setting in
                SettingView(setting: setting)
            }

        case let customView as SettingCustomView:
            customView.view
        default:
            Text("Unsupported setting, please file a bug report.")
        }
    }
}
