import Foundation
import UIKit
import CommonCrypto

extension UIImage {
    
    /**
     * 将图片最大一边压缩到目标大小
     */
    func resize(_ targetSize: CGFloat) -> UIImage? {
        let size = self.size
        
        //得到图片最大的一边尺寸
        let maxImageSize = max(size.width,size.height)
        if targetSize > maxImageSize{//图片最大边还没有目标尺寸大,不需要压缩
            return self
        }

        // 按比例计算缩放比例
        let scaleFactor = targetSize  / maxImageSize

        // 计算缩放后的大小
        let scaledWidth  = size.width * scaleFactor
        let scaledHeight = size.height * scaleFactor

        // 创建一个图形上下文进行绘制
        UIGraphicsBeginImageContext(CGSize(width: scaledWidth, height: scaledHeight))

        // 绘制图片
        self.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))

        // 从图形上下文中获取缩放后的图片
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

        // 关闭图形上下文
        UIGraphicsEndImageContext()

        return scaledImage
    }
}
