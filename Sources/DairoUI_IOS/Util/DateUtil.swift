//
//  DateUtil.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/13.
//

import Foundation

public enum DateUtil{
    
    /// 日期格式化
    ///
    /// - Parameter timespan:时间戳(秒)
    /// - Parameter layout:格式
    /// - Returns 格式化之后的日期
    public static func format(_ timespan: any SignedInteger, layout: String = "yyyy-MM-dd HH:mm:ss") -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(timespan))
        return self.format(date, layout:layout)
    }
    
    /// 日期格式化
    ///
    /// - Parameter date:日期
    /// - Parameter layout:格式
    /// - Returns 格式化之后的日期
    public static func format(_ date: Date, layout: String = "yyyy-MM-dd HH:mm:ss") -> String{
        let fmt = DateFormatter()
        fmt.dateFormat = layout
//        fmt.timeZone = TimeZone.current
        return fmt.string(from: date)
    }
}
