import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class BetterFileMd5PluginApi {

  static Stream resultStream = EventChannel("io.github.wangyng.better_file_md5_plugin/resultStream").receiveBroadcastStream();

  static Future<void> fileMd5({required int instanceId, required String filePath}) async {
    const channel = BasicMessageChannel<dynamic>('io.github.wangyng.better_file_md5_plugin.fileMd5', StandardMessageCodec());

    final Map<String, dynamic> requestMap = {};
    requestMap["instanceId"] = instanceId;
    requestMap["filePath"] = filePath;
    final reply = await channel.send(requestMap);

    if (!(reply is Map)) {
      _throwChannelException();
    }

    final replyMap = Map<String, dynamic>.from(reply);
    if (replyMap['error'] != null) {
      final error = Map<String, dynamic>.from(replyMap['error']);
      _throwException(error);
      
    } else {
      // noop
    }
  }

}

_throwChannelException() {
  throw PlatformException(code: 'channel-error', message: 'Unable to establish connection on channel.', details: null);
}

_throwException(Map<String, dynamic> error) {
  throw PlatformException(code: "${error['code']}", message: "${error['message']}", details: "${error['details']}");
}
