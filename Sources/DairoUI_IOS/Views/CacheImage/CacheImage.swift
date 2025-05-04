//
//  CacheImage.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/22.
//
#if os(iOS)
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
    //    private let uid = String(Date().timeIntervalSince1970) + "-" + String(Int.random(in: 1...100))
    
    ///当前图片的url
    private let url: String
    
    ///刷新图标标识
    @State private var freshImage: UInt64 = 0
    
    ///当前下载进度
    @State private var progress = ""
    
    public init(_ url: String) {
        self.url = url
    }
    
    public var body: some View {
        if self.freshImage > 0{
            //用来下载完成之后更新视图,不做任何处理
        }
        if let imagePath = CacheImageHelper.getDownloadedPath(url: self.url, folder: CacheImage.mCacheFolder){
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
                    CacheImageHelper.add(url: self.url, folder: CacheImage.mCacheFolder)
                    //                    self.download()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.url))){
                //                debugPrint("url2count = \(DownloadBridge.url2count[self.url])   url2downloading = \(DownloadBridge.url2downloading.count)")
                let msg = $0.object as! String
                //                print(msg)
                if msg.starts(with: "p:"){//下载进度
                    let data = msg.split(separator: ":")
                    self.progress = String(Int(Float64(data[2])! / Float64(data[1])! * 100)) + "%"
                } else if msg.starts(with: "f:nil"){//下载完成
                    self.freshImage += 1
                } else if msg.starts(with: "f:"){//下载失败
                    self.progress = "加载失败"
                }
            }
            .onDisappear{//视图被注销时,取消下载
                CacheImageHelper.cancel(self.url)
            }
            .frame(width: 200, height: 200)
        }
    }
    
    ///下载图片
    private func download(){
        //        let bridge = DownloadBridge.add(uid: self.uid, url: url, folder: CacheImage.mCacheFolder, progressFunc:{
        //            print("当前下载进度:\($1.fileSize)/\($0.fileSize)  \($2.fileSize)")
        //            let progressValue = String(Int(Float64($1)/Float64($0) * 100)) + "%"
        //            DispatchQueue.main.async {
        //                self.progress = progressValue
        //            }
        //        }){ err in
        //            if err != nil{
        //                debugPrint("下载出错:\(err)")
        //            } else {
        //                debugPrint("下载完成:\(Thread.isMainThread)")
        //                DispatchQueue.main.async {
        //                    self.freshImage += 1
        //                }
        //            }
        //        }
    }
}
#endif
