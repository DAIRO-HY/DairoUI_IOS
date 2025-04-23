//
//  RootViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/23.
//

import Foundation

public class RootViewModel : ObservableObject{
    
    ///显示等待框
    @Published public var toastFlag = false
    
    private var tag = Date().timeIntervalSince1970
    
    ///显示等待框
    @Published var showWaiting = false
    
    ///显示等待框
    @Published public var time = ""
    
#if DEBUG
    public init(){
        debugPrint("-->RootViewModel.init.\(tag)")
    }
    
    
    deinit{
        debugPrint("-->RootViewModel.deinit.\(tag)")
    }
#endif
}
