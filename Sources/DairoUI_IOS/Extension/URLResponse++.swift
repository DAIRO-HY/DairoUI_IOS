import Foundation

extension URLResponse {
    
    /**
     * 把头部信息的key转换成小写之后生产新的Headers
     */
    var header:[String: String]{
            let httpResponse = self as! HTTPURLResponse
            var headers = [String: String]()
            for key in httpResponse.allHeaderFields.keys {
                let lowercased = (key as! String).lowercased()
                headers[lowercased] = httpResponse.allHeaderFields[key] as? String
            }
            return headers
    }
}
