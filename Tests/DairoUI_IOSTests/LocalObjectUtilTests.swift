import Testing
import Foundation
@testable import DairoUI_IOS

private struct LocalObjectTestClass : Codable{
    public var test = 2
}

@Test private func writeTest() async throws {
    print("-->\(LocalObjectUtil.mFolder)")
    LocalObjectUtil.write(LocalObjectTestClass(), "test1")
}
