import Testing
import Foundation
@testable import DairoUI_IOS

@Test private func test() async throws {
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: "&=+")
    let paramValue = "你好&世界+测试="
    let encoded = paramValue.addingPercentEncoding(withAllowedCharacters: allowed)
    print(encoded ?? "编码失败")
}
