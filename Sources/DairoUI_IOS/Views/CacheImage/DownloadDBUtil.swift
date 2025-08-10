//
//  DownloadDBUtil.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/05.
//

import SQLite3
import Foundation

public enum DownloadDBUtilError: Error {
    case dbError(_ msg: String)
}

enum DownloadDBUtil{
    
    //数据操作锁,防止并发操作
    private static let lock = NSLock()
    
    ///数据库文件名
    //    private static let DB_FILE = "download.sqlite"
    private static let DB_FILE = "/Users/zhoulq/dev/java/idea/DairoDFS/data/download.sqlite"
    
    ///数据库操作静态实例
    nonisolated(unsafe) private static var mDB: OpaquePointer?
    
//    ///已经下载的文件ID对应的文件路径
//    nonisolated(unsafe) private static var id2path = DownloadDBUtil.selectDownloadedId2Path()
    
    
    static var db: OpaquePointer{
        if self.mDB != nil{
            return self.mDB!
        }
        sqlite3_open(self.DB_FILE, &mDB)
        //            let abs = DB_FILE.absPath
        //            print(abs)
        //            print(FileManager.default.fileExists(atPath: abs))
        self.initDb()
        return self.mDB!
    }
    
    /// 初始化数据库
    private static func initDb(){
        self.exec(self.CREATE_SQL)
    }
    
    private static func exec(_ sql: String){
        if sqlite3_exec(self.db, sql, nil, nil, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(self.db))
            print("SQL 执行出错: \(errmsg)")
        }
    }
    
    /// 添加一条缓存下载数据
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter path: 文件存储路径
    /// - Throws 错误消息
    static func addCache(_ id: String, _ url: String) throws{
        let now = Int32(Date().timeIntervalSince1970)
        let insertSQL = "INSERT INTO download(id, url, saveType, date, useDate) VALUES ('\(id)', ?, 0, \(now), \(now));"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (url as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        self.lock.unlock()
        if let err{
            throw DownloadDBUtilError.dbError(err)
        }
    }
    
    /// 添加一条永久保存数据
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter path: 文件存储路径
    /// - Throws 错误消息
    static func addSave(_ list: [(id: String, url: String)]) throws{
        let now = Int32(Date().timeIntervalSince1970)
        let insertSQL = "INSERT INTO download(id, url, saveType, date, useDate) VALUES (?, ?, 1, \(now), \(now));"
        var statement: OpaquePointer?
        var err: String?
        self.lock.lock()
        
        // 开启事务
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        
        //主键重复的id列表
        var existsIds = [String]()
        if sqlite3_prepare_v2(self.db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            for it in list{
                sqlite3_bind_text(statement, 1, (it.id as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (it.url as NSString).utf8String, -1, nil)
                if sqlite3_step(statement) == SQLITE_DONE {
                    err = nil
                } else {
                    err = String(cString: sqlite3_errmsg(self.db))
                    if err == "UNIQUE constraint failed: download.id"{//主键重复,先累计,后续单独处理
                        err = nil
                        existsIds.append(it.id)
                    } else {
                        
                    }
                }
                sqlite3_reset(statement) // 重置以便下一次绑定
                sqlite3_clear_bindings(statement) // 清除绑定数据
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        
        if err == nil && !existsIds.isEmpty{//将缓存文件修改文永久存储
            let updateSQL = "UPDATE download set saveType = 1 where id = ? and saveType = 0;"
            if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
                for id in existsIds{
                    sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)
                    if sqlite3_step(statement) == SQLITE_DONE {
                        err = nil
                    } else {
                        err = String(cString: sqlite3_errmsg(self.db))
                    }
                    sqlite3_reset(statement) // 重置以便下一次绑定
                    sqlite3_clear_bindings(statement) // 清除绑定数据
                }
                sqlite3_finalize(statement)
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
        }
        
        // 提交事务
        if err == nil{
            sqlite3_exec(db, "COMMIT", nil, nil, nil)
        } else {
            sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
        }
        self.lock.unlock()
        if let err{
            throw DownloadDBUtilError.dbError(err)
        }
    }
    
//    /// 通过文件id获取文件路径
//    /// - Parameter id: 文件id
//    /// - Returns 文件路径
//    static func selectPathById(_ id: String) -> String?{
//        
//        //@TODO:这里需要加入二级缓存,加快读取速度
//        var path: String? = nil
//        let querySQL = "SELECT path FROM download WHERE id = ?;"
//        var statement: OpaquePointer?
//        self.lock.lock()
//        
//        // 准备 SQL 语句
//        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)
//            
//            // 遍历查询结果
//            if sqlite3_step(statement) == SQLITE_ROW {
//                path = String(cString: sqlite3_column_text(statement, 0))
//            }
//            
//            // 释放语句
//            sqlite3_finalize(statement)
//        } else {
//            fatalError(String(cString: sqlite3_errmsg(self.db)))
//        }
//        self.lock.unlock()
//        return path
//    }
    
//    /// 通过文件id从缓存文件下载字典中获取文件路径
//    /// - Parameter id: 文件id
//    /// - Returns 文件路径
//    static func selectPathByCache(_ id: String) -> String?{
//        self.lock.lock()
//        let path = self.id2path[id]
//        self.lock.unlock()
//        return path
//    }
//
//    /// 获取已经下载的文件
//    /// - Returns 文件id对应的文件路径
//    private static func selectDownloadedId2Path() -> [String:String]{
//        var id2path = [String:String]()
//        let querySQL = "SELECT id,path FROM download WHERE state = 10;"
//        var statement: OpaquePointer?
//        
//        // 准备 SQL 语句
//        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
//            
//            // 遍历查询结果
//            while sqlite3_step(statement) == SQLITE_ROW {
//                let id = String(cString: sqlite3_column_text(statement, 0))
//                let path = String(cString: sqlite3_column_text(statement, 1))
//                id2path[id] = path
//            }
//            
//            // 释放语句
//            sqlite3_finalize(statement)
//        } else {
//            fatalError(String(cString: sqlite3_errmsg(self.db)))
//        }
//        return id2path
//    }
    
    /// 获取一条需要下载的数据
    /// - Returns 需要下载的文件id和文件路径
    static func selectOneForNeedDownload() -> (id: String, url: String)?{
        let querySQL = "SELECT id,url FROM download WHERE state = 0 and saveType = 1 ORDER BY date LIMIT 1;"
        var statement: OpaquePointer?
        var result: (id: String, url: String)? = nil
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let url = String(cString: sqlite3_column_text(statement, 1))
                result = (id:id, url:url)
            }
            
            // 释放语句
            sqlite3_finalize(statement)
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        self.lock.unlock()
        return result
    }
    
    /// 更新文件最后使用日期
    ///
    /// - Parameter id: 文件唯一id
    static func updateUseDate(_ id: String){
        let updateSQL = "UPDATE download set useDate = ? where id = ?;"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(Date().timeIntervalSince1970))
            sqlite3_bind_text(statement, 2, (id as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        self.lock.unlock()
        if let err{
            fatalError(err)
        }
    }
    
    /// 更新文件下载状态
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter state: 状态
    /// - Parameter error: 下载失败时的错误消息
    static func updateState(_ id: String, _ state: Int, _ error: String? = nil){
        let updateSQL = "UPDATE download set state = \(state), error = ? where id = '\(id)';"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            if let error{
                sqlite3_bind_text(statement, 1, (error as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(statement, 1)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        self.lock.unlock()
        if let err{
            fatalError(err)
        }
//        if state == 10{//如果当前下载状态为完成,则将该路径添加到缓存
//            let path = self.selectPathById(id)
//            self.lock.lock()
//            self.id2path[id] = path
//            self.lock.unlock()
//        }
    }
    
    /// 删除一个文件
    ///
    /// - Parameter id: 文件唯一id
    static func delete(_ id: String){
        
        //删除之前先获取文件路径,以便后续删除文件
        let path = Downloader.getPath(id)
        if FileManager.default.fileExists(atPath: path){//删除文件
            try? FileManager.default.removeItem(atPath: path)
        }
        
        let deleteSQL = "DELETE FROM download where id = ?;"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = "Prepare failed."
        }
        self.lock.unlock()
        if let err{
            fatalError(err)
        }
        self.lock.lock()
        
        //从已经下载缓存列表移除
//        self.id2path.removeValue(forKey: id)
        self.lock.unlock()
    }
    
//    /// 删除一个文件
//    ///
//    /// - Parameter id: 文件唯一id
//    static func exec(_ sql: String, _ params: Any...){
//        var statement: OpaquePointer?
//        let err: String?
//        self.lock.lock()
//        if sqlite3_prepare_v2(self.db, sql, -1, &statement, nil) == SQLITE_OK {
//            for i in params.indices{
//                let value = params[i]
//                if value is String{//如果参数是字符串类型
//                    sqlite3_bind_text(statement, 1, (value as! NSString).utf8String, -1, nil)
//                } else if value is Int{//如果参数是Int类型
//                    sqlite3_bind_int64(statement, 1, Int64(value as! Int))
//                } else if value is Int32{//如果参数是Int32类型
//                    sqlite3_bind_int(statement, 1, value as! Int32)
//                } else if value is Int64{//如果参数是Int64类型
//                    sqlite3_bind_int64(statement, 1, value as! Int64)
//                } else if value is Float64{//如果参数是Float64类型
//                    sqlite3_bind_double(statement, 1, value as! Float64)
//                } else if value is Float32{//如果参数是Float64类型
//                    sqlite3_bind_double(statement, 1, Float64(value as! Float32))
//                }
//            }
//            if sqlite3_step(statement) == SQLITE_DONE {
//                err = nil
//            } else {
//                err = String(cString: sqlite3_errmsg(self.db))
//            }
//            sqlite3_finalize(statement)
//        } else {
//            err = "Prepare failed."
//        }
//        self.lock.unlock()
//        if let err{
//            fatalError(err)
//        }
//    }
    
    
    ///建表语句
    private static let CREATE_SQL =
        """
        -- 文件下载表
        CREATE TABLE download
        (
            id       VARCHAR(32) PRIMARY KEY NOT NULL,
            url      VARCHAR(1024)           NOT NULL,              -- 下载URL
            state    INTEGER                 NOT NULL DEFAULT 0,-- 文件状态 0:等待下载 1:下载中 2:暂停中 3:下载失败  10:下载完成
            saveType INTEGER                 NOT NULL,          -- 文件保存方式 0:临时缓存 1:永久保存
            date     INTEGER                 NOT NULL,          -- 文件创建时间戳
            useDate  INTEGER                 NOT NULL,          -- 文件最后使用时间戳
            error    TEXT                    NULL               -- 文件下载失败的错误消息
        );
        CREATE INDEX index_state ON download (state);
        CREATE INDEX index_saveType ON download (saveType);
        CREATE INDEX index_useDate ON download (useDate);
        """
}
