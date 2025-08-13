//
//  DownloadViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//

import Foundation
class DownloadViewModel : ObservableObject{
    
    /// 文件id列表
    @Published var ids: [String]
    init(){
        self.ids = DownloadDBUtil.selectIdBySaveType(1)
    }
}
