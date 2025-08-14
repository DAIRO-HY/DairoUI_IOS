//
//  DownloadDBUtilTest.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/05.
//
import Testing
import SQLite3
@testable import DairoUI_IOS
import Foundation

@Test func Downloader_download1() async throws {
    Downloader("1122", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic"){_,err in
        print("-->下载失败:\(err)")
    }.download()
    await Task.sleep(999_000_000_000)
}

@Test func Downloader_download2() async throws {
    Downloader("1133", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100"){_,err in
        print("-->下载失败:\(err)")
    }.download()
    Downloader("1133", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100"){_,err in
        print("-->下载失败:\(err)")
    }.download()
    await Task.sleep(999_000_000_000)
}


@Test func Downloader_delete() async throws {
    Downloader("1144", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic"){_,_ in }.download()
    await Task.sleep(2_000_000_000)
    let path = DownloadManager.getDownloadedPath("1144")
    if path == nil{
        fatalError("测试异常")
    }
    DownloadDBUtil.delete(["1144"])
    if  DownloadManager.getDownloadedPath("1144") != nil{
        fatalError("缓存列表没有被删除,异常结束")
    }
    if FileManager.default.fileExists(atPath: path!){
        fatalError("测试异常,文件meiy0ou被删除")
    }
    print("-->正常结束")
}

@Test func Downloader_cancel1() async throws {
    var download:Downloader? = Downloader("1155", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753880938255678.mov?wait=100"){_,_ in }
    download?.download()
    await Task.sleep(1_000_000_000)
    download?.cancel()
    await Task.sleep(1_000_000_000)
    if Downloader.downloading.count != 0{
        fatalError("测试异常")
    }
    download = nil
    print("-->正常结束")
}

@Test func Downloader_cancel2() async throws {
    var download:Downloader? = Downloader("1166", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic"){_,_ in }
    download?.download()
    await Task.sleep(1_000_000_000)
    if Downloader.downloading.count != 0{
        fatalError("测试异常")
    }
    download = nil
    print("-->正常结束")
}
