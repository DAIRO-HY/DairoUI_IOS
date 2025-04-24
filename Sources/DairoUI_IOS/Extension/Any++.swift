//
//  Any++.swift
//  GlMusicIOS
//
//  Created by 周龙权 on 2021/9/11.
//

import ObjectiveC
import SwiftUI

/**
 比较两个变量值是否一样
 - parameter v1:参数1
 - parameter v2:参数2
 */
func equal(_ v1: Any?, _ v2: Any?, nullValue: Bool = true) -> Bool{
    if v1 == nil && v2 == nil { return nullValue}
    if v1 == nil || v2 == nil { return false}//其中一个为nil

    if type(of: v1!) != type(of: v2!) { return false }//两个变量类型不一致
    if let vv1 = v1 as? Int, let vv2 = v2 as? Int { return vv1 == vv2 }
    if let vv1 = v1 as? Int8, let vv2 = v2 as? Int8 { return vv1 == vv2 }
    if let vv1 = v1 as? Int16, let vv2 = v2 as? Int16 { return vv1 == vv2 }
    if let vv1 = v1 as? Int32, let vv2 = v2 as? Int32 { return vv1 == vv2 }
    if let vv1 = v1 as? Int64, let vv2 = v2 as? Int64 { return vv1 == vv2 }
    if let vv1 = v1 as? UInt, let vv2 = v2 as? UInt { return vv1 == vv2 }
    if let vv1 = v1 as? UInt8, let vv2 = v2 as? UInt8 { return vv1 == vv2 }
    if let vv1 = v1 as? UInt16, let vv2 = v2 as? UInt16 { return vv1 == vv2 }
    if let vv1 = v1 as? UInt32, let vv2 = v2 as? UInt32 { return vv1 == vv2 }
    if let vv1 = v1 as? UInt64, let vv2 = v2 as? UInt64 { return vv1 == vv2 }
    if let vv1 = v1 as? Float, let vv2 = v2 as? Float { return vv1 == vv2 }
    #if os(iOS)
    if let vv1 = v1 as? Float16, let vv2 = v2 as? Float16 { return vv1 == vv2 }
    #endif
    if let vv1 = v1 as? Float32, let vv2 = v2 as? Float32 { return vv1 == vv2 }
    if let vv1 = v1 as? Float64, let vv2 = v2 as? Float64 { return vv1 == vv2 }
    if let vv1 = v1 as? Double, let vv2 = v2 as? Double { return vv1 == vv2 }
    if let vv1 = v1 as? String, let vv2 = v2 as? String { return vv1 == vv2 }

    return false
}
