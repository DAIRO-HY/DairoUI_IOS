//
//  SettingButtonSingle.swift
//  Setting
//
//  Created by A. Zheng (github.com/aheze) on 2/21/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 普通的按钮
 */
public struct SettingButtonSingle: View, @preconcurrency Setting {
    public var id: AnyHashable?
    public var title: String
    public var verticalPadding = CGFloat(14)
    public var action: () -> Void
    public init(
        id: AnyHashable? = nil,
        title: String,
        verticalPadding: CGFloat = CGFloat(14),
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.verticalPadding = verticalPadding
        self.action = action
    }
    
    public var body: some View {
        SettingButtonSingleView(
            title: self.title,
            verticalPadding: self.verticalPadding,
            action: self.action
        )
    }
}

struct SettingButtonSingleView: View {
    @Environment(\.edgePadding) var edgePadding
    @Environment(\.settingSecondaryColor) var settingSecondaryColor
    let title: String
    var verticalPadding = CGFloat(14)
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {

                    Text(title)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, verticalPadding)
                    
            }
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.row)
    }
}
