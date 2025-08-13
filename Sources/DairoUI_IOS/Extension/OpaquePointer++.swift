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
    ///
    /// - Parameter iCol: 列号,0开始
    func text(_ iCol: Int32) -> String?{
        if let cStr = sqlite3_column_text(self, iCol){
            return String(cString: cStr)
        } else {
            return nil
        }
    }
}
