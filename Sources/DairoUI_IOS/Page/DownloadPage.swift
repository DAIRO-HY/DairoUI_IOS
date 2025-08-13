//
//  SwiftUIView.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//

import SwiftUI

public struct DownloadPage: View {
    
    @StateObject
    private var vm = DownloadViewModel()
    
    public init(){
    }
    public var body: some View {
        ScrollView{
            LazyVStack{
                ForEach(self.vm.ids, id: \.self) { id in
                    DownloadItemView(id)
                }
            }
        }
    }
}


struct DownloadTestage: View {
    var body: some View {
        NavigationView{
            VStack{
                Image(systemName: "document.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                NavigationLink(destination: DownloadPage()){
                    Text("页面跳转")
                }
                Button(action:{
                    var list = [(String,String)]()
                    for i in 1 ... 100{
                        list.append(("id:\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=1000000"))
                    }
                    try? DownloadManager.save(list)
                }){
                    Text("添加数据")
                }.padding()
            }
        }
    }
}

#Preview {
    DownloadPage()
}
