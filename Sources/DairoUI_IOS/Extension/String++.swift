import Foundation
import CryptoKit
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_SHA256
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG


extension String {
    
    /**
     * 转换成整型
     */
    var int: Int?{
        return Int(self)
    }
    
    /**
     * 转换成整型
     */
    var int64: Int64?{
        return Int64(self)
    }
    
    /**
     * 转换成整型
     */
    var int32: Int32?{
        return Int32(self)
    }
    
    /**
     * 转换成整型
     */
    var int16: Int16?{
        return Int16(self)
    }
    
    /**
     * 转换成整型
     */
    var int8: Int8?{
        return Int8(self)
    }
    
    /**
     * 转换成Double型
     */
    var double: Double?{
        return Double(self)
    }
    
    /**
     * 转换成福地啊你¥型
     */
    var float: Float?{
        return Float(self)
    }
    
    /**
     * 获取字符串的SHA256
     */
    var sha256:String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
    
    /**
     * 获取字符串的MD5
     */
    var md5:String {
        let inputData = Data(self.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    /**
     * Url编码
     */
    var urlEncode:String?{
        // RFC3986 に準拠
        // 変換対象外とする文字列（英数字と-._~）
        let allowedCharacters = NSCharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        
        if let encodedText = self.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {
            return encodedText
        }
        return nil
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
     * 保存一个对象到配置文件
     */
    func toLocalObj(_ obj: Codable?) -> Bool {
        
        //保存目录
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(self + ".json").path
        let parentPath = FileUtil.getParentPath(path)
        if !FileManager.default.fileExists(atPath: parentPath){//判断文件夹是否存在
            
            //创建文件夹
            FileUtil.mkdirs(parentPath)
        }
        let file = File(path)
        guard let target = obj else {//移除序列化文件
            file.delete()
            return true
        }
        let jsonData = try! JsonUtil.objToJsonData(target)
        if file.data == jsonData {//避免重复写入，频繁写入会影响磁盘寿命，但读不会
            return false
        }
        file.write(jsonData)
        return true
    }
    
    /**
     * 从本地序列化文件读取到实列
     */
    func localObj<T>(_ type: T.Type) -> T? where T: Decodable {
        
        //保存目录
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(self + ".json").path
        if !FileManager.default.fileExists(atPath: path) {//文件不存在
            return nil
        }
        let file = File(path)
        guard let data = file.data else{
            return nil
        }
        return try? JSONDecoder().decode(type.self, from: data) as T
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
