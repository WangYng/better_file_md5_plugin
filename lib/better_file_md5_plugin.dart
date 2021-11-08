import 'dart:async';

import 'package:better_file_md5_plugin/better_file_md5_plugin_api.dart';

class BetterFileMd5 {

  /// 计算文件的Md5, 无论文件多大都不会阻塞主线程
  static Future<String?> md5(String filePath) async {
    final fileMd5Plugin = BetterFileMd5Plugin();

    String? md5;
    final md5Completer = Completer();

    StreamSubscription subscription = fileMd5Plugin.resultStream.listen((event) {
      md5 = event;
      md5Completer.complete();
    });
    await fileMd5Plugin.fileMd5(filePath: filePath);

    await md5Completer.future;
    subscription.cancel();

    return md5;
  }
}

class BetterFileMd5Plugin {
  static int _firstInstanceId = 1;

  final int instanceId = _firstInstanceId++;

  /// 返回的文件Md5计算结果
  late Stream resultStream;

  BetterFileMd5Plugin() {
    resultStream = BetterFileMd5PluginApi.resultStream.where((event) {
      if (event is Map) {
        final instanceId = int.tryParse(event["instanceId"]?.toString() ?? "") ?? -1;
        return instanceId == this.instanceId;
      }
      return false;
    }).map<String?>((event) {
      return event["md5"]?.toString();
    });
  }

  Future<void> fileMd5({required String filePath}) async {
    return BetterFileMd5PluginApi.fileMd5(instanceId: instanceId, filePath: filePath);
  }
}
