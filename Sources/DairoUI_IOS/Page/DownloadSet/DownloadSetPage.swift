//
//  DownloadSetPage.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/15.
//

import SwiftUI

struct DownloadSetPage: View {
    @State private var showDeleteAlert = false
    
    @StateObject private var vm = DownloadSetViewModel()
    
    /// 同时下载文件数
    @State private var maxSavingCount = DownloadConst.maxSavingCount
    
    /// 同时缓存文件数
    @State private var maxCachingCount = DownloadConst.maxCachingCount
    
    /// 缓存文件保存期限
    @State private var cacheSaveDay = DownloadConst.cacheSaveDay
    
    /// 同时下载文件数模版
    private let downloadAsyncCountDemo = [1,2,3,4,5,6,7,8,9,10].map{
        SettingPickerData("\($0)",$0)
    }
    
    /// 缓存文件保存期限模版
    private let cacheSaveDayDemo = [
        SettingPickerData("1天", 1),
        SettingPickerData("1星期", 7),
        SettingPickerData("1个月(30天)", 30),
        SettingPickerData("3个月(90天)", 90),
        SettingPickerData("6个月(180天)", 180),
        SettingPickerData("1年(365天)", 365),
        SettingPickerData("永久", Int.max),
    ]
    
    var body: some View {
        SettingStack{
            SettingPage(navigationTitleDisplayMode:.inline){
                SettingGroup{
                    SettingPicker("同时下载文件数",data: self.downloadAsyncCountDemo, value: self.$maxSavingCount){ value in
                        if value >= DownloadConst.maxCachingCount{
                            Toast.show("同时下载文件数必须小于同时缓存文件数")
                            return false
                        }
                        DownloadConst.maxSavingCount = value
                        return true
                    }
                    .icon("square.and.arrow.down.fill", backgroundColor: Color.red)
                    SettingPicker("同时缓存文件数",data: self.downloadAsyncCountDemo, value: self.$maxCachingCount){ value in
                        if value <= DownloadConst.maxSavingCount{
                            Toast.show("同时缓存文件数必须大于同时下载文件数")
                            return false
                        }
                        DownloadConst.maxCachingCount = value
                        return true
                    }
                    .icon("square.and.arrow.down.fill", backgroundColor: Color.green)
                }
                
                SettingGroup{
                    SettingPicker("缓存文件保存期限",data: self.cacheSaveDayDemo, value: self.$cacheSaveDay){ value in
                        DownloadConst.cacheSaveDay = value
                        return true
                    }
                    .icon("timer.circle.fill", backgroundColor: Color.orange)
                }
                
                SettingGroup{
                    for it in self.vm.usedSizeList{
                        SettingButton(it.title, tip: it.size.fileSize){
                            self.vm.deleteTargetDate = it.date
                            self.showDeleteAlert = true
                        }
                        .icon("calendar", backgroundColor: Color.cyan)
                    }
                }
            }
        }
        .alert("确认删除这些缓存吗？", isPresented: $showDeleteAlert) {
            Button("删除", role: .destructive) {
                self.vm.onDeleteClick()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("此操作无法撤销")
        }
        .navigationTitle("下载设置")
    }
}

#Preview {
    DownloadSetPage()
}
