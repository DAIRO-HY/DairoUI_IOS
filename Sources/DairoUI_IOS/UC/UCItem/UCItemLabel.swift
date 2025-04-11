//
//  GLItem.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/8.
//

import SwiftUI

struct UCItemLabel : View {
    
    /**
     标题
     */
    private let title: String
    
    /**
     提示信息
     */
    private let subTitle: String?
    
    /**
     是否显示线
     */
    private let showLine: Bool
    
    /**
     * 是否显示向右的箭头
     */
    private let showRightIcon: Bool
    
    /**
     * 是否显示图标
     */
    private let icon: String?
    
    
    /** #初始化
     - parameter title:提示文字
     - parameter subTitle:提示信息
     - parameter showLine:是否要显示线
     */
    init(_ title: String,
         subTitle: String? = nil,
         icon: String? = nil,
         showRightIcon: Bool = true,
         showLine: Bool = true) {
        self.title = title
        self.subTitle = subTitle
        self.icon = icon
        self.showLine = showLine
        self.showRightIcon = showRightIcon
    }
    
    var body: some View {
        HStack(spacing: 0){
            if let icon = self.icon{//有显示图标的情况下
                Image(systemName: icon).font(.body).foregroundColor(Color.gl.textContent)
                    .padding(.horizontal)
            }else{
                Spacer().frame(width: 0).padding(.leading)
            }
            VStack(spacing: 0) {
                HStack{
                    Text(title).font(.body).foregroundColor(Color.gl.textContent)
                    if subTitle != nil {
                        Text(subTitle!)
                            .font(.body)
                            .foregroundColor(Color.gl.textSecondary)
                            .frame(maxWidth: .infinity,alignment: .trailing)
                    }else{
                        Spacer()
                    }
                    if self.showRightIcon {
                        Image(systemName: "chevron.right").foregroundColor(Color.gl.textSecondary)
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

struct PageRow_Previews : PreviewProvider {
    static var previews: some View {
        UCItemLabel("一条数据", subTitle:"这里是说明1235678", icon: "person")
    }
}
