//
//  RootGroup.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/23.
//

import Foundation
import SwiftUI


public struct RootView<Content>: View where Content: View {
    
    @StateObject public var rootVm = RootViewModel()
    
    /// 子控件
    @ViewBuilder public var content: Content
    public init( @ViewBuilder content: () -> Content) {
        self.content = content()
    }
    public var body: some View {
        ZStack{
            self.content
            LoadingAnimationView().environmentObject(self.rootVm)
            ToastView().environmentObject(self.rootVm)
        }.onAppear{
            RootViewManager.add(rootVm)
        }.onDisappear{
            RootViewManager.remove(rootVm)
        }
    }
}

#Preview {
    RootView{
        Button("按钮"){
        }
    }.onAppear{
        Toast.show("Toast消息", delay: 10000000)
        Loading.show()
    }
}

