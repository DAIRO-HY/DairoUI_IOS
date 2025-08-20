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
    
    ///当前图片的url
    private let url: String
    
    ///刷新图标标识
    @State private var freshImage: UInt64 = 0
    
    ///当前下载进度
    @State private var progress = ""
    
    private var width: CGFloat?
    private var height: CGFloat?
    private var alignment: Alignment = .center
    private var radius: CGFloat = 0
    
    private var isResizable = false
    
    //填充模式
    private var contentMode = ContentMode.fill
    
    /// 文件缓存id
    private let downloadId: String
    
    public init(_ url: String, downloadId: String? = nil) {
        self.url = url
        if downloadId != nil{
            self.downloadId = downloadId!
        } else {
            self.downloadId = url.md5
        }
    }
    
    public var body: some View {
        if self.freshImage > 0{
            //用来下载完成之后更新视图,不做任何处理
        }
        if let path = DownloadManager.getDownloadedPath(self.downloadId){
            Image(uiImage: UIImage(contentsOfFile: path)!)
                .resizable()
                .aspectRatio(contentMode: self.contentMode)
                .frame(width: self.width, height: self.height, alignment: self.alignment)
                .clipped()// 裁剪掉超出部分
                .cornerRadius(self.radius)
        } else {
            
            // 加载中
            ZStack{
                Text(self.progress).onAppear{
                    DownloadManager.cache(self.downloadId, self.url)
                }
                //                ProgressView().onAppear{
                //                    DownloadManager.cache(self.downloadId, self.url)
                //                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(self.downloadId))){
                let userInfo = $0.userInfo!
                switch userInfo["key"] as! DownloadNotify{
                case .progress:/// 进度回调
                    // 进度参数是一个数组,数组内容分别是 总大小,已下载大小,下载速度
                    let progress = userInfo["value"] as! [Int64]
                    self.progress = String(Int(Float64(progress[1]) / Float64(progress[0]) * 100)) + "%"
                case .pause:
                    break
                case .finish:
                    guard let error = userInfo["value"] as? Error else{
                        
                        //图片缓存完成,刷新页面
                        self.freshImage += 1
                        return
                    }
                    if let error = error as? DownloaderError{
                        if case let .error(msg) = error {
                            self.progress = msg
                        }
                    } else {
                        self.progress = error.localizedDescription
                    }
                }
            }
            .onDisappear{//视图被注销时,取消下载
                DownloadManager.cancel(self.downloadId)
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

#Preview {
    CacheImage("http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic")
}
#endif
