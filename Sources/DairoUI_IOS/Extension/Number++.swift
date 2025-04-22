//
//  NumberExtension.swift
//  GlMusicIOS
//
//  Created by zhoulq on 2023/06/02.
//

import Foundation
extension SignedInteger{
    
    /**
     * 将整形数据转成文件大小格式的字符串
     */
    public var fileSize: String{
        let this = Double(self)
        var result = ""
        if self >= 1024 * 1024 * 1024{
            return String(format:"%.0.01f",this / 1024 / 1024 / 1024) + "GB"
        }
        if self >= 1024 * 1024{
            return String(format:"%.0.01f",this / 1024 / 1024) + "MB"
        }
        if self >= 1024{
            return String(format:"%.0.01f",this / 1024) + "KB"
        }
        return String(this) + "B"
    }
    
    /**
     * 转换成时间格式
     */
    public var timeFormat: String{
        
        //得到秒
        let senconds = Int(self / 1000)
        
        //小时
        let h = String(format:"%02d", senconds / (60 * 60))
        
        //分
        let m = String(format:"%02d", senconds % (60 * 60) / 60)
        
        //秒
        let s = String(format:"%02d", senconds % 60)
        if senconds >= 60 * 60{
            return "\(h):\(m):\(s)"
        }
        if senconds >= 60{
            return "\(m):\(s)"
        }
        return "00:" + s
    }
}

extension Float64{
    
    /**
     * 转换成时间格式
     */
    public var timeFormat: String{
        return Int64(self).timeFormat
    }
}
