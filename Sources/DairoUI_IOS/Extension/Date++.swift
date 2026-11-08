//
//  NumberExtension.swift
//  GlMusicIOS
//
//  Created by zhoulq on 2023/06/02.
//

import Foundation

extension Date{
    
    /// 日期格式化
    ///
    /// - Parameter timespan:时间戳(秒)
    /// - Returns 格式化之后的日期 
    public func format(_ layout: String = "yyyy-MM-dd HH:mm:ss") -> String{
        return DateUtil.format(self, layout: layout)
    }
}
