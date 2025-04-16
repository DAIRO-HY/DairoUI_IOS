//
//  DownloadTask.swift
//  DairoUI_IOS
//
//  Created by zhoulq on 2025/04/16.
//


///文件上传任务
class DownloadTask {
//  ///当前正在下载的列表
//  static final downloadingId2Bridge = HashMap<int, DownloadBridge>();
//
//  ///同时下载数
//  static var syncCount = SettingShared.downloadSyncCount;
//
//  ///开始下载
//  static void start() async {
//    while (true) {
//      if (DownloadTask.downloadingId2Bridge.length >= DownloadTask.syncCount) {
//        //同时下载数量达到了上线
//        break;
//      }
//
//      //正在下载的id
//      final downloadingIds = DownloadTask.downloadingId2Bridge.keys.toList().join(",");
//
//      //获取一条需要下载的数据
//      final dto = DownloadDao.selectOneByNotDownload(downloadingIds);
//      if (dto == null) {
//        break;
//      }
//
//      //避免同一个下载链接同时下载
//      //避免两个文件同时保存同一个文件
//      if (DownloadTask.downloadingId2Bridge.values.toList().find((it) => it.dto.url == dto.url || it.dto.path == dto.path) != null) {
//        break;
//      }
//
//      if(dto.md5 == null){
//
//        //下载之前,先获取文件信息
//        final http = HttpUtil(dto.url.domainUrl);
//        http.connectTimeout = 5000;
//        await http.head();
//        final contextLength = http.responseHeader?["content-length"];
//
//        //这里并非文件真正的MD5，而是双重加密的MD5
//        final contextMd5 = http.responseHeader?["content-md5"];
//        if (contextLength == null || contextMd5 == null) {
//          DownloadDao.setState(dto.id, 3, "获取文件信息失败");
//
//          //通知刷新页面
//          EventUtil.post(EventCode.DOWNLOAD_PAGE_RELOAD);
//          continue;
//        }
//        final size = int.parse(contextLength);
//        DownloadDao.setSizeAndMd5(dto.id, size, contextMd5);
//        dto.size = size;
//        dto.md5 = contextMd5;
//      }
//
//      //避免同一个MD5的文件同时下载
//      if (DownloadTask.downloadingId2Bridge.values.toList().find((it) => it.dto.md5 == dto.md5) != null) {
//        break;
//      }
//
//      if(File(dto.path).existsSync() && dto.size == File(dto.path).lengthSync() && dto.md5 == await File(dto.path).md5){
//        //该文件已经下载完成
//        DownloadDao.setState(dto.id, 10);
//
//        //通知刷新页面
//        EventUtil.post(EventCode.DOWNLOAD_PAGE_RELOAD);
//        continue;
//      }
//      final md5Dto = DownloadDao.selectOneByMd5AndFinish(dto.md5!);
//      if(md5Dto != null && File(md5Dto.path).existsSync() && dto.size == File(md5Dto.path).lengthSync() && dto.md5 == await File(md5Dto.path).md5){
//        //该文件已经下载完成,将文件复制到目标目录
//        var file = File(dto.path);
//        if (file.existsSync()) {
//          //文件后缀
//          final ext = "." + dto.path.fileExt;
//
//          //文件名前缀
//          final pre = dto.name.substring(0, dto.name.length - ext.length - 1);
//
//          //文件所在目录
//          final folder = dto.path.fileParent;
//          for (var i = 1; i < 1000000000; i++) {
//            file = File("$folder/$pre($i)$ext");
//            if (!file.existsSync()) {
//              break;
//            }
//          }
//          DownloadDao.setPath(dto.id,file.path);
//        }
//
//        //创建文件夹
//        Directory(file.path.fileParent).createSync(recursive: true);
//        File(md5Dto.path).copySync(file.path);
//
//        //该文件已经下载完成
//        DownloadDao.setState(dto.id, 10);
//
//        //通知刷新页面
//        EventUtil.post(EventCode.DOWNLOAD_PAGE_RELOAD);
//        continue;
//      }
//
//      final bridge = DownloadBridge(dto);
//      DownloadTask.downloadingId2Bridge[dto.id] = bridge;
//    }
//    for (var it in DownloadTask.downloadingId2Bridge.values) {
//      it.download();
//    }
//  }
//
//  ///移除一个正在下载任务
//  static void removeDownloading(DownloadBridge bridge) {
//    DownloadTask.downloadingId2Bridge.remove(bridge.dto.id);
//  }
}
