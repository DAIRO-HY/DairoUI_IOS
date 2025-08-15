//
//  SettingPicker.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 A multi-choice picker.
 */
public struct SettingPicker<T:Hashable>: View, @preconcurrency Setting {
    public var id: AnyHashable?
    public var icon: SettingIcon?
    public var title: String
    public var data: [SettingPickerData<T>]
    @Binding public var value: T
    public var foregroundColor: Color?
    public var horizontalSpacing = CGFloat(12)
    public var verticalPadding = CGFloat(14)
    public var horizontalPadding: CGFloat?
    public var choicesConfiguration = ChoicesConfiguration()
    
    /// 值改变时回调函数
    public let changeFunc: (_ value: T)->Bool
    
    public init(
        id: AnyHashable? = nil,
        _ title: String,
        data: [SettingPickerData<T>],
        value: Binding<T>,
        foregroundColor: Color? = nil,
        horizontalSpacing: CGFloat = CGFloat(12),
        verticalPadding: CGFloat = CGFloat(14),
        horizontalPadding: CGFloat? = nil,
        choicesConfiguration: ChoicesConfiguration = ChoicesConfiguration(),
        changeFunc: @escaping (_ value: T)->Bool = { _ in
            return true
        }
    ) {
        self.id = id
        self.title = title
        self.data = data
        self._value = value
        self.foregroundColor = foregroundColor
        self.horizontalSpacing = horizontalSpacing
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.choicesConfiguration = choicesConfiguration
        self.changeFunc = changeFunc
    }
    
    public enum PickerDisplayMode {
        case navigation
        case menu
        case inline
    }
    
    public struct ChoicesConfiguration {
        public var verticalPadding = CGFloat(14)
        public var horizontalPadding: CGFloat?
        public var pageNavigationTitleDisplayMode = SettingPage.NavigationTitleDisplayMode.inline
        public var pickerDisplayMode = PickerDisplayMode.navigation
        public var groupHeader: String?
        public var groupFooter: String?
        public var groupHorizontalPadding: CGFloat?
        public var groupBackgroundColor: Color?
        public var groupBackgroundCornerRadius = CGFloat(12)
        public var groupDividerLeadingMargin = CGFloat(16)
        public var groupDividerTrailingMargin = CGFloat(0)
        public var groupDividerColor: Color?
        
        public init(
            verticalPadding: CGFloat = CGFloat(14),
            horizontalPadding: CGFloat? = nil,
            pageNavigationTitleDisplayMode: SettingPage.NavigationTitleDisplayMode = SettingPage.NavigationTitleDisplayMode.inline,
            pickerDisplayMode: PickerDisplayMode = PickerDisplayMode.navigation,
            groupHeader: String? = nil,
            groupFooter: String? = nil,
            groupHorizontalPadding: CGFloat? = nil,
            groupBackgroundColor: Color? = nil,
            groupBackgroundCornerRadius: CGFloat = CGFloat(12),
            groupDividerLeadingMargin: CGFloat = CGFloat(16),
            groupDividerTrailingMargin: CGFloat = CGFloat(0),
            groupDividerColor: Color? = nil
        ) {
            self.verticalPadding = verticalPadding
            self.horizontalPadding = horizontalPadding
            self.pageNavigationTitleDisplayMode = pageNavigationTitleDisplayMode
            self.pickerDisplayMode = pickerDisplayMode
            self.groupHeader = groupHeader
            self.groupFooter = groupFooter
            self.groupHorizontalPadding = groupHorizontalPadding
            self.groupBackgroundColor = groupBackgroundColor
            self.groupBackgroundCornerRadius = groupBackgroundCornerRadius
            self.groupDividerLeadingMargin = groupDividerLeadingMargin
            self.groupDividerTrailingMargin = groupDividerTrailingMargin
            self.groupDividerColor = groupDividerColor
        }
    }
    
    public var body: some View {
        SettingPickerView(
            icon: self.icon,
            title: self.title,
            data: self.data,
            value: self.$value,
            foregroundColor: self.foregroundColor,
            horizontalSpacing: self.horizontalSpacing,
            verticalPadding: self.verticalPadding,
            horizontalPadding: self.horizontalPadding,
            choicesConfiguration: self.choicesConfiguration,
            changeFunc: self.changeFunc
        )
    }
}

/// Convenience modifiers.
public extension SettingPicker {
    
    func icon(_ icon: String, color: Color = .blue) -> SettingPicker {
        var view = self
        view.icon = .system(icon: icon, backgroundColor: color)
        return view
    }
    
    func icon(_ icon: String, foregroundColor: Color = .white, backgroundColor: Color = .blue) -> SettingPicker {
        var view = self
        view.icon = .system(icon: icon, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
        return view
    }
    
    func icon(icon: SettingIcon) -> SettingPicker {
        var view = self
        view.icon = icon
        return view
    }
    
    func pickerDisplayMode(_ pickerDisplayMode: PickerDisplayMode) -> SettingPicker {
        var picker = self
        picker.choicesConfiguration.pickerDisplayMode = pickerDisplayMode
        return picker
    }
}

struct SettingPickerView<T:Hashable>: View {
    @Environment(\.edgePadding) var edgePadding
    @Environment(\.settingSecondaryColor) var settingSecondaryColor
    
    var icon: SettingIcon?
    let title: String
    var data: [SettingPickerData<T>]
    @Binding var value: T
    var foregroundColor: Color?
    var horizontalSpacing = CGFloat(12)
    var verticalPadding = CGFloat(14)
    var horizontalPadding: CGFloat? = nil
    var choicesConfiguration = SettingPicker<T>.ChoicesConfiguration()
    
    /// 值改变时回调函数
    var changeFunc: (_ value: T)->Bool
    
    @State var isActive = false
    
    /// 临时值,menu模式时,用来还原初始值
    @State var tempValue: T? = nil
    
    var body: some View {
        switch choicesConfiguration.pickerDisplayMode {
        case .navigation:
            Button {
                isActive = true
            } label: {
                HStack(spacing: horizontalSpacing) {
                    if let icon {
                        SettingIconView(icon: icon)
                    }
                    
                    Text(title)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, verticalPadding)
                    
                    if let selected = self.data.first(where: { $0.value == self.value }){
                        Text(selected.label).font(.subheadline)
                            .foregroundColor(foregroundColor ?? settingSecondaryColor)
                    }
                    
                    Image(systemName: "chevron.forward")
                        .foregroundColor(foregroundColor ?? settingSecondaryColor)
                }
                .padding(.horizontal, horizontalPadding ?? edgePadding)
                .accessibilityElement(children: .combine)
            }
            .buttonStyle(.row)
            .background {
                NavigationLink(isActive: $isActive) {
                    SettingPickerChoicesView(
                        title: self.title,
                        data: self.data,
                        value: self.$value,
                        choicesConfiguration: self.choicesConfiguration,
                        changeFunc: self.changeFunc
                    )
                } label: {
                    EmptyView()
                }
                .opacity(0)
            }
            
        case .menu:
            HStack(spacing: horizontalSpacing) {
                if let icon {
                    SettingIconView(icon: icon)
                }
                
                Text(self.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, self.verticalPadding)
                
                let index = self.data.firstIndex(where: { $0.value == self.value })
                Picker("", selection: self.$value) {
                    ForEach(Array(zip(self.data.indices, self.data)), id: \.1) { index, item in
                        Text(item.label).tag(item.value)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: self.value){ newValue in
                    if self.changeFunc(newValue){//允许改变
                        self.tempValue = newValue
                    } else {
                        self.value = self.tempValue!
                    }
                }
#if os(iOS)
                .padding(.trailing, -edgePadding + 2)
#else
                .padding(.trailing, -2)
#endif
                .tint(foregroundColor ?? settingSecondaryColor)
            }
            .padding(.horizontal, horizontalPadding ?? edgePadding)
            .accessibilityElement(children: .combine)
            .onAppear{
                self.tempValue = self.value
            }
        case .inline:
            VStack{
                HStack(spacing: self.horizontalSpacing) {
                    if let icon {
                        SettingIconView(icon: icon)
                    }
                    
                    Text(self.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, self.verticalPadding)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(foregroundColor ?? settingSecondaryColor)
                }
                .padding(.horizontal, horizontalPadding ?? edgePadding)
                .accessibilityElement(children: .combine)
                Divider()
                ForEach(Array(zip(self.data.indices, self.data)), id: \.1) { index, item in
                    Button {
                        if self.changeFunc(item.value){//允许改变
                            self.value = item.value
                        }
                    } label: {
                        HStack {
                            Text(item.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, choicesConfiguration.verticalPadding)
                            
                            if item.value == self.value {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .frame(width: 10,height:10)
                            }
                        }
                        .padding(.horizontal, choicesConfiguration.horizontalPadding)
                    }
                    .buttonStyle(.row)
                }
            }
        }
    }
}

struct SettingPickerChoicesView<T:Hashable>: View {
    
    @Environment(\.dismiss) var dismiss
    
    /// 显示标题
    let title: String
    
    /// 选择数据
    var data: [SettingPickerData<T>]
    
    /// 当前选中的值
    @Binding var value: T
    
    /// 显示模式
    var choicesConfiguration: SettingPicker<T>.ChoicesConfiguration
    
    /// 值改变时回调函数
    var changeFunc: (_ value: T)->Bool
    
    var body: some View {
        SettingPageView(title: title, navigationTitleDisplayMode: choicesConfiguration.pageNavigationTitleDisplayMode) {
            let settingGroupView = SettingGroupView(
                header: choicesConfiguration.groupHeader,
                footer: choicesConfiguration.groupFooter,
                horizontalPadding: choicesConfiguration.groupHorizontalPadding,
                backgroundColor: choicesConfiguration.groupBackgroundColor,
                backgroundCornerRadius: choicesConfiguration.groupBackgroundCornerRadius,
                dividerLeadingMargin: choicesConfiguration.groupDividerLeadingMargin,
                dividerTrailingMargin: choicesConfiguration.groupDividerTrailingMargin,
                dividerColor: choicesConfiguration.groupDividerColor
            ) {
                ForEach(Array(zip(self.data.indices, self.data)), id: \.1) { index, item in
                    Button {
                        if self.changeFunc(item.value){//允许改变
                            self.value = item.value
                            
                            //返回上一页面
                            self.dismiss()
                        }
                    } label: {
                        HStack {
                            Text(item.label)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, choicesConfiguration.verticalPadding)
                            
                            if item.value == self.value {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.horizontal, choicesConfiguration.horizontalPadding)
                    }
                    .buttonStyle(.row)
                }
            }
#if os(iOS)
            if #available(iOS 16.0, *) {
                settingGroupView.toolbar(.hidden, for: .tabBar)
            } else {
                settingGroupView
            }
#else
            settingGroupView
#endif
        }
    }
}

/**
 * 设置选择器数据模型
 */
public struct SettingPickerData<T:Hashable>: Hashable{
    
    // 显示文本
    public let label: String
    
    //值
    public let value: T
    
    public init(_ label: String, _ value: T) {
        self.label = label
        self.value = value
    }
}
