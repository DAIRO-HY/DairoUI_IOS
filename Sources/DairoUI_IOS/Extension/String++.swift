import Foundation
import CryptoKit
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_SHA256
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG


public extension String {
    
    /**
     * 转换成整型
     */
    public var int: Int?{
        return Int(self)
    }
    
    /**
     * 转换成整型
     */
    public var int64: Int64?{
        return Int64(self)
    }
    
    /**
     * 转换成整型
     */
    public var int32: Int32?{
        return Int32(self)
    }
    
    /**
     * 转换成整型
     */
    public var int16: Int16?{
        return Int16(self)
    }
    
    /**
     * 转换成整型
     */
    public var int8: Int8?{
        return Int8(self)
    }
    
    /**
     * 转换成Double型
     */
    public var double: Double?{
        return Double(self)
    }
    
    /**
     * 转换成福地啊你¥型
     */
    public var float: Float?{
        return Float(self)
    }
    
    /**
     * 获取字符串的SHA256
     */
    public var sha256:String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
    
    /**
     * 获取字符串的MD5
     */
    var md5: String {
        let inputData = Data(self.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    /**
     * 去除空格（ ）、制表符（\t）、换行符（\n、\r）等字符。
     */
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /**
     * Url编码
     */
    var urlEncode: String{
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=+")
        let encoded = self.addingPercentEncoding(withAllowedCharacters: allowed)
        return encoded!
    }
    
    /**
     * 截取某个字符之前得字符串
     */
    func before(_ before: Character) -> String?{
        guard let firstIndex = self.firstIndex(of: before) else{
            return nil
        }
        return String(self[..<firstIndex])
    }
    
    /**
     * 截取某个字符以后得字符串
     */
    func after(_ after: Character) -> String?{
        guard let firstIndex = self.firstIndex(of: after) else{
            return nil
        }
        return String(self[self.index(firstIndex,offsetBy: 1)...])
    }
    
    /**
     * 获取绝对路径
     */
    public var absPath: String{
        if self.hasPrefix("/"){//如果这个路径是以/开头,说明已经是绝对路径,原样返回即可
            return self
        }
        return FileManager.default.currentDirectoryPath + "/" + self
        
//        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            let fileURL = documentsPath.appendingPathComponent(path)
//            return fileURL.path
//        }
//        return ""
    }
    
    //    /**
    //     * 将图片地址转成一张图片
    //     */
    //    func urlImage(callback: @escaping (_ image: UIImage) -> Void){
    //
    //        // 使用Kingfisher加载图片
    //        KingfisherManager.shared.retrieveImage(with: URL(string: self)!) { result in
    //            if case .success(let value) = result {
    //                // 加载成功时，获取UIImage并更新image属性
    //                DispatchQueue.main.async {
    //                    callback(value.image)
    //                }
    //            }
    //        }
    //    }
    //
    //    /**
    //     * 将图片地址转成一张图片
    //     */
    //    var urlImage: KFImage{
    //
    //        // 使用Kingfisher加载图片
    //        return KFImage(URL(string: self)!)
    //    }
}
