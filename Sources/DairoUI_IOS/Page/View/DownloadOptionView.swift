//
//  FileOptionBarView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

struct DownloadOptionView: View {
    
    @EnvironmentObject var vm: DownloadViewModel
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 8){
            Divider()
            HStack{
                Text("已选择:\(self.vm.checked.count)").foregroundColor(.secondary)
                Spacer()
                Button(action:{
                    self.vm.checked.removeAll()
                    self.vm.saveType = self.vm.saveType == 0 ? 1 : 0
                    self.vm.reload()
                }){
                    HStack(spacing: 0){
                        Text("下载")
                            .padding(.vertical,5)
                            .padding(.horizontal,5)
                            .foregroundColor(Color.gl.black)
                            .background(self.vm.saveType == 1 ? Color.clear : .secondary)
                            .opacity(self.vm.saveType == 1 ? 1 : 0.3)
                        Text("缓存")
                            .padding(.vertical,5)
                            .padding(.horizontal,5)
                            .foregroundColor(Color.gl.black)
                            .background(self.vm.saveType == 0 ? Color.clear : .secondary)
                            .opacity(self.vm.saveType == 0 ? 1 : 0.3)
                    }.border(Color.black, width: 2)
                }
            }.padding(.horizontal, 5)
            Divider()
            HStack{
                DwonloadOptionButton("全选", icon: "checklist.checked", action: self.vm.onCheckAllClick)
                DwonloadOptionButton("共有", icon: "square.and.arrow.up", disabled: self.vm.checked.isEmpty, action: self.vm.onPauseAllClick)
                DwonloadOptionButton("删除", icon: "trash", disabled: self.vm.checked.isEmpty){
                    self.showDeleteAlert = true
                }
                .alert("确认删除吗？", isPresented: $showDeleteAlert) {
                    Button("删除", role: .destructive) {
                        self.vm.onDeleteClick()
                    }
                    Button("取消", role: .cancel) { }
                } message: {
                    Text("此操作无法撤销")
                }
                DwonloadOptionButton("全暂停", icon: "pause.circle", action: self.vm.onPauseAllClick)
                DwonloadOptionButton("全开始", icon: "play.circle", action: self.vm.onStartAllClick)
                DwonloadOptionButton("设置", icon: "gearshape", action: self.vm.onPauseAllClick)
            }
        }
    }
}


#Preview {
    DownloadOptionTestView()
}

struct DownloadOptionTestView: View {
    
    @StateObject
    private var vm = DownloadViewModel()
    var body: some View {
        DownloadOptionView().environmentObject(self.vm)
    }
}
