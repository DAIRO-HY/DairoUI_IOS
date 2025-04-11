//
//  TextFiledIcon.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/5.
//

import SwiftUI

// 带图片的输入框类型
enum UCTextFiledType{
    case text //普通文本输入框
    case password //密码输入框
}

//自定义带图标的文本输入框
struct UCTextFiled: View {
    
    /**
     左边自定义控件
     */
    private var mLeftView: AnyView?
    
    /**
     右边自定义控件
     */
    private var mRightView: AnyView?
    
    // 要绑定的值
    private var mText: Binding<String>
    
    // 提示文字
    private let mHide: String
    
    // 显示类型
    private let mType:UCTextFiledType
    
    
    /** #初始化
     - parameter text:绑定的文本
     - parameter hide:没有输入时提示信息
     - parameter type:输入框类型
     - parameter leftView:左边自定义视图
     - parameter rightView:右边自定义视图
     */
    init(text: Binding<String>,
         hide:String = "",
         type: UCTextFiledType = .text,
         leftView: AnyView? = nil,
         rightView: AnyView? = nil
    ){
        self.mText = text
        self.mType = type
        self.mHide = hide
        self.mLeftView = leftView
        self.mRightView = rightView
    }
    
    /** #初始化
     - parameter text:绑定的文本
     - parameter icon:显示的图标样式
     - parameter hide:没有输入时提示信息
     - parameter type:输入框类型
     - parameter rightView:右边自定义视图
     */
    init(icon: String,
         text: Binding<String>,
         hide:String = "",
         type: UCTextFiledType = .text,
         rightView: AnyView? = nil
    ) {
        let icon = Image(systemName: icon)
            .frame(width:34)
            .foregroundColor(Color.gl.textContent)
            .font(.system(.body))
        
        let leftView = AnyView(icon)//左侧为一个图标
        self.init(text: text, hide:hide, type: type, leftView: leftView, rightView: rightView)
    }
    
    var body: some View {
        HStack {
            if let rv = mLeftView {//如果有左边自定义控件
                rv
            }
            switch mType {
            case UCTextFiledType.text:
                TextField(mHide, text: mText)
                    .keyboardType(.emailAddress) // 确保输入法切换
                    .autocapitalization(.none) // 可选：关闭自动大写
                    .disableAutocorrection(true) // 可选：关闭自动校正
                    .font(.body)
                    .foregroundColor(Color.gl.textContent)
            case UCTextFiledType.password:
                SecureField(mHide, text: mText)
                    .font(.body)
                    .foregroundColor(Color.gl.textContent)
            }
            if let rv = mRightView {//如果有右边自定义控件
                rv
            }
        }
        .padding(.vertical,10)
        .padding(.trailing)
        .background(Color.gl.bgContent)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(lineWidth: 1).foregroundColor(Color.gl.borderPrimary))
    }
}

struct UCTextFiled_Previews: PreviewProvider {
    @State static var previewText = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@qq.com"
    static var previews: some View {
        UCTextFiled(icon:"lock.square.fill",text: $previewText, rightView: AnyView(Text("发送验证码")))
    }
}

