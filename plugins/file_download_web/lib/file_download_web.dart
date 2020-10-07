import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('file_download_web');

Future<String> get platformVersion async {
  final String version = await _channel.invokeMethod('getPlatformVersion');
  return version;
}

Future<void> downloadToClientWeb(
  String content,
  String fileName,
  String contentType,
) async {
  await _channel.invokeMethod('downloadToClient', {
    'content': content,
    'fileName': fileName,
    'contentType': contentType,
  });
}

Future<String> importFromClientWeb() async {
  return _channel.invokeMethod('importFromClient');
}
