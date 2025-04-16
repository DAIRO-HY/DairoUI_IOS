import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'DownloadCode.dart';
import 'DownloadManager.dart';
import 'DownloadMessage.dart';

///文件上传任务
class DownloadThread {
  ///消息通信端口
  final SendPort sendPort;

  ///下载中的文件信息
  final DownloadingInfo info;

  ///服务器域名
  final String domain;

  ///接收消息端口
  final receivePort = ReceivePort();

  ///正在请求的客户端
  HttpClient? _client;

  ///是否被强制中断
  bool isBreak = false;

  DownloadThread(this.sendPort, this.info, this.domain) {
    //设置接收消息的函数
    this.receivePort.listen(this._receive);

    //向外部公开端口
    this.sendPort.send(DownloadMessage(DownloadCode.SENDPORT, this.receivePort.sendPort));
  }

  ///接收到消息时的回调
  Future<void> _receive(Object? msg) async {
    if (msg == "PAUSE") {
      //强行停止
      this.isBreak = true;
      this._client?.close(force: true);
    }
  }

  ///开始上传任务
  Future<void> download() async {
    try {
      await this._start();

      //上传完成
      this.sendPort.send(DownloadMessage(DownloadCode.OK));
    } catch (e) {
      if (this.isBreak) {
        //被强行停止
        this.sendPort.send(DownloadMessage(DownloadCode.FAIL, "PAUSE"));
        return;
      }
      //上传出错
      final String error;
      if (e is SocketException) {
        error = "网络连接失败";
      } else if (e is HttpException) {
        error = "网络连接中断";
      } else {
        error = e.toString();
      }
      final message = DownloadMessage(DownloadCode.FAIL, error);
      this.sendPort.send(message);
    } finally {
      this.receivePort.close();
    }
  }

  ///开始下载
  Future<void> _start() async {
    //当前下载文件
    final file = File(this.info.path);

    //已经下载大小
    int downloadedSize;
    if (file.existsSync()) {
      //得到已下载大小
      downloadedSize = file.lengthSync();
    }else {
      downloadedSize = 0;
    }

    //设置消息为正在下载
    final connctionMessage = DownloadMessage(DownloadCode.MESSAGE, "网络连接中");
    this.sendPort.send(connctionMessage);
    // final uri = Uri.parse(Const.DOMAIN + this.url + "&wait=100");

    var url = this.info.url;
    if(!url.startsWith("http")){
      url = this.domain + this.info.url;
    }
    final uri = Uri.parse(url);
    final client = HttpClient();
    this._client = client;

    IOSink? sink;
    try {
      final request = await client.openUrl("GET", uri);

      //禁止重定向
      request.followRedirects = false;
      request.headers.set(HttpHeaders.rangeHeader, "bytes=${downloadedSize}-");
      if(this.info.token.isNotEmpty){//添加认证Token
        request.headers.set(HttpHeaders.cookieHeader, "token=${this.info.token}");
      }
      final response = await request.close();
      if (response.statusCode == 416) { //文件应该是已经下载完成
        //文件已经下载完成
        return;
      }

      if (response.statusCode != 200 && response.statusCode != 206) {
        final body = await response.transform(utf8.decoder).join();
        //上传报错了
        throw Exception(body);
      }

      //得到文件大小
      final size = response.contentLength + downloadedSize;

      //当前时间戳
      var lastTime = DateTime
          .now()
          .millisecondsSinceEpoch;


      if (!file.existsSync()) { //文件不存在则创建文件
        file.createSync(recursive: true);
      }

      //文件输出流
      sink = file.openWrite(mode: FileMode.append);

      //最后一次记录的上传大小（用来计算网速）
      var lastDownloadSize = downloadedSize;
      await response.forEach((data) {
        sink!.add(data);
        downloadedSize += data.length;
        final curTime = DateTime
            .now()
            .millisecondsSinceEpoch;
        if (curTime - lastTime > 500) {
          //计算下载速度(Byte)
          final speed = (downloadedSize - lastDownloadSize) / (curTime - lastTime) * 1000;

          //剩余时间(毫秒)
          final needTime = (size - downloadedSize) / speed * 1000;

          //发送上传进度消息
          final message = DownloadMessage(DownloadCode.PROGRESS, [size, downloadedSize, speed.toInt(), needTime.toInt()]);

          this.sendPort.send(message);
          lastDownloadSize = downloadedSize;
          lastTime = DateTime.now().millisecondsSinceEpoch;
          // print("${downloadedSize.dataSize}/${size.dataSize}");
        }
        if (this.isBreak) {
          //上传被强行停止了
          throw Exception();
        }
      });

    } finally {
      await sink?.flush();
      await sink?.close();
      client.close();
    }
  }
}
