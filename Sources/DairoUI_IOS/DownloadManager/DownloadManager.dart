import 'dart:isolate';
import 'package:dairo_dfs_app/util/shared_preferences/SettingShared.dart';

import 'DownloadCode.dart';
import 'DownloadMessage.dart';
import 'DownloadThread.dart';

///文件上传任务
class DownloadManager {
  ///正在下载的文件信息
  final DownloadingInfo info;

  ///下载完成回调函数
  final void Function() onSuccess;

  ///下载完成回调函数
  final void Function(String error) onError;

  ///下载完成回调函数
  final void Function(int size, int downloadedSize, int speed, int remainder) onProgress;

  ///文件上传线程
  late Isolate _isolate;

  /// 这是一个往下载线程发送消息的端口
  SendPort? _toThreadSendPort;

  ///标记是否已开始了下载
  var isStrarted = false;

  ///标记是否被终止
  var isBreak = false;

  /// 创建一个 ReceivePort
  final _receivePort = ReceivePort();

  DownloadManager({
    required this.info,
    required this.onSuccess,
    required this.onError,
    required this.onProgress,
  }) {
    this._receivePort.listen(_receive);
  }

  ///接收到消息时的回调
  void _receive(Object? message) {
    message as DownloadMessage;
    switch (message.code) {
      case DownloadCode.SENDPORT: //公开内部消息通信端口
        this._toThreadSendPort = message.data as SendPort;
      case DownloadCode.OK: //上传完成
        this._receivePort.close(); //停止接收消息
        this._isolate.kill(priority: Isolate.immediate);
        this.onSuccess();
      case DownloadCode.FAIL: //上传出错
        final msg = message.data as String;
        this._receivePort.close(); //停止接收消息
        this._isolate.kill(priority: Isolate.immediate);
        this.onError(msg);
      case DownloadCode.PROGRESS: //上传进度
        if (this.isBreak) {
          //如果被标记了终端状态
          this._toThreadSendPort?.send("PAUSE");
          return;
        }
        final data = message.data as List<Object>;
        int size = data[0] as int;
        int downloadedSize = data[1] as int;
        int speed = data[2] as int;
        int needTime = data[3] as int;

        //更新进度
        this.onProgress(size, downloadedSize, speed, needTime);
      case DownloadCode.MESSAGE: //更新消息
      // final msg = message.data as String;
      // bean.msg = msg; //更新上传消息
      // EventUtil.post(EventCode.UPLOAD_PROGRESS); //通知更新页面
    }
  }

  ///开始下载
  void download() {
    this.isStrarted = true;
    if (this.isBreak) {
      //已经标记为终端,没有必要往下执行
      return;
    }
    Isolate.spawn((List<dynamic> args) async {
      //消息通信端口
      final sendPort = args[0] as SendPort;

      //正在下载的文件信息
      final info = args[1] as DownloadingInfo;

      //服务器主机
      final domain = args[2] as String;

      //开始上传线程
      final block = DownloadThread(sendPort, info, domain);
      await block.download();
    }, [this._receivePort.sendPort, this.info, SettingShared.domainNotNull]).then((instance) {
      this._isolate = instance;
    });
  }

  ///停止正在下载任务
  void pause() async {
    this.isBreak = true;
    if (!this.isStrarted) {
      //如果没有开始下载,直接返回
      return;
    }
    int cancelCount = 0;
    while (this._toThreadSendPort == null) {
      //下载已经开始,但是还有收到发送消息通知,所有这里循环等待一段时间,直到收到通知
      cancelCount++;
      print("-->等待关闭:$cancelCount");
      await Future.delayed(Duration(milliseconds: 100));
    }
    // if(cancelCount > 0){
    //   print("-->cancelCount:$cancelCount");
    // }
    this._toThreadSendPort?.send("PAUSE");
  }
}

///正在下载的文件信息
class DownloadingInfo {
  /// 文件路径
  final String token = SettingShared.token ?? "";

  /// 文件路径
  final String path;

  /// 文件下载url
  final String url;

  DownloadingInfo({required this.path, required this.url});
}
