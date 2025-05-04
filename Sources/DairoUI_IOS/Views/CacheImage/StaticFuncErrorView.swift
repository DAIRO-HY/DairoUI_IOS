//
//  SwiftUIView.swift
//  DairoUI-IOS-DEMO
//
//  Created by zhoulq on 2025/04/30.
//

import SwiftUI

public struct StaticFuncErrorView: View {
    public init(){
        
    }
    public var body: some View {
        Button(action:{
//            StaticFuncErrorView.add("123"){
//                print("call success:\(Date())")
//            }
            StaticUtil.add("123"){
                print("call success:\(Date())")
            }
        }){
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
    
    /**
     * 添加测试
     */
    public static func add(_ uid: String, finishFunc: @escaping () -> Void){
        StaticUtil.funcMap[uid] = FuncEntity(finishFunc: finishFunc)
        let item = StaticUtil.funcMap[uid]
        item?.finishFunc()
        Task{
            item?.finishFunc()
        }
    }
}

public struct FuncEntity{
    let finishFunc: () -> Void
}

public class StaticUtil {
    
    /**
     *
     */
    nonisolated(unsafe) static var funcMap = [String: FuncEntity]()
    
    /**
     * 添加测试
     * 这里有一个很奇怪的问题,如果不加@MainActor,在第二次执行item?.finishFunc()会报错
     * 如果这个add函数在第30行的View中,即使没有@MainActor,也不会报错,而且这个错误只会发生在Package中
     * 原因(来自ChatGPT的回答):
     * 这一段调用的是 StaticFuncErrorView.add 静态方法。由于这个方法是定义在 StaticFuncErrorView 结构体中的，不会有跨 concurrency domain 的问题。它虽然在 View 中定义，但本质上和普通 static func 没区别，因此不会涉及到 actor 隔离。
     */
    @MainActor
    public static func add(_ uid: String, finishFunc: @escaping () -> Void){
        StaticUtil.funcMap[uid] = FuncEntity(finishFunc: finishFunc)
        let item = StaticUtil.funcMap[uid]
        item?.finishFunc()
        Task{
            item?.finishFunc()
        }
    }
}

#Preview {
    StaticFuncErrorView()
}
