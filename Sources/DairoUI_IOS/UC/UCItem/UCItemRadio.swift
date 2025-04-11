//
//  GLCheck.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/11.
//

import SwiftUI


@available(iOS 14.0, *)
struct UCItemRadio<T>: View {
    
    /**
     * 选中的值
     */
    var value: Binding<T>
    
    /**
     * 标题
     */
    var title: String?
    
    /**
     数据
     */
    private var data: [(label: String, value: T)]
    
    /**
     选中的值
     */
    private var checkedValue: Any?
    
    init(title:String? = nil, value: Binding<T>, _ data: [(label: String, value: T)], checkedValue: Any? = nil){
        self.title = title
        self.data = data
        self.checkedValue = checkedValue
        self.value = value
    }
    var body: some View {
        ZStack{
            UCItemGroup(title: self.title) {
                ForEach(0..<data.count,id:\.self) { i in
                    let item = data[i]
                    Button(action:{
                        self.value.wrappedValue = item.value
                    }){
                        HStack {
                            
                            //名称
                            Text(item.label).foregroundColor(Color.gl.textContent)
                            Spacer()
                            if equal(self.value.wrappedValue, item.value){//选中当前值
                                Image(systemName: "record.circle")
                                    .foregroundColor(Color.gl.textPrimary)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color.gl.textPrimary).opacity(0.5)
                            }
                        }
                        .font(.body)
                        .padding(.vertical, UCItemConst.ITEM_PADDING)
                        .padding(.horizontal)
                    }
                    if (i != data.endIndex - 1){//最后一条线不要显示
                        Line().padding(.leading)//线
                    }
                }
            }
        }
    }
}


@available(iOS 14.0, *)
struct UCRadioPage_Previews: PreviewProvider {
    static var data = [(label: "语文", value: 1), (label: "数学", value: 2), (label: "英语", value: 3), (label: "化学", value: 4)]
    
    /**
     * 用户所有收藏
     */
    static var previews: some View {
        @State var value = 0
        UCItemRadio<Int>(title:"标题", value: $value, data, checkedValue: 2)
    }
}
