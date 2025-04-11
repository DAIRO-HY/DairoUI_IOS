//
// Created by user on 2023/07/28.
//

import Foundation
class FileLastUseUtil{

    private static let KEY_FILE_LAST_USE_DATE = "KEY_FILE_LAST_USE_DATE"


    /**
     * 检查是否需要保存,若文件已经保存,则更新最后播放时间
     */
    static func checkSaveAndUpdateFileLastUseTime(_ filename: String) -> Bool{
        return true
        var fileLastUseTime: [String : Int64]? = nil
        if let data = UserDefaults.standard.data(forKey: KEY_FILE_LAST_USE_DATE){
            fileLastUseTime = try? JsonUtil.jsonDataToObj(data, [String : Int64].self)
        }
        if fileLastUseTime == nil{
            fileLastUseTime = [String : Int64]()
        }

        //是否要保存
        var isSaveAllow = false
        if let lastUseTime = fileLastUseTime![filename]{//第一次使用
            let time = Int64(Date().timeIntervalSince1970) - lastUseTime
            if time < 2 * 24 * 60 * 60{//上次使用时间两天以内
                isSaveAllow = true
            }
        }

        //保存最后一次使用时间
        fileLastUseTime![filename] = Int64(Date().timeIntervalSince1970)
        let jsonData = try! JsonUtil.objToJsonData(fileLastUseTime!)
        UserDefaults.standard.set(jsonData, forKey: KEY_FILE_LAST_USE_DATE)
        return isSaveAllow
    }
}
