import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the FileDownloadWeb plugin.
class FileDownloadWebWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'file_download_web',
      const StandardMethodCodec(),
      registrar.messenger,
    );

    final pluginInstance = FileDownloadWebWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getPlatformVersion':
        return getPlatformVersion();
        break;
      case 'downloadToClient':
        return _downloadToClientWeb(
            call.arguments["content"] as String,
            call.arguments["fileName"] as String,
            call.arguments["contentType"] as String);
      case 'importFromClient':
        return _importFromClientWeb();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              "file_download_web for web doesn't implement '${call.method}'",
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }
}

void _downloadToClientWeb(
  String content,
  String fileName,
  String contentType,
) {
  final file = html.Blob([content], contentType);
  final a = html.AnchorElement(href: html.Url.createObjectUrlFromBlob(file));
  a.download = fileName;
  a.click();
  a.remove();
}

Future<String> _importFromClientWeb() async {
  final input = html.InputElement(type: "file");
  input.accept = "application/json";
  final completer = Completer<String>();

  input.onChange.listen((event) {
    if (input.files.isNotEmpty) {
      final file = input.files[0];
      if (file.type != "application/json") {
        html.window.alert(
            "Debes seleccionar un archivo válido, la extensión debe ser '.json'.");

        return completer.complete(null);
      }

      final reader = html.FileReader();
      reader.onLoad.listen((e) {
        return completer.complete(reader.result as String);
      });
      reader.readAsText(file);
    } else {
      return completer.complete(null);
    }
  });
  input.click();
  final result = await completer.future;
  input.remove();
  return result;
}
