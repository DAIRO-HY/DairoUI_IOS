import Testing
import Foundation
@testable import DairoUI_IOS

@Test private func readAll() async throws {
    let data = FileUtil.readAll("/Users/zhoulq/Documents/java/HelloWorld.java")
    print(data?.count)
}
