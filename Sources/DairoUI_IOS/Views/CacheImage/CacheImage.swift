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
    public static var mCacheFolder: String {
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
    
    private var width: CGFloat = 200
    private var height: CGFloat = 200
    private var alignment: Alignment = .center
    private var radius: CGFloat = 0
    
    //填充模式
    private var contentMode = ContentMode.fill
    
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
                .aspectRatio(contentMode: self.contentMode)
                .frame(width: self.width, height: self.height, alignment: self.alignment)
                .clipped()// 裁剪掉超出部分
                .cornerRadius(self.radius)
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
            .frame(width: self.width, height: self.height)
        }
    }
    
    /**
     设置尺寸
     */
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> CacheImage{
        var view = self
        if let width{
            view.width = width
        }
        if let height{
            view.height = height
        }
        view.alignment = alignment
        return view
    }
    
    //设置填充模式
    public func aspectRatio(_ contentMode: ContentMode) -> CacheImage{
        var view = self
        view.contentMode = contentMode
        return view
    }
    
    /**
     设置圆角
     */
    public func cornerRadius(_ radius: CGFloat) -> CacheImage{
        var view = self
        view.radius = radius
        return view
    }
}
#endif
