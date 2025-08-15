import Testing
import Foundation
@testable import DairoUI_IOS

@Test private func test() async throws {
    DownloadConst.maxSavingCount = 10
    print(DownloadConst.maxSavingCount)
}
