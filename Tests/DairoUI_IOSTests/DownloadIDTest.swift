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

@Test func DownloadID_ID1() async throws {
    let id = DownloadID.ID("http://www.xxx.com/path1/path1?aa=00", .path)
    print("-->\(id)")
}

@Test func DownloadID_ID2() async throws {
    let id = DownloadID.ID("http://www.xxx.com", .path)
    print("-->\(id)")
}

@Test func DownloadID_ID3() async throws {
    let id = DownloadID.ID("http://www.xxx.com/path1/path2?a=12323", .pathAndQuery)
    print("-->\(id)")
}

@Test func DownloadID_ID4() async throws {
    let id = DownloadID.ID("http://www.xxx.com/path1/path2", .url)
    print("-->\(id)")
}
