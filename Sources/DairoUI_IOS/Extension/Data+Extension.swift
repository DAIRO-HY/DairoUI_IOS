import Foundation
import CryptoKit
import CommonCrypto

extension Data{
    
    /**
     * 将Data转String
     */
    var string: String?{
        return String(data: self, encoding: .utf8)
    }
    
    public var sha256: String{
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    /// 获取该Data的md5
    public var md5: String{
        let hashed = Insecure.MD5.hash(data: self)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}
