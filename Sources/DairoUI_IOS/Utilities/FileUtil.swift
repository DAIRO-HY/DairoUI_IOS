//
// Created by user on 2023/07/28.
//

import Foundation
import CommonCrypto
public enum FileUtil{
    
    /**
     读取文件所有内容
     - Parameters:
     - path: 文件路径
     */
    public static func readData(_ path: String) -> Data?{
        
        // 打开文件
        guard let readFileHandle = FileHandle(forReadingAtPath: path) else{
            return nil
        }
        defer{
            try? readFileHandle.close()
        }
        
        // 读取全部数据
        return readFileHandle.readData(ofLength: Int.max)
    }
    
    /// 获取文件MD5
    public static func md5(_ path: String) -> String? {
        return md5(URL(fileURLWithPath: path))
    }
    
    /// 获取文件MD5
    public static func md5(_ url: URL) -> String? {
        guard let stream = InputStream(url: url) else { return nil }
        stream.open()
        defer { stream.close() }

        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)

        let bufferSize = 1024 * 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read > 0 {
                _ = CC_MD5_Update(&context, buffer, CC_LONG(read))
            } else {
                break
            }
        }

        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Final(&digest, &context)

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    
    /**
     读取文件所有文本内容
     - Parameters:
     - path: 文件路径
     */
    public static func readText(_ path: String) -> String{
        guard let data = FileUtil.readData(path) else{
            return ""
        }
        guard let text = String(data: data, encoding: .utf8) else{
            return ""
        }
        return text
    }
    
    /**
     * 写入数据
     *  data 要写入的数据
     *  isAppend 是否追加数据
     */
    public static func writeText(_ path: String, _ content: String, _ isAppend: Bool = false){
        if let data = content.data(using: .utf8) {
            FileUtil.write(path, data, isAppend)
        }
    }
    
    /**
     写入数据
     - Parameters:
     - path 要写入的数据
     - data 是否追加数据
     */
    public static func write(_ path: String, _ data: Data, _ isAppend: Bool = false){
        
        //判断文件是否存在,不存在先创建一个文件
        //如果文件已经存在,再次创建文件时会把之前的文件内容清空,所以这里要先判断是否已经存在
        if !FileManager.default.fileExists(atPath: path){//文件不存在时
            let parentPath = FileUtil.parentPath(path)
            if !FileManager.default.fileExists(atPath: parentPath){//判断文件夹是否存在
                
                //创建文件夹
                FileUtil.createDirectory(parentPath)
            }
            
            //创建文件
            FileManager.default.createFile(atPath: path, contents: data)
            return
        }
        if !isAppend{//覆盖现有文件文件
            FileManager.default.createFile(atPath: path, contents: data)
            return
        }
        
        //初始化一个可以写文件时工具
        guard let writeFileHandle = FileHandle(forWritingAtPath: path) else{
            return
        }
        
        //追加写入文件
        writeFileHandle.write(data)
        try? writeFileHandle.close()
    }
    
    /**
     创建一个空文件
     - Parameters:
     - path 文件路径
     */
    public static func createEmptyFile(_ path: String){
        if !FileManager.default.fileExists(atPath: path) {//文件不存在
            let parentPath = FileUtil.parentPath(path)
            if !FileManager.default.fileExists(atPath: parentPath){//创建文件夹
                FileUtil.createDirectory(parentPath)
            }
            
            //创建文件
            FileManager.default.createFile(atPath: path, contents: nil)
        }
    }
    
    /**
     * 创建多级目录
     */
    public static func createDirectory(_ path: String) -> Bool{
        let url = URL(fileURLWithPath: path)
        
        // 如果文件夹不存在，则创建
        do{
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }
    
    /**
     * 获取文件名
     * paramter path 当前文件路径
     */
    public static func fileName(_ path: String) -> String{
        
        //查找最后一个斜杠所在位置
        guard let lastSepIndex = path.lastIndex(of: "/") else {
            return ""
        }
        let substringAfterLastSlash = path[path.index(after: lastSepIndex)...]
        return String(substringAfterLastSlash)
    }
    
    /**
     * 获取文件上级目录
     * paramter path 当前文件路径
     */
    public static func parentPath(_ path: String) -> String{
        
        //查找最后一个斜杠所在位置
        guard let lastSepIndex = path.lastIndex(of: "/") else {
            return ""
        }
        let substringAfterLastSlash = path[...path.index(before: lastSepIndex)]
        return String(substringAfterLastSlash)
    }
    
    /**
     * 获取文件后缀
     * paramter path 当前文件路径
     */
    public static func fileExtension(_ path: String) -> String{
        let filename = self.fileName(path)
        
        //查找最后一个点所在位置
        guard let lastDotIndex = filename.lastIndex(of: ".") else {
            return ""
        }
        let substringAfterLastSlash = filename[filename.index(before: lastDotIndex)...]
        return String(substringAfterLastSlash)
    }
    
    /**
     * 获取文件大小
     */
    public static func fileSize(_ path: String) -> Int64?{
        guard let attr = try? FileManager.default.attributesOfItem(atPath: path) else{
            return nil
        }
        guard let fileSize = attr[FileAttributeKey.size] as? Int64 else{
            return nil
        }
        return fileSize
    }
    
    /**
     * 文件重命名
     */
    public static func rename(source: String, target: String){
        let fileManager = FileManager.default
        
        // 原路径（当前文件路径）
        let sourceURL = URL(fileURLWithPath: source)
        
        // 新路径（新文件名）
        let targetURL = URL(fileURLWithPath: target)
        try? fileManager.moveItem(at: sourceURL, to: targetURL)
    }
    
}
