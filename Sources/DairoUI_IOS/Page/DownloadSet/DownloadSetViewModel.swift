//
//  DownloadViewModel.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/12.
//

import Foundation

public class DownloadSetViewModel : ObservableObject{
    
    /// 所有缓存大小
    @Published var usedSizeList = [(title: String, date: Int, size: Int64)]()
    
    //当前时间戳(秒)
    private let now = Int(Date().timeIntervalSince1970)
    
    /// 用来保存要删除的使用日期
    var deleteTargetDate = 0
    public init(){
        self.loadCacheSize()
    }
    
    /// 加载已经缓存大小
    func loadCacheSize(){
        self.usedSizeList = [
            ("所有缓存", self.now),
            ("1天未使用", self.now - 1 * 24 * 60 * 60),
            ("1星期未使用", self.now - 7 * 24 * 60 * 60),
            ("1个月未使用", self.now - 30 * 24 * 60 * 60),
            ("3个月未使用", self.now - 90 * 24 * 60 * 60),
            ("6个月未使用", self.now - 180 * 24 * 60 * 60),
            ("1年未使用", self.now - 365 * 24 * 60 * 60)
        ].map{
            
            //获取缓存大小
            let usedSize = DownloadDBUtil.selectSizeByUsedDate($0.1)
            return ($0.0, $0.1, usedSize)
        }
    }
    
    /// 删除按钮点击事件
    func onDeleteClick(){
        let ids = DownloadDBUtil.selectIdByUsedDate(self.deleteTargetDate)
        
        //删除这些文件
        DownloadManager.delete(ids)
        self.loadCacheSize()
    }
}
