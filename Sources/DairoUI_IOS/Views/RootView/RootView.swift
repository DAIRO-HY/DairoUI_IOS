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
    
    @ViewBuilder public var content: Content
    public init( @ViewBuilder content: () -> Content) {
        self.content = content()
    }
    public var body: some View {
        ZStack{
            self.content
//            LoadingAnimationView()
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
        Text("243")
    }.onAppear{
        Toast.toastMessage = ToastMessage(delay: Double(Int.max), message: "消息内容")
    }
}

