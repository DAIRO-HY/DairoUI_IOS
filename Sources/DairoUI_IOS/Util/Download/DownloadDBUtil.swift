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

public enum DownloadDBUtil{
    
    //数据操作锁,防止并发操作
    private static let lock = NSLock()
    
    ///数据库文件名
    //    private static let DB_FILE = "download.sqlite"
    //    private static let DB_FILE = "/Users/zhoulq/dev/java/idea/DairoDFS/data/download.sqlite"
    //    private static let DB_FILE = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("download.sqlite").path
    
    ///数据库操作静态实例
    nonisolated(unsafe) private static var mDB: OpaquePointer?
    
    //    ///已经下载的文件ID对应的文件路径
    //    nonisolated(unsafe) private static var id2path = DownloadDBUtil.selectDownloadedId2Path()
    
    
    static var db: OpaquePointer{
        if self.mDB != nil{
            return self.mDB!
        }
        sqlite3_open(DownloadConfig.dbFile, &mDB)
        //                    let abs = DownloadConst.dbFile.absPath
        //                    print(abs)
        //                    print(FileManager.default.fileExists(atPath: abs))
        self.initDb()
        return self.mDB!
    }
    
    /// 初始化数据库
    private static func initDb(){
        self.exec(self.CREATE_SQL)
        self.updateStateToPauseByDownloading()
    }
    
    private static func exec(_ sql: String){
        if sqlite3_exec(self.db, sql, nil, nil, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(self.db))
            print("SQL 执行出错: \(errmsg)")
        }
    }
    
    /// 将正在下载中的任务标记为暂停状态
    /// 该操作仅仅在APP第一次打开时执行,内部无需锁操作
    private static func updateStateToPauseByDownloading(){
        let updateSQL = "UPDATE download set state = 2 where state = 1 and saveType = 1;"
        var statement: OpaquePointer?
        let err: String?
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                err = nil
            } else {
                err = String(cString: sqlite3_errmsg(self.db))
            }
            sqlite3_finalize(statement)
        } else {
            err = String(cString: sqlite3_errmsg(self.db))
        }
        if let err{
            fatalError(err)
        }
    }
    
    /// 添加一条缓存下载数据
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter path: 文件存储路径
    /// - Throws 错误消息
    static func addCache(_ id: String, _ url: String) throws{
        
        //获取文件名
        let name = self.getFileNameByUrl(url)
        
        //当前时间戳
        let now = Int(Date().timeIntervalSince1970)
        let insertSQL = "INSERT INTO download(id, url, name, saveType, date, useDate) VALUES ('\(id)', ?, ?, 0, \(now), \(now));"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (url as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
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
        
        //当前时间戳
        let now = Int(Date().timeIntervalSince1970)
        let insertSQL = "INSERT INTO download(id, url, name, saveType, date, useDate) VALUES (?, ?, ?, 1, \(now), \(now));"
        var statement: OpaquePointer?
        var err: String?
        self.lock.lock()
        
        // 开启事务
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        
        //主键重复的id列表
        var existsIds = [String]()
        if sqlite3_prepare_v2(self.db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            for it in list{
                
                //获取文件名
                let name = self.getFileNameByUrl(it.url)
                sqlite3_bind_text(statement, 1, (it.id as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (it.url as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, (name as NSString).utf8String, -1, nil)
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
            let ids = "'" + existsIds.joined(separator: "','") + "'"
            let updateSQL = """
                    UPDATE download set saveType = 1 where id in (\(ids)) and saveType = 0; -- 将缓存文件设置为永久保存文件
                    UPDATE download set state = 0 where id in (\(ids)) and state in (2,3); -- 将暂停或失败的文件设置为准备下载状态
                """
            
            //这里有个坑,如果同时执行多条sql语句,只能使用sqlite3_exec函数,sqlite3_prepare_v2函数只会执行第一条sql语句
            if sqlite3_exec(self.db, updateSQL, nil, nil, nil) != SQLITE_OK{
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
        //print(self.selectListBySaveType(1))
    }
    
    /// 从url中获取文件名
    static func getFileNameByUrl(_ url: String) -> String{
        var path = url[url.range(of: "://")!.upperBound...]
        if let slashIndex = path.firstIndex(of: "/"){
            path = path[slashIndex...]
            if let questionIndex = path.firstIndex(of: "?"){
                path = path[..<questionIndex]
            }
        } else {
            path = "/"
        }
        var lastSlashIndex = path.lastIndex(of: "/")!
        lastSlashIndex = path.index(lastSlashIndex,offsetBy: 1)
        let name = path[lastSlashIndex...]
        return String(name)
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
    /// - Parameter ids: 文件id列表
    static func updateUseDate(_ ids: [String]){
        let updateSQL = "UPDATE download set useDate = \(Int(Date().timeIntervalSince1970)) where id in ('\(ids.joined(separator: "','"))');"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
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
    static func setState(_ id: String, _ state: Int, _ error: String? = nil){
        let updateSQL = "UPDATE download set state = \(state), error = ? where id = '\(id)' and state <> \(state);"
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
    
    /// 暂停所有下载
    static func pauseAll(){
        let updateSQL = "UPDATE download set state = 2 where state in (0,1);"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
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
    
    /// 开始所有下载
    static func startAll(){
        let updateSQL = "UPDATE download set state = 0,error = null where state in (2,3);"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
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
    
    /// 设置文件大小
    ///
    /// - Parameter id: 文件唯一id
    /// - Parameter size: 文件大小
    public static func setSize(_ id: String, _ size: Int64){
        let updateSQL = "UPDATE download set size = \(size) where id = '\(id)' and size = 0;"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, updateSQL, -1, &statement, nil) == SQLITE_OK {
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
    
    /// 删除一个文件
    ///
    /// - Parameter id: 文件唯一id
    static func delete(_ ids: [String]){
        let deleteSQL = "DELETE FROM download where id in ('\(ids.joined(separator: "','"))');"
        var statement: OpaquePointer?
        let err: String?
        self.lock.lock()
        if sqlite3_prepare_v2(self.db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
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
    
    /// 查询一条数据
    /// - Parameter saveType: 文件保存方式
    /// - Returns 文件路径
    static func selectOne(_ id: String) -> DownloadDto?{
        let querySQL = "SELECT name,size,state,saveType,date,useDate,error FROM download WHERE id = '\(id)';"
        var statement: OpaquePointer?
        
        var dto: DownloadDto? = nil
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            if sqlite3_step(statement) == SQLITE_ROW {
                dto = DownloadDto(
                    id: id,
                    url: "",
                    name: statement!.text(0),
                    size: statement!.int64(1),
                    state: statement!.int8(2),
                    saveType: statement!.int8(3),
                    date: statement!.int(4),
                    useDate: statement!.int(5),
                    error: statement!.textOrNil(6)
                )
            }
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        
        // 释放语句
        sqlite3_finalize(statement)
        self.lock.unlock()
        return dto
    }
    
    /// 获取下载列表
    /// - Parameter saveType: 文件保存方式
    /// - Returns 文件路径
    static func selectListBySaveType(_ saveType: Int8) -> [DownloadDto]{
        let querySQL = "SELECT id,name,size,state,date,useDate,error FROM download WHERE saveType = \(saveType);"
        var statement: OpaquePointer?
        
        var list = [DownloadDto]()
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            while sqlite3_step(statement) == SQLITE_ROW {
                let dto = DownloadDto(
                    id: statement!.text(0),
                    url: "",
                    name: statement!.text(1),
                    size: statement!.int64(2),
                    state: statement!.int8(3),
                    saveType: saveType,
                    date: statement!.int(4),
                    useDate: statement!.int(5),
                    error: statement!.textOrNil(4)
                )
                list.append(dto)
            }
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        
        // 释放语句
        sqlite3_finalize(statement)
        self.lock.unlock()
        return list
    }
    
    /// 通过保存方式获取下载数据
    /// - Parameter saveType: 文件保存方式
    /// - Returns 文件路径
    static func selectIdBySaveType(_ saveType: Int8) -> [String]{
        let querySQL = "SELECT id FROM download WHERE saveType = \(saveType) ORDER BY useDate desc;"
        var statement: OpaquePointer?
        
        var list = [String]()
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            while sqlite3_step(statement) == SQLITE_ROW {
                list.append(String(cString: sqlite3_column_text(statement, 0)))
            }
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        
        // 释放语句
        sqlite3_finalize(statement)
        self.lock.unlock()
        return list
    }
    
    /// 获取某个时间之前使用过的缓存大小
    /// - Returns 某个时间之前使用过的缓存大小
    static func selectSizeByUsedDate(_ targetDate: Int) -> Int64{
        let querySQL = "SELECT SUM(size) FROM download WHERE saveType = 0 and useDate < \(targetDate);"
        var statement: OpaquePointer?
        var result: Int64 = 0
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            if sqlite3_step(statement) == SQLITE_ROW {
                result = statement!.int64(0)
            }
            
            // 释放语句
            sqlite3_finalize(statement)
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        self.lock.unlock()
        return result
    }
    
    /// 获取某个时间之前使用过的文件id
    /// - Returns 某个时间之前使用过的文件id
    public static func selectIdByUsedDate(_ targetDate: Int) -> [String]{
        let querySQL = "SELECT id FROM download WHERE saveType = 0 and useDate < \(targetDate);"
        var statement: OpaquePointer?
        var result = [String]()
        self.lock.lock()
        
        // 准备 SQL 语句
        if sqlite3_prepare_v2(self.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            
            // 遍历查询结果
            while sqlite3_step(statement) == SQLITE_ROW {
                result.append(statement!.text(0))
            }
            
            // 释放语句
            sqlite3_finalize(statement)
        } else {
            fatalError(String(cString: sqlite3_errmsg(self.db)))
        }
        self.lock.unlock()
        return result
    }
    
    
    ///建表语句
    private static let CREATE_SQL =
        """
        -- 文件下载表
        CREATE TABLE download
        (
            id       VARCHAR(32) PRIMARY KEY NOT NULL,
            url      VARCHAR(1024)           NOT NULL,           -- 下载URL
            name     VARCHAR(128)            NOT NULL,           -- 文件名
            size     INTEGER                 NOT NULL DEFAULT 0, -- 文件大小
            state    INTEGER                 NOT NULL DEFAULT 0,-- 文件状态 0:等待下载 1:下载中 2:暂停中 3:下载失败  10:下载完成
            saveType INTEGER                 NOT NULL,           -- 文件保存方式 0:临时缓存 1:永久保存
            date     INTEGER                 NOT NULL,           -- 文件创建时间戳(秒)
            useDate  INTEGER                 NOT NULL,           -- 文件最后使用时间戳(秒)
            error    TEXT                    NULL                -- 文件下载失败的错误消息
        );
        CREATE INDEX index_state ON download (state);
        CREATE INDEX index_saveType ON download (saveType);
        CREATE INDEX index_useDate ON download (useDate);
        """
}
