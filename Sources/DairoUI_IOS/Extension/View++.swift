//
//  View++.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/7.
//

import SwiftUI

/**
 扩展GLPage功能
 */
public extension View {
    
    /**
     关闭其他所有页面,跳转到该页面
     */
    public func relaunch() {
#if os(iOS)
        let screnDelegate: UIWindowSceneDelegate? = {
            var uiScreen: UIScene?
            UIApplication.shared.connectedScenes.forEach { (screen) in
                uiScreen = screen
            }
            return (uiScreen?.delegate as? UIWindowSceneDelegate)
        }()
        screnDelegate?.window!?.rootViewController = UIHostingController(rootView: UCRoot{
            self
        })
#endif
    }
}
