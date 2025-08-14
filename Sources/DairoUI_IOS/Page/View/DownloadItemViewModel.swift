//
//  DownloadItemViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/14.
//

import Foundation

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
//    @Published var downloadState: String = ""
    
    /// 进度信息
    @Published var progressInfo: String = ""
    
    /// 是否已经下载完成
//    @Published var isDownloaded = false
    
    /// 下载状态
    @Published var downloadState: Int8 = 0
    
    /// 下载状态
    @Published var downloadStateLabel = ""
    init(_ id: String){
        self.dto = DownloadDBUtil.selectOne(id)!
        self.total = Int64(self.dto.size)
        self.error = dto.error
        self.setDownloadState(self.dto.state)
        if self.dto.state == 10{
            return
        }
        
        //得到文件下载中存储路径
        let downloadingPath = Downloader.getDownloadingPath(id)
        if FileManager.default.fileExists(atPath: downloadingPath){
            self.downloaded = FileUtil.getFileSize(downloadingPath) ?? 0
            self.progressInfo = self.downloaded.fileSize
        }
    }
    
    /// 设置下载状态
    func setDownloadState(_ state: Int8){
        if state == 0{
            self.downloadStateLabel = "等待下载"
        } else if state == 1{
            self.downloadStateLabel = "下载中"
        } else if state == 2{
            self.downloadStateLabel = "已暂停"
        } else if state == 3{
            self.downloadStateLabel = "下载失败"
        } else if state == 10{
            self.downloadStateLabel = "下载完成"
        }
        self.downloadState = state
    }
    
    /// 暂停/开始点击事件
    func onDownloadStateClick(){
        if self.downloadState == 0 || self.downloadState == 1{// 当前准备下载或正在下载中
            DownloadManager.cancel(self.dto.id, isForce: true)
            self.setDownloadState(2)
            
            //将其设置为暂停中
            DownloadDBUtil.updateState(self.dto.id, 2)
        } else {
            self.error = nil
            self.setDownloadState(0)
            
            //将其设置为准备下载中
            DownloadDBUtil.updateState(self.dto.id, 0)
            
            //开启循环下载
            DownloadManager.loopDownloadByWaiting()
        }
    }
    
    deinit{
        print("-->DownloadItemViewModel.deinit")
    }
}
