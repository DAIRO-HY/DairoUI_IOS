//
//  RootViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/23.
//

import Foundation
import SwiftUI

public class RootViewModel : ObservableObject{
    
    ///显示等待框
    @Published var toastFlag = false
    
    ///显示等待框
    @Published var showWaiting = false
    
#if DEBUG
    public init(){
//        debugPrint("-->RootViewModel.init.\(tag)")
    }
    
    
    deinit{
//        debugPrint("-->RootViewModel.deinit.\(tag)")
    }
#endif
}
