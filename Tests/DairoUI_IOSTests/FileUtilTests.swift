import Testing
import Foundation
@testable import DairoUI_IOS

@Test private func readAll() async throws {
    let data = FileUtil.readAll("/Users/zhoulq/Documents/java/HelloWorld.java")
    print(data?.count)
}

@Test private func FileUtilTest_getMD5() async throws {
    let md5 = FileUtil.getMD5("/Users/zhoulq/dev/java/idea/DairoDFS/data/ffmpeg/ffmpeg")
    print(md5)
}
