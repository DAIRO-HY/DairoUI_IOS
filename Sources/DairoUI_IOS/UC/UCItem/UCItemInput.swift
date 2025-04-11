//
//  GLItemInput.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/10.
//

import SwiftUI

struct UCItemInput: View {
    
    // 要绑定的值
    var text: Binding<String>
    
    // 输入框未输入提示
    private let hide: String
    
    // 提示文字
    private let title: String
    
    /**
     * 是否显示图标
     */
    private let icon: String?
    
    // 显示类型
    private let type: UCTextFiledType
    
    /**
     是否显示线
     */
    private let showLine: Bool	
    
    /** #初始化
     - parameter title:提示文字
     - parameter text:绑定的文本
     - parameter hide:没有输入是提示文字
     - parameter type:输入框类型
     - parameter showLine:是否要显示线
     */
    init(title:String,
         text: Binding<String>,
         hide: String = "",
         type: UCTextFiledType = .text,
         showLine: Bool = true,
         icon: String? = nil) {
        self.text = text
        self.hide = hide
        self.type = type
        self.title = title
        self.showLine = showLine
        self.icon = icon
    }
    var body: some View {
        HStack(spacing: 0){
            if let icon = self.icon{//有显示图标的情况下
                Image(systemName: icon).foregroundColor(Color.gl.textContent)
                    .padding()
            }else{
                Spacer().frame(width: 0).padding(.leading)
            }
            VStack(spacing: 0) {
                HStack {
                    Text(title).padding(.trailing,20).font(.body).foregroundColor(Color.gl.textContent)
                    switch type {
                    case UCTextFiledType.text:
                        TextField(hide, text: text).font(.body)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.gl.textContent)
                    case UCTextFiledType.password:
                        SecureField(hide, text: text).font(.body)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Color.gl.textContent)
                    }
                }
                .padding(.vertical, UCItemConst.ITEM_PADDING)
                .padding(.trailing)
                
                //是否显示线
                if self.showLine{
                    Line()//线
                }
            }
        }
    }
}

struct UCItemInput_Previews: PreviewProvider {
    
    @State static var previewText = "xxxxxxxxx@qq.com"
    static var previews: some View {
        UCItemInput(title: "提示标题", text: $previewText, icon: "person")
    }
}
