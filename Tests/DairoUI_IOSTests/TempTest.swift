import Testing
import Foundation
@testable import DairoUI_IOS

@Test private func test() async throws {
    let d = 2.05
    let sdf = UInt64(d * 100)
    print("-->end:\(sdf)")
}
