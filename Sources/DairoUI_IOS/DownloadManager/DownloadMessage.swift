//
//  DownloadMessage.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//

///下载通知消息
public struct DownloadMessage {
    
    /// 状态值
    public let status: DownloadStatus
    
    /// 消息数据
    public let data: Any?
    
    init(status: DownloadStatus, data: Any? = nil) {
        self.status = status
        self.data = data
    }
}
