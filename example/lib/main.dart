import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:better_file_md5_plugin/better_file_md5_plugin.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String hexMd5 = "";
  String base64Md5 = "";

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // save image to local path
      final bytes = Uint8List.view((await rootBundle.load("images/logo.png")).buffer);
      final file = File(path.join((await getTemporaryDirectory()).path, "logo.png"));
      if (!file.existsSync()) {
        await file.writeAsBytes(bytes);
      }

      final md5 = await BetterFileMd5.md5(file.path);
      if (md5 != null && mounted) {
        setState(() {
          base64Md5 = md5;
          hexMd5 = hex.encode(base64Decode(md5));
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
          child: Text('base64Md5 : $base64Md5 \nhexMd5 : $hexMd5'),
        ),
      ),
    );
  }
}
