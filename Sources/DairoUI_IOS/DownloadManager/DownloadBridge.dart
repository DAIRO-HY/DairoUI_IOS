import 'dart:io';

import 'package:dairo_dfs_app/Const.dart';
import 'package:dairo_dfs_app/db/dto/DownloadDto.dart';
import 'package:dairo_dfs_app/extension/Number++.dart';
import 'package:dairo_dfs_app/extension/String++.dart';
import 'package:dairo_dfs_app/util/download/DownloadManager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../db/dao/DownloadDao.dart';
import '../even_bus/EventCode.dart';
import '../even_bus/EventUtil.dart';
import 'DownloadTask.dart';

class DownloadBridge {
  ///控制保存时间间隔
  static const SAVE_DOWNLOAD_SIZE_TIMER = 10 * 1000;

  ///下载文件信息
  DownloadDto dto;

  ///下载管理
  DownloadManager? _downloadManager;

  ///记录最后一次保存进度时间
  int lastSaveTime = 0;

  DownloadBridge(this.dto);

  ///上传进度
  double get progress {
    if (this.dto.size == 0) {
      //这是一个空文件
      return 1;
    }
    return this.dto.downloadedSize / this.dto.size;
  }

  ///开始下载
  void download() {
    if (this._downloadManager != null) {
      //任务已经在下载中，无需重复添加
      return;
    }
    this.dto.state = 1;
    final info = DownloadingInfo(url: this.dto.url, path: "${this.dto.path}.download");
    this._downloadManager = DownloadManager(info: info, onSuccess: this.onSuccess, onError: this.onError, onProgress: this.onProgress);
    this._downloadManager!.download();
  }

  ///暂停下载
  void pause() {
    DownloadDao.setSize(this.dto.id, this.dto.size);
    DownloadDao.setProgress(this.dto.id, this.dto.downloadedSize);
    this._downloadManager?.pause();
  }

  ///下载完成回调函数
  void onSuccess() {
    final downloadFile = File("${this.dto.path}.download");
    var file = File(this.dto.path);
    if (file.existsSync()) {
      //文件后缀
      final ext = "." + this.dto.path.fileExt;

      //文件名前缀
      final pre = this.dto.name.substring(0, this.dto.name.length - ext.length -1);

      //文件所在目录
      final folder = this.dto.path.fileParent;
      for (var i = 1; i < 1000000000; i++) {
        file = File("$folder/$pre($i)$ext");
        if (!file.existsSync()) {
          break;
        }
      }
      DownloadDao.setPath(this.dto.id,file.path);
    }
    downloadFile.renameSync(file.path);

    //标记为下载完成
    DownloadDao.setState(this.dto.id, 10);
    // DownloadDao.setSize(this.dto.id, File(this.dto.path).lengthSync());
    this._downloadManager = null;

    ///从正在下载的任务列表中将自己移除
    DownloadTask.removeDownloading(this);
    DownloadTask.start();

    //通知刷新页面
    EventUtil.post(EventCode.DOWNLOAD_PAGE_RELOAD);
    if (this.dto.saveToImageGallery == 0) {
      return;
    }

    //将相片或者视频保存到相册
    ImageGallerySaver.saveFile(this.dto.path).then((rs) {
      if (rs["isSuccess"]) {
        //保存到相册成功
      }
    });
  }

  ///下载完成回调函数
  void onError(String error) {
    if (error == "PAUSE") {
      //暂停操作
      DownloadDao.setState(this.dto.id, 2);
    } else {
      DownloadDao.setState(this.dto.id, 3, error);
    }
    this._downloadManager = null;

    ///从正在下载的任务列表中将自己移除
    DownloadTask.removeDownloading(this);
    DownloadTask.start();

    //通知刷新页面
    EventUtil.post(EventCode.DOWNLOAD_PROGRESS);
  }

  ///下载完成回调函数
  void onProgress(int size, int downloadedSize, int speed, int remainder) {
    this.dto.size = size;
    this.dto.downloadedSize = downloadedSize;
    this.dto.msg = "${speed.dataSize}/S 剩余时间 ${remainder.timeFormat}";

    //控制保存频率
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - this.lastSaveTime > DownloadBridge.SAVE_DOWNLOAD_SIZE_TIMER) {
      DownloadDao.setProgress(this.dto.id, downloadedSize);
      this.lastSaveTime = now;
    }
    //通知刷新页面
    EventUtil.post(EventCode.DOWNLOAD_PROGRESS);
  }
}
