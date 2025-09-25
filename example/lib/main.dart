import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:better_file_md5_plugin/better_file_md5_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String hexMd5 = "--loading--";
  String base64Md5 = "--loading--";
  String filePath = "--loading--";

  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      // save image to local path
      final bytes = Uint8List.view((await rootBundle.load("images/logo.png")).buffer);
      final tempDir = Directory.systemTemp;
      final file = File(path.join(tempDir.path, "logo.png"));
      if (!file.existsSync()) {
        await file.writeAsBytes(bytes);
      }
      setState(() {
        filePath = file.path;
      });

      final md5 = await BetterFileMd5.md5(file.path);
      if (md5 != null && mounted) {
        setState(() {
          base64Md5 = md5;
          hexMd5 = _bytesToHex(base64Decode(md5));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('filePath: ${filePath} \nbase64Md5 : $base64Md5 \nhexMd5 : $hexMd5'),
        ),
      ),
    );
  }
}
