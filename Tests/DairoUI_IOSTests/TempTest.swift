import Testing
import Foundation
@testable import DairoUI_IOS

struct Person: LocalObjectUtilEncodable,Codable {
    var name: String
    var age: Int
    var city: String
    
    func toJSON() -> String {
        return #"{"id":edfsv,"name":"\#(name)","date":"\#(city)"}"#
    }
}

@Test private func test() async throws {
    print(["1","2"].joined(separator: ","))
}
