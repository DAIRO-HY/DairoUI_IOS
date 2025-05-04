//
//  DownloadingInfo.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//

///正在下载的文件信息
struct DownloadingInfo {
    
    /// 文件下载url
    public let url: String
    
    ///文件存储路径
    public let savePath: String
    
    /// 文件下载过程中的文件路径
    var downloadingPath: String{
        return self.savePath + CacheImageDownloader.DOWNLOADING_FILE_EXT
    }
}
