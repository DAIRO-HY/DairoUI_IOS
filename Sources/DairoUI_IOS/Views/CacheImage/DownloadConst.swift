//
//  DownloadConst.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/13.
//

import Foundation

/// 文件下载的常量配置
enum DownloadConst{
    
    /// 最大缓存文件下载上限
    /// 缓存文件下载上限一定要大于保存文件下载上限,否则,当保存下载达到上限之后,缓存下载无法工作
    static let maxCachingCount = 4
    
    /// 最大保存文件下载上限
    static let maxSavingCount = 1
    
    /// 下载文件保存的文件夹
    static let saveFolder = DownloadConst.getSaveFolder()
    
    /// 数据库文件保存目录
    static let dbFile = DownloadConst.getDBFile()
    
    /// 获取下载保存文件夹
    private static func getSaveFolder() -> String{
        var downloadURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("download")
        if !FileManager.default.fileExists(atPath: downloadURL.path){//如果文件夹不存在,则创建文件夹
            try? FileManager.default.createDirectory(at: downloadURL, withIntermediateDirectories: true)
            
            //设置文件夹不允许备份到iCloud
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? downloadURL.setResourceValues(values)
        }
        return downloadURL.path
    }
    
    /// 获取数据库文件目录
    private static func getDBFile() -> String{
        var dbURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("download.sqlite")
        if !FileManager.default.fileExists(atPath: dbURL.path){//如果文件不存在,则创建文件
            
            //先创建一个空文件
            FileManager.default.createFile(atPath: dbURL.path, contents: nil)
            
            //设置文件不允许备份到iCloud
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? dbURL.setResourceValues(values)
        }
        return dbURL.path
    }
}
