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

@Test func DateUtil_format1() async throws {
    print("-->格式化时间:\(DateUtil.format(Date()))")
}

@Test func DateUtil_format2() async throws {
    print("-->格式化时间:\(DateUtil.format(123456576575))")
}
