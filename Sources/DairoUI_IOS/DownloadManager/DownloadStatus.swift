//
//  DownloadStatus.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//

//异步上传结果状态值
public enum DownloadStatus {

  ///公开内部消息通信端口
  case SENDPORT

  ///上传完成
  case OK

  ///上传失败
  case FAIL

  ///上传进度
  case PROGRESS

  ///更新消息
  case MESSAGE
}
