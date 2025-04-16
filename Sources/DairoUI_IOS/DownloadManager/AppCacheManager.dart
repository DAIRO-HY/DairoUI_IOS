import 'dart:collection';
import 'dart:io';
import 'package:dairo_dfs_app/extension/String++.dart';
import 'package:flutter/cupertino.dart';

//在windows平台使用/作为文件路径分隔符时会报错，使用paths.normalize(path)将路径转换成特定操作系统的分隔符
import 'package:path/path.dart' as paths;
import 'package:dairo_dfs_app/util/shared_preferences/SettingShared.dart';
import 'package:synchronized/synchronized.dart';
import '../../db/dao/DownloadDao.dart';
import '../SyncVariable.dart';
import '../download/DownloadManager.dart';

class AppCacheManager {
  ///记录文件最后使用时间的后缀
  static const LAST_USE_DATE_FILE_END = ".date";

  ///同时下载数
  static const SYNC_COUNT = 5;

  ///每个链接对应的缓存管理实例锁
  static final url2cacheManagerLock = Lock();

  ///每个链接对应的缓存管理实例
  static final url2cacheManager = HashMap<String, AppCacheManagerBridge>();

  ///当前url
  final String url;

  ///下载成功之后回调
  final void Function(File file) onSuccess;

  ///[checkedDownload]是否检查已经下载
  AppCacheManager(this.url, {String? key, required this.onSuccess, bool checkedDownload = true}) {
    if (checkedDownload) {
      final download = DownloadDao.selectOneByUrlAndFinish(this.url);
      if (download != null) {
        final file = File(download.path);
        if (file.existsSync()) {
          //如果该文件已经被下载
          AppCacheManager._writeDate(file);
          this.onSuccess(file);
          return;
        }
      }
    }

    //得到缓存文件
    final file = AppCacheManager.getCacheFile(this.url);
    if (file.existsSync()) {
      //缓存文件已经存在
      AppCacheManager._writeDate(file);
      this.onSuccess(file);
      return;
    }
    AppCacheManager.url2cacheManagerLock.synchronized(() async {
      var bridge = AppCacheManager.url2cacheManager[this.url];
      if (bridge == null) {
        bridge = AppCacheManagerBridge(this.url, file);
        AppCacheManager.url2cacheManager[this.url] = bridge;
      }
      //将当前缓存实例添加到列表
      bridge.cacheManages.add(this);
    });
    AppCacheManager._download();
  }

  ///停止加载
  void cancel() {
    AppCacheManager.url2cacheManager[this.url]?.remove(this);
  }

  ///获取缓存文件，如果存在
  static File getCacheFile(String url) {
    final key = url.md5;

    //得到文件保存路径
    String path = paths.normalize("$cacheFolder/$key");
    final cacheFile = File(path);
    return cacheFile;
  }

  ///缓存目录
  static String get cacheFolder => paths.normalize("${SyncVariable.supportPath}/cache");

  ///启动下载
  static void _download() {
    AppCacheManager.url2cacheManagerLock.synchronized(() async {
      var startedCount = 0;
      for (var bridge in AppCacheManager.url2cacheManager.values) {
        if (startedCount >= AppCacheManager.SYNC_COUNT) {
          //限制同时下载数量
          break;
        }
        startedCount++;
        if (bridge.isStarted) {
          continue;
        }
        bridge.download();
      }
    });
  }

  ///创建一个文件名+.date的文件，用来记录最后一次读取时间，方便指定清除最近没有使用的缓存文件
  static void _writeDate(File file) {
    final dateFile = File(file.path + AppCacheManager.LAST_USE_DATE_FILE_END);
    if (!dateFile.existsSync()) {
      //如果文件不存在，则创建文件
      dateFile.createSync(recursive: true);
      file.createSync(recursive: true);
    }
    final dateStr = dateFile.readAsStringSync();
    final newDateStr = (DateTime.now().millisecondsSinceEpoch / 1000 / 60 / 60 / 24).toInt().toString();
    if (dateStr == newDateStr) {
      //如果时间是同一天，则不做任何处理
      return;
    }
    dateFile.writeAsStringSync(newDateStr);
  }
}

///缓存管理桥接
class AppCacheManagerBridge {
  ///下载管理
  late DownloadManager _downloadManager;

  ///当前url
  final String url;

  ///文件
  final File file;

  ///缓存管理列表
  final cacheManages = HashSet<AppCacheManager>();

  ///标记是否已启动
  var isStarted = false;

  AppCacheManagerBridge(this.url, this.file) {
    final info = DownloadingInfo(path: "${this.file.path}.temp", url: SettingShared.domainNotNull + this.url);
    this._downloadManager = DownloadManager(
        info: info, onSuccess: this.onSuccess, onError: this.onError, onProgress: (int size, int downloadedSize, int speed, int remainder) {});
  }

  ///开始下载
  void download() {
    this.isStarted = true;

    //下载之前先下入日期，避免文件下载一半时无法统计到缓存
    AppCacheManager._writeDate(File("${this.file.path}.temp"));
    this._downloadManager.download();
  }

  ///移除一个缓存管理
  void remove(AppCacheManager cacheManager) {
    AppCacheManager.url2cacheManagerLock.synchronized(() {
      //从缓存管理列表中移除
      this.cacheManages.remove(cacheManager);
      if (this.cacheManages.isEmpty) {
        //如果缓存管理为空列表,则移除这URL的下载管理
        AppCacheManager.url2cacheManager.remove(this.url);

        //下载停止
        this._downloadManager.pause();
      }
    });
    if (this.cacheManages.isEmpty) {
      //如果该下载地址的缓存管理被全部移除
      AppCacheManager._download();
    }
  }

  ///下载完成回调
  void onSuccess() {
    AppCacheManager.url2cacheManagerLock.synchronized(() {
      //重命名文件
      File(this.file.path + ".temp").renameSync(this.file.path);
      File(this.file.path + ".temp" + AppCacheManager.LAST_USE_DATE_FILE_END).renameSync(this.file.path + AppCacheManager.LAST_USE_DATE_FILE_END);
      for (final it in this.cacheManages) {
        it.onSuccess(this.file);
      }
      AppCacheManager.url2cacheManager.remove(this.url);
    });
    AppCacheManager._download();
  }

  ///下载完成回调
  void onError(String error) {
    debugPrint("图片下载出错:$error");
    AppCacheManager.url2cacheManagerLock.synchronized(() {
      AppCacheManager.url2cacheManager.remove(this.url);
    });
    AppCacheManager._download();
  }
}
