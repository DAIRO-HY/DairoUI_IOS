//
//  DownloadDBUtilTest.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/05.
//
import Testing
import SQLite3
@testable import DairoUI_IOS

@Test func DownloadDBUtil_insert() async throws {
}

@Test func DownloadDBUtil_addSave() async throws {
    var list = [(String,String)]()
    for i in 1 ... 10{
        list.append(("1-\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic"))
    }
    try! DownloadDBUtil.addSave(list)
}

@Test func DownloadDBUtil_addSa12ve() async throws {
    let ss = DownloadDBUtil.selectOneForNeedDownload()
    print("-->\(ss?.id)")
}
