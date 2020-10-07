import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_download_web/file_download_web.dart';
import 'package:file_chooser/file_chooser.dart';

void downloadToClient(
  String content,
  String fileName,
  String contentType,
) {
  if (kIsWeb) {
    downloadToClientWeb(content, fileName, contentType);
  } else {
    _downloadToClientNative(content, fileName, contentType);
  }
}

const _jsonFileType = [
  FileTypeFilterGroup(fileExtensions: ["json"])
];

Future<void> _downloadToClientNative(
  String content,
  String fileName,
  String contentType,
) async {
  final result = await showSavePanel(
    allowedFileTypes: _jsonFileType,
    suggestedFileName: fileName,
  );
  if (result.canceled || result.paths.isEmpty) {
    return;
  } else {
    // final directory = await getDownloadsDirectory();
    final file = io.File(result.paths[0]);
    return file.writeAsString(content); 
  }
}

Future<String> importFromClient() async {
  if (kIsWeb) {
    return importFromClientWeb();
  } else {
    final result = await showOpenPanel(
      allowedFileTypes: _jsonFileType,
      allowsMultipleSelection: false,
      canSelectDirectories: false,
    );
    if (result.canceled || result.paths.isEmpty) {
      return null;
    } else {
      final file = File(result.paths[0]);
      return file.readAsString();
    }
  }
}
