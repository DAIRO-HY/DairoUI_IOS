//
//  GLItemGroup.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/12.
//

import SwiftUI

class UCItemConst{
    
    /**
     * 条目内边距
     */
    static let ITEM_PADDING = CGFloat(12)
}

/**
 上下各一条线的容器
 */
struct UCItemGroup<Content>: View where Content : View {
    
    /**
     * 距离顶部距离
     */
    var marginTop = 30
    
    /**
     * 标题
     */
    var title: String?
    
    @ViewBuilder private var mContent: () -> Content
    init(marginTop: Int = 30, title:String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.marginTop = marginTop
        self.title = title
        self.mContent = content
    }
    var body: some View {
        VStack {
            Spacer().frame(height: CGFloat(self.marginTop))
            if let title = self.title{
                Text(title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(Color.gl.textContent)
                    .padding(.leading, 10)
                Spacer().frame(height: 8)
            }
            VStack(spacing: 0) {
                Group(content: mContent).background(Color.gl.bgContent)
            }
            .frame(maxWidth:.infinity)
            .background(Color.gl.bgContent)
            .cornerRadius(10)
        }
    }
}

struct UCItemGroup_Previews: PreviewProvider {
    static var previews: some View {
        UCItemGroup(title: "这是标题") {
            VStack {
                UCItemLabel("一条数据",subTitle:"这里是说明1235678")
                UCItemLabel("一条数据",subTitle:"这里是说明1235678")
                UCItemLabel("一条数据",subTitle:"这里是说明1235678",showLine: false)
            }
        }
    }
}
