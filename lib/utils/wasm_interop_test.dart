import 'dart:io';
import 'dart:typed_data';
import 'dart:wasm';
import 'package:test/test.dart';

WasmInstance createWasm(Uint8List bytes) {
  final module = WasmModule(bytes);
  final imports = WasmImports();
  return module.instantiate(imports);
}

Future<void> main() async {
  final file = File("./lib/utils/main.wasm");
  final moduleBytes = await file.readAsBytes();

  final instance = createWasm(moduleBytes);
  final addFunc = instance.lookupFunction("add");
  final result = addFunc.call([1, 2]);
  test("", () {
    expect(result, 3);
  });
}
