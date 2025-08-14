//
//  DownloadDto.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/14.
//

/// 下载信息
public struct DownloadDto{
    
    /// 文件id
    public let id: String
    
    /// 下载URL
    public let url: String
    
    /// 文件名
    public let name: String
    
    /// 文件大小
    public let size: Int64
    
    /// 文件状态 0:等待下载 1:下载中 2:暂停中 3:下载失败  10:下载完成
    public let state: Int8
    
    /// 文件保存方式 0:临时缓存 1:永久保存
    public let saveType: Int8
    
    /// 文件创建时间戳(秒)
    public let date: Int
    
    /// 文件最后使用时间戳(秒)
    public let useDate: Int
    
    /// 文件下载失败的错误消息
    public let error: String?
    
    public init(id: String, url: String, name: String, size: Int64, state: Int8, saveType: Int8, date: Int, useDate: Int, error: String?) {
        self.id = id
        self.url = url
        self.name = name
        self.size = size
        self.state = state
        self.saveType = saveType
        self.date = date
        self.useDate = useDate
        self.error = error
    }
}
