//
//  FileListViewItem.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI
import DairoUI_IOS

class DownloadItemViewModel : ObservableObject{
    
    /// 当前下载信息
    let dto: DownloadDto
    
    /// 文件总大小
    @Published var total: Int64 = 1
    
    /// 已经下载大小
    @Published var downloaded: Int64 = 0
    
    /// 下载错误
    @Published var error: String? = nil
    
    /// 下载状态
    @Published var downloadState: String = ""
    
    /// 进度信息
    @Published var progressInfo: String = ""
    
    /// 是否已经下载完成
    @Published var isDownloaded = false
    init(_ id: String){
        self.dto = DownloadDBUtil.selectOne(id)!
        self.total = Int64(dto.date)
        self.error = dto.error
        if self.dto.state == 0{
            self.downloadState = "等待下载"
        } else if self.dto.state == 1{
            self.downloadState = "下载中"
        } else if self.dto.state == 2{
            self.downloadState = "已暂停"
        } else if self.dto.state == 3{
            self.downloadState = "下载失败"
        } else if self.dto.state == 10{
            self.downloadState = "下载完成"
            self.isDownloaded = true
        }
    }
    
    deinit{
        print("-->DownloadItemViewModel.deinit")
    }
}

public struct DownloadItemView: View {
    
    private let isSelectMode = false
    
    ///文件信息
    @ObservedObject private var vm: DownloadItemViewModel
    public init(_ id: String) {
        self.vm = DownloadItemViewModel(id)
    }
    public var body: some View {
        HStack{
            
            //缩略图
            self.thumb
            VStack{
                Text(self.vm.dto.id)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    Text(DateUtil.format(self.vm.dto.date))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(self.vm.total.fileSize)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                if !self.vm.isDownloaded{
                    ProgressView(value: Float64(self.vm.downloaded), total: Float64(self.vm.total))
                        .progressViewStyle(.linear)
                        .tint(.blue)
                    HStack{
                        if let error = self.vm.error{
                            Button(action:{
                                Toast.show(error)
                            }){
                                Text(error).font(.footnote).foregroundColor(.red)
                                    .lineLimit(1)                       // 禁止换行，只显示一行
                                    .truncationMode(.tail)              // 超出部分显示省略号
                            }
                        } else {
                            Text(self.vm.progressInfo)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(self.vm.downloadState)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }.onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.vm.dto.id))){
                let userInfo = $0.userInfo!
                switch userInfo["key"] as! DownloadNotify{
                case .progress:/// 进度回调
                    let progress = userInfo["value"] as! [Int64]
                    self.vm.total = progress[0]
                    self.vm.downloaded = progress[1]
                    //                    self.vm.speed = progress[2].fileSize + "/S"
                    self.vm.progressInfo = "\(progress[1].fileSize)(\(progress[2].fileSize)/S)"
                    self.vm.downloadState = "下载中"
                case .finish:
                    guard let error = userInfo["value"] as? Error else{
                        self.vm.isDownloaded = true
                        self.vm.downloadState = "下载完成"
                        return
                    }
                    self.vm.downloadState = "下载失败"
                    if let error = error as? DownloaderError{
                        if case let .error(msg) = error {
                            self.vm.error = msg
                        }
                    } else {
                        self.vm.error = error.localizedDescription
                    }
                }
            }
            //                    if self.isSelected{//当前为选中状态
            //                        Image(systemName: "checkmark.circle")
            //                            .font(.title2)
            //                    } else {
            //                        Image(systemName: "circle")
            //                            .font(.title2)
            //                    }
        }
        .padding(.horizontal)
    }
    
    ///缩略图
    private var thumb: some View{
        Section{
            //                if self.dfsFile.fm.hasThumb{//如果有缩略图
            //                    CacheImage(self.dfsFile.fm.thumbUrl)
            //                        .frame(width: 50, height: 50)
            //                        .cornerRadius(6)
            //                } else {//没有缩略图
            //                    Image(systemName: "document.fill")
            //                        .resizable()
            //                        .frame(width: 50, height: 50)
            //                        .foregroundColor(.white)
            //                }
            Image(systemName: "document.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
        }
    }
}

//#Preview {
//    VStack{
//        DownloadItemView(getDownloadDto())
//        Button(action:{
//            Downloader("ID12345678", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100"){_,err in
//                print("-->下载失败:\(err)")
//            }.download()
//        }){
//            Text("BUTTON")
//        }.padding()
//    }
//}
//
//private func getDownloadDto() -> DownloadDto{
//    let dfb = DownloadDto(
//        id: "ID12345678",
//        url: "",
//        state: 0,
//        saveType: 1,
//        date: 1234567,
//        useDate: 1234556,
//        error: nil
//    )
//    return dfb
//}

