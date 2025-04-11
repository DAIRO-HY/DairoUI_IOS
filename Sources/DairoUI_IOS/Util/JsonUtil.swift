import Foundation
class JsonUtil{
    
    /**
     * 对象转JsonData
     */
    static func objToJsonData(_ obj: Codable)throws -> Data{
        
        // オブジェクトからJsonに変換
        let encoder = JSONEncoder()
        return try encoder.encode(obj)
    }
    
    
    static func jsonDataToObj<T>(_ jsonData:Data,_ type: T.Type)throws -> T? where T: Decodable{
        return try JSONDecoder().decode(type.self, from: jsonData) as T
    }
}
