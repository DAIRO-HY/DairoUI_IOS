//
//  OpaquePointer++.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/13.
//

import SQLite3

// 数据库读取数据扩展
public extension OpaquePointer{
    
    /// 获取字符串数据
    /// - Parameter iCol: 列号,0开始
    /// - Returns 字符串数据
    func text(_ iCol: Int32) -> String{
        if let cStr = sqlite3_column_text(self, iCol){
            return String(cString: cStr)
        } else {
            return ""
        }
    }
    
    /// 获取可能为nil的字符串数据
    /// - Parameter iCol: 列号,0开始
    /// - Returns 字符串数据
    func textOrNil(_ iCol: Int32) -> String?{
        if let cStr = sqlite3_column_text(self, iCol){
            return String(cString: cStr)
        } else {
            return nil
        }
    }
    
    /// 获取Int64数据
    /// - Parameter iCol: 列号,0开始
    /// - Returns Int64数据
    func int64(_ iCol: Int32) -> Int64{
        return sqlite3_column_int64(self, iCol)
    }
    
    /// 获取Int32数据
    /// - Parameter iCol: 列号,0开始
    /// - Returns Int32数据
    func int32(_ iCol: Int32) -> Int32{
        return sqlite3_column_int(self, iCol)
    }
    
    /// 获取Int数据
    /// - Parameter iCol: 列号,0开始
    /// - Returns Int数据
    func int(_ iCol: Int32) -> Int{
        return Int(sqlite3_column_int(self, iCol))
    }
    
    /// 获取Int16数据
    /// - Parameter iCol: 列号,0开始
    /// - Returns Int16数据
    func int16(_ iCol: Int32) -> Int16{
        return Int16(sqlite3_column_int(self, iCol))
    }
    
    /// 获取Int8数据
    /// - Parameter iCol: 列号,0开始
    /// - Returns Int8数据
    func int8(_ iCol: Int32) -> Int8{
        return Int8(sqlite3_column_int(self, iCol))
    }
}
