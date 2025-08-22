import Testing
import Foundation
@testable import DairoUI_IOS

nonisolated(unsafe) private var list1 = [0,1,2,3,4,5,6,7,8,9]
@Test private func test() async throws {
    var list2 = getList()
    list1[0] = 100
    print("-->list1:\(list1)")
    print("-->list2:\(list2)")
}

private func getList() -> [Int]{
    return list1
}
