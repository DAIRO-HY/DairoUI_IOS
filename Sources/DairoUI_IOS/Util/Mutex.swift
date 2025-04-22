//
//  Mutex.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/18.
//

actor Mutex {
    
    /**
     * 单线程执行
     */
    func sync(block: ()->Void) {
        block()
    }
}
