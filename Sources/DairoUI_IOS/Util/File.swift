//
// Created by user on 2024/03/05.
// 文件操作
//

import Foundation
public class File{
    
    /**
     * 文件路径
     */
    private let path:String
    init(_ path: String){
        self.path = path
    }
    
    /**
     * 从为文件中获取所有数据
     */
    var data: Data?{
        if !FileManager.default.fileExists(atPath: self.path) {//文件不存在
            return nil
        }
        
        // 打开文件
        let readFileHandle = FileHandle(forReadingAtPath: self.path)!
        //            defer{//作用域结束执行
        //                readFileHandle.close()
        //            }
        
        // 读取全部数据
        let data = readFileHandle.readData(ofLength: Int.max)
        
        try? readFileHandle.close()
        return data
    }
    
    /**
     * 读取文本
     */
    var text: String?{
        guard let data = self.data else{
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    
    
    /**
     * 写入数据
     *  data 要写入的数据
     *  isAppend 是否追加数据
     */
    func writeText(_ str: String, _ isAppend: Bool = false){
        if let data = str.data(using: .utf8) {
            self.write(data, isAppend)
        }
    }
    
    /**
     * 写入数据
     *  data 要写入的数据
     *  isAppend 是否追加数据
     */
    func write(_ data: Data, _ isAppend: Bool = false){
        
        //判断文件是否存在,不存在先创建一个文件
        //如果文件已经存在,再次创建文件时会把之前的文件内容清空,所以这里要先判断是否已经存在
        if !FileManager.default.fileExists(atPath: path){//文件不存在时
            let parentPath = FileUtil.getParentPath(path)
            if !FileManager.default.fileExists(atPath: parentPath){//判断文件夹是否存在
                
                //创建文件夹
                FileUtil.mkdirs(parentPath)
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
        guard let writeFileHandle = FileHandle(forWritingAtPath: self.path) else{
            return
        }
        
        //追加写入文件
        writeFileHandle.write(data)
        try? writeFileHandle.close()
    }
    
    /**
     * 删除文件
     */
    func delete(){
        try? FileManager.default.removeItem(atPath: path)
    }
}
