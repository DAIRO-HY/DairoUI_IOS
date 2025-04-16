import 'DownloadCode.dart';

///上传消息
class DownloadMessage {

  /// 状态值
  final DownloadCode code;

  /// 消息数据
  final Object? data;
  DownloadMessage(this.code,[this.data]);
}
