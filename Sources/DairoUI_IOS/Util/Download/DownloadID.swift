//
//  DownloadID.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//
import Foundation


/// 下载ID枚举
public enum DownloadID {
    
    /// 将当前url作为id
    case url
    
    /// 将当前url的path部分作为id
    case path
    
    /// 将当前url的path和参数部分作为id
    case pathAndQuery
    
    /// 自定义id
    case othor(_ id: String)
    
    /// 从url中获取文件id
    ///
    /// - Parameter url: 当前url
    /// - Parameter did: 转换成id的方式
    /// - Returns 文件id
    public static func ID(_ url: String, _ did: DownloadID) -> String{
        switch did{
        case .othor(let id):
            return id
        case .url:
            return url.md5
        case .path:
            var path = url[url.range(of: "://")!.upperBound...]
            if let slashIndex = path.firstIndex(of: "/"){
                path = path[slashIndex...]
                if let questionIndex = path.firstIndex(of: "?"){
                    path = path[..<questionIndex]
                }
            } else {
                path = "/"
            }
            return path.replacingOccurrences(of: "/", with: "_")
        case .pathAndQuery:
            var path = url[url.range(of: "://")!.upperBound...]
            if let slashIndex = path.firstIndex(of: "/"){
                path = path[slashIndex...]
            } else {
                path = "/"
            }
            return path.replacingOccurrences(of: "/", with: "_").md5
        }
    }
}
