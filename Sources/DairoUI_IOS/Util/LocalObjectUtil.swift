//
//  LocalObjectUtil.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/22.
//

import Foundation

public protocol LocalObjectUtilEncodable {
    func toJSON() -> String
}

public enum LocalObjectUtil{
    
    ///对象序列化保存文件夹
    nonisolated(unsafe) public static var folder: String? = nil
    
    /**
     设置保存目录
     - Parameters:
     - path: 保存的文件路径
     */
    public static func setFolder(_ folder: String){
        if !FileManager.default.fileExists(atPath: folder){//判断文件夹是否存在,不存在则创建
            FileUtil.mkdirs(folder)
        }
        LocalObjectUtil.folder = folder
    }
    
    ///对象序列化保存文件夹
    public static var mFolder: String {
        if LocalObjectUtil.folder == nil{
            LocalObjectUtil.setFolder(FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("local-object").path)
        }
        return LocalObjectUtil.folder!
    }
    
    /**
     * 保存一个对象到文件
     */
    public static func write(_ obj: Codable?, _ name: String) -> Bool {
        
        //保存目录
        let path = LocalObjectUtil.mFolder + "/" + name
        guard let obj else{//obj为nil时,删除文件
            try! FileManager.default.removeItem(atPath: path)
            return true
        }
        let encoder = JSONEncoder()
        
        //写入时先排序,默认顺序是随机的
        encoder.outputFormatting = [.sortedKeys]
        let jsonData = try! encoder.encode(obj)
        if FileUtil.readAll(path) == jsonData {//避免重复写入，频繁写入会影响磁盘寿命，但读不会
            return false
        }
        FileManager.default.createFile(atPath: path, contents: jsonData)
        return true
    }
    
    /**
     * 保存一个对象到文件
     */
    public static func write(_ obj: LocalObjectUtilEncodable?, _ name: String) -> Bool {
        
        //保存目录
        let path = LocalObjectUtil.mFolder + "/" + name
        guard let obj else{//obj为nil时,删除文件
            try! FileManager.default.removeItem(atPath: path)
            return true
        }
        let jsonData = obj.toJSON().data(using: .utf8)
        if FileUtil.readAll(path) == jsonData {//避免重复写入，频繁写入会影响磁盘寿命，但读不会
            return false
        }
        FileManager.default.createFile(atPath: path, contents: jsonData)
        return true
    }
    
    /**
     * 从本地序列化文件读取到实列
     */
    public static func read<T>(_ type: T.Type, _ name: String) -> T? where T: Decodable {
        
        //保存目录
        let path = LocalObjectUtil.mFolder + "/" + name
        if !FileManager.default.fileExists(atPath: path) {//文件不存在
            return nil
        }
        guard let data = FileUtil.readAll(path) else{
            return nil
        }
        return try? JSONDecoder().decode(type.self, from: data) as T?
    }
    
    ///删除一个对象到文件
    public static func delete(_ name: String) {
        
        //保存目录
        let path = LocalObjectUtil.mFolder + "/" + name
        try? FileManager.default.removeItem(atPath: path)
    }
}
