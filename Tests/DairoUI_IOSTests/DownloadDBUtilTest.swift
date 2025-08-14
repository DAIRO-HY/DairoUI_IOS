//
//  DownloadDBUtilTest.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/05.
//
import Testing
import SQLite3
@testable import DairoUI_IOS

@Test func DownloadDBUtil_addSave() async throws {
    var list = [(String,String)]()
    for i in 1 ... 1{
        list.append(("1-\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic"))
    }
    try! DownloadDBUtil.addSave(list)
}

@Test func DownloadDBUtil_addSa12ve() async throws {
    let ss = DownloadDBUtil.selectOneForNeedDownload()
    print("-->\(ss?.id)")
}

@Test func DownloadDBUtil_selectListBySaveType() async throws {
    let list = DownloadDBUtil.selectListBySaveType(1)
    print("-->\(list)")
//    for it in list{
//        print("-->\(ss?.id)")
//    }
}


@Test func DownloadDBUtil_getFileNameByUrl1() async throws {
    let name = DownloadDBUtil.getFileNameByUrl("http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic")
    print("-->\(name)")
}

@Test func DownloadDBUtil_getFileNameByUrl2() async throws {
    let name = DownloadDBUtil.getFileNameByUrl("http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?token=1242322")
    print("-->\(name)")
}

@Test func DownloadDBUtil_getFileNameByUrl3() async throws {
    let name = DownloadDBUtil.getFileNameByUrl("http://localhost:8031")
    print("-->\(name)")
}
