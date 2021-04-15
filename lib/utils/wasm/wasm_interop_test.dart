// import 'dart:io';
// import 'dart:typed_data';
// import 'package:test/test.dart';
// import 'package:wasm/wasm.dart';

// WasmInstance createWasm(Uint8List bytes) {
//   final module = WasmModule(bytes);
//   return module.instantiate().build();
// }

// Future<void> main() async {
//   print(Platform.resolvedExecutable);
//   final file = File("./lib/utils/main.wasm");
//   final moduleBytes = await file.readAsBytes();

//   final instance = createWasm(moduleBytes);
//   final addFunc = instance.lookupFunction("add");
//   final result = addFunc.call([1, 2]);
//   test("", () {
//     expect(result, 3);
//   });
// }
