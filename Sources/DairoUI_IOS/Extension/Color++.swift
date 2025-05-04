//
//  Color++.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/6.
//
import SwiftUI

//对颜色类的扩展
extension Color: GLCompatible {}
public extension GL where Base == Color {
    static var black: Color { Color("black", bundle: .module) }//黑色
    static var white: Color { Color("white", bundle: .module) }//白色
    static var likeFavorite: Color { Color("likeFavorite", bundle: .module) }//喜欢的颜色
    static var isFriendColor: Color { Color("likeFavorite", bundle: .module) }//是否友好用户标记背景色
    
    static var bg: Color { Color("bg", bundle: .module) }//背景色
    static var bgContent: Color { Color("bg-content", bundle: .module) }//内容背景色
    static var bgPrimary: Color { Color("bg-primary", bundle: .module) }//主调背景色
    static var bgSecondary: Color { Color("bg-secondary", bundle: .module) }//次要按钮背景颜色
    
    static var border: Color { Color("border", bundle: .module) }//边框颜色
    static var borderPrimary: Color { Color("border-primary", bundle: .module) }//主题按钮边框颜色
    static var borderSecondary: Color { Color("border-secondary", bundle: .module) }//次要按钮边框颜色
    
    static var textPrimary: Color { Color("text-primary", bundle: .module) }//主题字体颜色
    static var textContent: Color { Color("text-content", bundle: .module) }//内容文字颜色
    static var textSecondary: Color { Color("text-secondary", bundle: .module) }//次要文字颜色
    static var textPrimaryContent: Color { Color("text-primary-content", bundle: .module) }//主调背景时的内容文字颜色
    static var textPrimarySecondary: Color { Color("text-primary-secondary", bundle: .module) }//主调背景时的次要文字颜色
    
    static var btnTextPrimary: Color { Color("btn-text-primary", bundle: .module) }//主题按钮字体颜色
    static var btnTextSecondary: Color { Color("btn-text-secondary", bundle: .module) }//次要按钮字体颜色
    
    static var line: Color { Color("line", bundle: .module) }//线
    
    
    
    
    
}
