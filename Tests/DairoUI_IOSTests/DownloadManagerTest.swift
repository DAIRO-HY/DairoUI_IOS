//
//  DownloadDBUtilTest.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/08/05.
//
import Testing
import SQLite3
@testable import DairoUI_IOS
import Foundation

@Test func DownloadManager_add() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    for i in 1 ... 100{
        Task.detached{
            DownloadManager.cache("\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100")
        }
    }
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_add2() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    for i in 1 ... 10{
        Task.detached{
            DownloadManager.cache("\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=10")
        }
    }
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_save() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    
    var list = [(String,String)]()
    for i in 1 ... 10{
        list.append(("1-\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=\(i * 10)"))
    }
    try DownloadManager.save(list)
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_add_save() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    Task.detached{
        await Task.sleep(1_000_000_000)
        for i in 1 ... 10{
            Task.detached{
                DownloadManager.cache("\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=30")
            }
        }
    }
    
    var list = [(String,String)]()
    for i in 1 ... 10{
        list.append(("1-\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=\(i * 1000000)"))
    }
    try DownloadManager.save(list)
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_add_save2() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    for i in 1 ... 10{
        Task.detached{
            DownloadManager.cache("\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=100")
        }
    }
    
    var list = [(String,String)]()
    for i in 1 ... 10{
        list.append(("1-\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=\(i * 10)"))
    }
    try DownloadManager.save(list)
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_add_save3() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    var list = [(String,String)]()
    for i in 1 ... 1{
        list.append(("112233", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=\(i * 1000000)"))
    }
    try DownloadManager.save(list)
    await Task.sleep(3_000_000_000)
    DownloadManager.cancel("112233")
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_add_save4() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    
    DownloadManager.cache("112233", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=1000000")
    var list = [(String,String)]()
    for i in 1 ... 1{
        list.append(("112233", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=1000000"))
    }
    try DownloadManager.save(list)
    await Task.sleep(3_000_000_000)
    DownloadManager.cancel("112233")
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_cancel() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    for i in 1 ... 100{
        Task.detached{
            DownloadManager.cache("\(i)", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=10000000")
        }
    }
    await Task.sleep(1_000_000_000)
    for i in 1 ... 100{
        Task.detached{
            DownloadManager.cancel("\(i)")
        }
    }
    await Task.sleep(999_000_000_000)
}

@Test func DownloadManager_cancel2() async throws {
    Task.detached{
        while true{
            print("-->⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎⬇︎")
            print("-->DownloadManager.id2count.count:\(DownloadManager.id2count.count)")
            print("-->DownloadManager.id2download.count:\(DownloadManager.id2download.count)")
            print("-->DownloadManager.waitingId2url.count:\(DownloadManager.waitingId2url.count)")
            print("-->⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎⬆︎")
            await Task.sleep(1_000_000_000)
            
        }
    }
    for i in 1 ... 100{
        Task.detached{
            DownloadManager.cache("1122", "http://localhost:8031/d/oq8221/%E7%9B%B8%E5%86%8C/1753616814872371.heic?wait=10000000")
        }
    }
    await Task.sleep(3_000_000_000)
    for i in 1 ... 100{
        Task.detached{
            DownloadManager.cancel("1122")
        }
    }
    await Task.sleep(999_000_000_000)
}
