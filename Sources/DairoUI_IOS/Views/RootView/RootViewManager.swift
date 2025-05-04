//
//  RootViewManager.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/23.
//

import Foundation
import SwiftUI

public struct RootViewManager{
    
    ///管理root视图模型
    nonisolated(unsafe) private static var stacks = [RootViewModel]()
    
    ///当前最顶层栈
    nonisolated(unsafe) public static var top = RootViewModel()
    
    private static let lock = NSLock()
    
    /**
     添加栈
     */
    static func add(_ vm: RootViewModel){
        RootViewManager.lock.lock()
        RootViewManager.stacks.append(vm)
        RootViewManager.update()
        RootViewManager.lock.unlock()
#if DEBUG
        debugPrint("-->RootViewManager.rootStack.add.count:\(RootViewManager.stacks.count)")
#endif
    }
    
    /**
     移除栈
     */
    static func remove(_ vm: RootViewModel){
        RootViewManager.lock.lock()
        for i in 0 ..< RootViewManager.stacks.count{
            if vm === RootViewManager.stacks[i]{
                RootViewManager.stacks.remove(at: i)
                break
            }
        }
        RootViewManager.update()
        RootViewManager.lock.unlock()
#if DEBUG
        debugPrint("-->RootViewManager.rootStack.remove.count:\(RootViewManager.stacks.count)")
#endif
    }
    
    /**
     更新当前显示的vm
     */
    private static func update(){
        RootViewManager.top = RootViewManager.stacks.last!
    }
}
