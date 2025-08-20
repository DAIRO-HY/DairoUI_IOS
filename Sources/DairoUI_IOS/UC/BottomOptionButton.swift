//
//  UCOptionMenuButton.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/05/04.
//

import SwiftUI

public struct BottomOptionButton: View {
    
    ///高度
    private let HEIGHT = 42.0
    
    ///标题
    private let label: String
    
    ///图标
    private let icon: String
    
    ///字体颜色
    //    final Color? color;
    
    ///是否禁用
    private let disabled: Bool
    
    ///点击回调事件
    private let action: () -> Void
    
    public init(_ label: String, icon: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.disabled = disabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: self.action){
            VStack{
                Spacer().frame(height: 5)
                Image(systemName: self.icon)
                Text(self.label)
                    .font(.footnote)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity)
            .opacity(self.disabled ? 0.5 : 1)
        }
        .buttonStyle(.row)
        .disabled(self.disabled)
        .frame(maxWidth: .infinity)
    }
}
