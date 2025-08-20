import Testing
import Foundation
@testable import DairoUI_IOS

@Test private func test() async throws {
    DownloadConfig.maxSavingCount = 10
    print(DownloadConfig.maxSavingCount)
}
