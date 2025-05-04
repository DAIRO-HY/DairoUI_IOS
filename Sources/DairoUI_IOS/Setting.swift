//
//  SettingTheme.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 The base protocol for views shown in the `SettingBuilder`.
 */
public protocol Setting {
    var id: AnyHashable? { get set }
}

public extension Setting {
    /**
     A unique identifier for the view.
     */
    var identifier: AnyHashable? {
        if let id = self.id {
            return id
        }
        return self.textIdentifier
    }

    /**
     The identifier generated from the setting's title.
     */
    var textIdentifier: AnyHashable? {
        switch self {
        case let text as SettingText:
            return text.title
//        case let label as SettingLabel:
//            return label.property.title
        case let button as SettingButton:
            return button.title
        case let button as SettingButtonSingle:
            return button.title
        case let settingView as SettingNavigationLink<AnyView>:
            return settingView.title
        case let toggle as SettingToggle:
            return toggle.title
        case is SettingSlider:
            return nil
        case let picker as SettingPicker<Int>:
            return picker.title
        case let picker as SettingPicker<Int64>:
            return picker.title
        case let picker as SettingPicker<String>:
            return picker.title
        case let picker as SettingPicker<Float>:
            return picker.title
        case let picker as SettingPicker<Float64>:
            return picker.title
        case let textField as SettingTextField:
            return textField.title
        case let page as SettingPage:
            return page.title
        case let group as SettingGroup:
            return group.tuple.identifier
        case let tuple as SettingTupleView:
            return tuple.flattened.compactMap { "\($0.identifier)" }.joined()
        case let customView as SettingCustomView:
            return customView.titleForSearch ?? "Custom"
        default:
            print("Text identifier was nil for: \(type(of: self))")
            return nil
        }
    }

    /**
     Text for searching.
     */
    var text: String? {
        switch self {
        case let v as SettingText:
            return v.title
//        case let v as SettingLabel:
//            return v.property.title
        case let v as SettingButton:
            return v.title
        case let v as SettingButtonSingle:
            return v.title
        case let v as SettingNavigationLink<AnyView>:
            return v.title
        case let toggle as SettingToggle:
            return toggle.title
        case is SettingSlider:
            return nil
        case let picker as SettingPicker<Int>:
            return picker.title
        case let picker as SettingPicker<Int64>:
            return picker.title
        case let picker as SettingPicker<String>:
            return picker.title
        case let picker as SettingPicker<Float>:
            return picker.title
        case let picker as SettingPicker<Float64>:
            return picker.title
        case let textField as SettingTextField:
            return textField.title
        case let page as SettingPage:
            return page.title
        case let group as SettingGroup:
            return group.header
        case is SettingTupleView:
            return nil
        case let customView as SettingCustomView:
            return customView.titleForSearch
        default:
            return nil
        }
    }
}
