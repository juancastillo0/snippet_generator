import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snippet_generator/models/serializer.dart';
import 'package:snippet_generator/models/type_models.dart';

final _boxesMap = {
  TypeConfig: _BoxConfig<TypeConfig>(0, "type", TypeConfig.serializer),
  ClassConfig: _BoxConfig<ClassConfig>(1, "class", ClassConfig.serializer),
  PropertyField:
      _BoxConfig<PropertyField>(2, "property", PropertyField.serializer),
};

Box<T> getBox<T>() {
  return Hive.box<T>(_boxesMap[T].boxName);
}

Future<void> initHive() async {
  await Hive.initFlutter();

  for (final _boxConfig in _boxesMap.values) {
    _boxConfig.register();
  }

  for (final _boxConfig in _boxesMap.values) {
    await _boxConfig.openBox();
  }
}

class _JsonAdapter<T> extends TypeAdapter<T> {
  _JsonAdapter({@required this.typeId, @required this.serializer});

  final Serializer<T> serializer;

  @override
  final int typeId;

  @override
  T read(BinaryReader reader) {
    final jsonString = reader.readString();
    final json = jsonDecode(jsonString);
    return serializer.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, T obj) {
    final json = serializer.toJson(obj);
    final jsonString = jsonEncode(json);
    writer.writeString(jsonString);
  }
}

class _BoxConfig<T> {
  final int typeId;
  final String boxName;
  final Serializer<T> serializer;

  const _BoxConfig(
    this.typeId,
    this.boxName,
    this.serializer,
  );

  void register() {
    Hive.registerAdapter<T>(
      _JsonAdapter<T>(
        typeId: typeId,
        serializer: serializer,
      ),
    );
  }

  Future<void> openBox() async {
    await _openBox<T>(boxName);
  }
}

Future<Box<T>> _openBox<T>(String name) async {
  Box<T> box;
  try {
    box = await Hive.openBox<T>(name);
  } catch (_) {
    Hive.deleteBoxFromDisk(name);
    box = await Hive.openBox<T>(name);
  }
  return box;
}
