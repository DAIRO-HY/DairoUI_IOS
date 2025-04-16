//
//  DownloadingInfo.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//

///正在下载的文件信息
struct DownloadingInfo {
    
    /// 文件路径
    let path: String
    
    /// 文件下载url
    let url: String
    init(path: String, url: String) {
        self.path = path
        self.url = url
    }
}
