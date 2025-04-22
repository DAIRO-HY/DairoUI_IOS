//
//  CacheImage.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/22.
//

import Foundation
import SwiftUI

/**
 * 缓存图片加载视图
 */
public struct CacheImage: View{
    
    ///图片缓存文件夹
    public static var cacheFolder: String? = nil
    
    /**
     * 获取歌曲存储目录
     */
    private static var mCacheFolder: String {
        if CacheImage.cacheFolder == nil{
            
            //设置缓存目录
            CacheImage.cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("img_cache").path
        }
        return CacheImage.cacheFolder!
    }
    
    ///用来标记该控件的唯一性
    private let uid = String(Int64(Date().timeIntervalSince1970 * 1_000_000)) + "-" + String(Int.random(in: 1...100))
    
    ///当前图片的url
    private let url: String
    
    ///刷新图标标识
    @State private var freshImage: UInt64 = 0
    
    ///当前下载进度
    @State private var progress = ""
    
    public init(url: String, imagePath: String? = nil, progress: String = "") {
        self.url = url
    }
    
    public var body: some View {
        if self.freshImage > 0{
            //用来下载完成之后更新视图,不做任何处理
        }
        if let imagePath = DownloadBridge.getDownloadedPath(url: self.url, folder: CacheImage.mCacheFolder){
            Image(uiImage: UIImage(contentsOfFile: imagePath)!)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .frame(width: 200, height: 300)
        } else {
            // 加载中
            ZStack{
                Text(self.progress)
                ProgressView().onAppear{
                    debugPrint(self.uid)
                    self.download()
                }
            }
            .onDisappear{
                DownloadBridge.pause(self.uid)
            }
            .frame(width: 200, height: 200)
        }
    }
    
    ///下载图片
    private func download(){
        let bridge = DownloadBridge.add(uid: self.uid, url: url, folder: CacheImage.mCacheFolder, progressFunc:{
            print("当前下载进度:\($1.fileSize)/\($0.fileSize)  \($2.fileSize)")
            let progressValue = String(Int(Float64($1)/Float64($0) * 100)) + "%"
            DispatchQueue.main.async {
                self.progress = progressValue
            }
        }){ err in
            if err != nil{
                debugPrint("下载出错:\(err)")
            } else {
                debugPrint("下载完成:\(Thread.isMainThread)")
                DispatchQueue.main.async {
                    self.freshImage += 1
                }
            }
        }
    }
}
