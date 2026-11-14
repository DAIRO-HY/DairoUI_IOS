//
//  RootView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/23.
//

import Foundation
import SwiftUI


public struct RootView<Content>: View where Content: View {
    
    @StateObject public var rootViewModel = RootViewModel()
    
    @AppStorage(ThemeMode.storageKey) private var theme = ThemeMode.system.rawValue
    
    /// 子控件
    @ViewBuilder public var content: Content
    public init( @ViewBuilder content: () -> Content) {
        self.content = content()
    }
    public var body: some View {
        ZStack{
            self.content
            LoadingAnimationView().environmentObject(self.rootViewModel)
            ToastView().environmentObject(self.rootViewModel)
        }
        .preferredColorScheme((ThemeMode(rawValue: self.theme) ?? .system).colorScheme)
        .onAppear{
            RootViewManager.add(rootViewModel)
        }.onDisappear{
            RootViewManager.remove(rootViewModel)
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

