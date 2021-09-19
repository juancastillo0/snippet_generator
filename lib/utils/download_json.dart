import 'dart:typed_data';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_system_access/file_system_access.dart';

Future<String?> getDirectory() async {
  final handle = await FileSystem.instance.showDirectoryPicker();
  if (handle == null) {
    return null;
  }
  print(handle.name);
  final fileResult = await handle.getFileHandle('nameFile.txt', create: true);

  await fileResult.when(
    ok: (file) async {
      print(file.name);

      final writable = await file.createWritable();
      // await writable.write(FileSystemWriteChunkType.string("appended"));
      await writable.close();
    },
    err: (err) async {},
  );

  return handle.name;
  // } else {
  //   final path = await FileSelectorPlatform.instance.getDirectoryPath();
  //   return path;
  // }
}

void downloadToClient(
  String content,
  String fileName,
  String contentType,
) {
  _downloadToClientNative(content, fileName, contentType);
}

final _jsonFileType = [
  XTypeGroup(extensions: ['json'])
];

Future<void> _downloadToClientNative(
  String content,
  String fileName,
  String contentType,
) async {
  final path = await FileSelectorPlatform.instance.getSavePath(
    acceptedTypeGroups: _jsonFileType,
    suggestedName: fileName,
  );
  if (path == null) {
    return;
  } else {
    final textFile = XFile.fromData(
      Uint8List.fromList(content.codeUnits),
      mimeType: 'text/plain',
      name: fileName,
    );
    await textFile.saveTo(path);
  }
}

Future<String?> importFromClient() async {
  final file = await FileSelectorPlatform.instance.openFile(
    acceptedTypeGroups: _jsonFileType,
    // allowsMultipleSelection: false,
    // canSelectDirectories: false,
  );
  if (file == null) {
    return null;
  } else {
    return file.readAsString();
  }
}
