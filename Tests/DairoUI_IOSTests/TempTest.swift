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
//    let jsonData = Person(name: "sfsfs", age: 12, city: "贵阳市").toJSON().data(using: .utf8)!
//    print(String(data: jsonData, encoding: .utf8)!)
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let jsonData = try! encoder.encode(Person(name: "sfsfs", age: 12, city: "贵阳市"))
    print(String(data: jsonData, encoding: .utf8)!)
}
