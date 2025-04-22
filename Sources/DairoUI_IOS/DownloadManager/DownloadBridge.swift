//
//  DownloadBridge.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//
import Foundation

struct DownloadWaiting{
    let url: String
    let folder: String
    let progressFunc: DownloadThread.DownloadThreadProgressFuncType?
    let finishFunc: (_ error:Error?) -> Void
}

public class DownloadBridge {
    
    /**
     * 最大下载上线
     */
    private static let maxDownloadingCount = 10
    
    /**
     * 当前uid对应排队下载信息
     */
    nonisolated(unsafe) private static var uid2Waiting = [String: DownloadWaiting]()
    
    /**
     * 当前url  =>  正在下载
     */
    nonisolated(unsafe) private static var url2downloading = [String: DownloadThread]()
    
    /**
     * 当前uid  =>  正在下载
     */
    nonisolated(unsafe) private static var uid2downloading = [String: DownloadWaiting]()
    
    /**
     * 当前正在下载的的md5对应的下载任务
     */
//    nonisolated(unsafe) private static var url2waiting = [String: DownloadThread]()
    
    /**
     * 单线程并发锁
     */
    private static let lock = NSLock()
    
    /**
     * 添加一个下载任务
     */
    public static func add(uid: String, url: String, folder: String, progressFunc: DownloadThread.DownloadThreadProgressFuncType? = nil, finishFunc: @escaping (_ error:Error?) -> Void){
        
        //文件下载路径
        let filePath = DownloadBridge.makeFilePath(url: url, folder: folder)
        
        //测试用
//        try? FileManager.default.removeItem(atPath: filepath)
        if let path = DownloadBridge.getDownloadedPath(url: url, folder: folder){
            finishFunc(nil)
            return
        }
        debugPrint("文件下载目录:\(filePath)")
        DownloadBridge.lock.lock()
        if DownloadBridge.uid2Waiting.contains(where:{$0.key == url}){ //如果url已经在排队
            DownloadBridge.lock.unlock()
            finishFunc(MultipleDownloadError())
            return
        }
        
        //添加
        DownloadBridge.uid2Waiting[uid] = DownloadWaiting(url: url, folder: folder, progressFunc: progressFunc, finishFunc: finishFunc)
        DownloadBridge.lock.unlock()
        
        // 开启下载队列
        DownloadBridge.download()
    }
    
    ///开始下载
    private static func download() {
        lock.lock()
        
        //准备下载的列表
        var prepareDownloads = [DownloadThread]()
        for item in DownloadBridge.uid2Waiting{
            if DownloadBridge.url2downloading.count >= DownloadBridge.maxDownloadingCount{//限制并发数
                break
            }
            if DownloadBridge.url2downloading.contains(where: {$0.key == item.value.url}){//该url正在下载中,跳过
                continue
            }
            
            //文件下载路径
            let path = DownloadBridge.makeFilePath(url: item.value.url, folder: item.value.folder)
            let info = DownloadingInfo(savePath: path, url: item.value.url, uid: item.key)
            let dt = DownloadThread(info, finishFunc: DownloadBridge.finish)
            dt.setProgressFunc(item.value.progressFunc)
            DownloadBridge.url2downloading[item.value.url] = dt
            DownloadBridge.uid2downloading[item.key] = item.value
            prepareDownloads.append(dt)
        }
        
        DownloadBridge.uid2downloading.forEach{//将正在下载的任务从uid排队列表中移除
            DownloadBridge.uid2Waiting.removeValue(forKey: $0.key)
        }
        
        debugPrint("-->剩余请求数:\(DownloadBridge.url2downloading.count)/\(DownloadBridge.uid2Waiting.count)")
        lock.unlock()
        
        //开始下载不能放在锁(lock)内执行,如果文件已经下载完成,下载任务会立即回到finish函数,从而导致死锁
        prepareDownloads.forEach{
            $0.download()
        }
    }
    
    /**
     * 文件下载完成回调函数
     */
    private static func finish(_ info: DownloadingInfo, _ err: Error?){
        DownloadBridge.lock.lock()
        
        let waitingInfo = DownloadBridge.uid2downloading[info.uid]!
        
        //下载线程结束之后从正在下载队列中移除
        DownloadBridge.url2downloading.removeValue(forKey: info.url)
        DownloadBridge.uid2downloading.removeValue(forKey: info.uid)
        DownloadBridge.lock.unlock()
        
        waitingInfo.finishFunc(err)
        
        // 开启下载队列
        DownloadBridge.download()
    }
    
    /**
     * 暂停下载
     */
    public static func pause(_ uid: String) {
        lock.lock()
        if DownloadBridge.uid2Waiting.contains(where: {$0.key == uid}){
            DownloadBridge.uid2Waiting.removeValue(forKey: uid)
        }
        if let waitingInfo = DownloadBridge.uid2downloading[uid]{
            DownloadBridge.url2downloading[waitingInfo.url]?.cancel()
            DownloadBridge.url2downloading.removeValue(forKey: waitingInfo.url)
        }
        lock.unlock()
        download()
    }
    
    /**
     * 获取已经下载了的文件
     */
    public static func getDownloadedPath(url: String, folder: String) -> String?{
        
        //拼接文件名
        let filepath = makeFilePath(url: url, folder: folder)
        if FileManager.default.fileExists(atPath: filepath){
            return filepath
        }
        return nil
    }
    
    /**
     * 生成文件路径
     */
    private static func makeFilePath(url: String, folder: String) -> String{
        
        //获取下载文件的MD5
        let md5 = url.md5
        
        //拼接文件名
        return folder + "/" + md5
    }
}

/**
 * 下载线程已经存在ERROR
 */
public struct MultipleDownloadError : Error{
}
