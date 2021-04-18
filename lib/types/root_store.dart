import 'dart:async';
import 'dart:convert';
import 'package:file_system_access/file_system_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/notifiers/collection_notifier/map_notifier.dart';
import 'package:snippet_generator/types/type_item.dart';
import 'package:snippet_generator/types/type_models.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/parsers/views/components_widget_store.dart';
import 'package:snippet_generator/themes/theme_store.dart';
import 'package:snippet_generator/utils/download_json.dart';
import 'package:snippet_generator/utils/persistence.dart';
import 'package:snippet_generator/widgets/globals.dart';
import 'package:dart_style/dart_style.dart';
import 'package:y_crdt/y_crdt.dart';

enum AppTabs { types, ui, theme }

class RootStore {
  // final key = uuid.v4();

  TypeItem? lastSelectedItem;
  TypeItem? _selectedItem;
  TypeItem? get selectedItem => _selectedItem;
  void setSelectedItem(TypeItem item) {
    lastSelectedItem = item;
    Future.delayed(Duration.zero, () {
      _selectedItem = item;
    });
  }

  final formatter = DartFormatter();

  final ydoc = Doc();
  // late final provider = WebrtcProvider("root_store", ydoc, signaling: ['ws://localhost:4444']);

  TypeItem? copiedItem;
  final selectedTabNotifier = AppNotifier(AppTabs.ui);
  AppTabs get selectedTab => selectedTabNotifier.value;

  final themeModeNotifier = AppNotifier(ThemeMode.light, name: "themeMode");

  final componentWidgetsStore = ComponentWidgetsStore();

  final themesStore = ThemesStore(name: "themesStore");

  final types = MapNotifier<String, TypeConfig>();

  final selectedTypeNotifier = AppNotifier<TypeConfig?>(null);
  TypeConfig? get selectedType => selectedTypeNotifier.value;

  final isCodeGenNullSafeNotifier = AppNotifier<bool>(true);
  bool get isCodeGenNullSafe => isCodeGenNullSafeNotifier.value;

  final directoryHandle = AppNotifier<FileSystemDirectoryHandle?>(null);

  Future<void> selectDirectory() async {
    final directory = await FileSystem.instance.showDirectoryPicker();
    final permission = await directory.requestPermission(
        mode: FileSystemPermissionMode.readwrite);
    if (permission == PermissionStateEnum.granted) {
      if (directoryHandle.value != null) {
        final currentDir = directoryHandle.value!;
        if (await currentDir.isSameEntry(directory)) {
          return;
        } else {
          typeFiles.clear();
        }
      }
      directoryHandle.value = directory;
      await _saveTypeFiles(directory);
    }
  }

  final Map<String, _FileForType> typeFiles = {};

  Future<void> _saveTypeFiles(FileSystemDirectoryHandle directory) async {
    final Map<String, TypeConfig> typesToSave = types.map(
      (key, value) => MapEntry("${value.name.trim()}.dart", value),
    );
    typesToSave.remove(".dart");

    final _futs = typesToSave.entries.map((entry) async {
      final type = entry.value;
      final previous = typeFiles[entry.key];

      try {
        final sourceCode = type.sourceCode.value;
        final _hashCode = sourceCode.hashCode;
        if (previous != null && previous.sourceCodeHashCode == _hashCode) {
          return;
        }
        final file = await directory.getFileHandle(entry.key, create: true);
        final writable = await file.createWritable();

        await writable.write(FileSystemWriteChunkType.string(sourceCode));
        await writable.close();
        typeFiles[entry.key] = _FileForType(_hashCode, type, file);
      } catch (_) {}
    });
    await Future.wait(_futs);

    final _futsDelete = [...typeFiles.entries]
        .where((element) => !typesToSave.containsKey(element.key))
        .map((e) async {
      final fileHandle = e.value.fileHandle;
      await directory.removeEntry(fileHandle.name, recursive: true);
      typeFiles.remove(e.key);
    });
    await Future.wait(_futsDelete);
  }

  final _messageEventsController = StreamController<MessageEvent>.broadcast();
  Stream<MessageEvent> get messageEvents => _messageEventsController.stream;

  RootStore() {
    GlobalKeyboardListener.addKeyListener(_handleKeyPress);
    GlobalKeyboardListener.addTapListener(_handleGlobalTap);
    types.events.listen((data) {
      if (selectedType != null &&
          !types.containsKey(selectedType!.key) &&
          types.isNotEmpty) {
        selectedTypeNotifier.value = types.values.first;
      }
    });
    // provider.on("synced", (_) {
    //   print("synched");
    // });
  }

  void _handleGlobalTap(_) {
    _selectedItem = null;
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.isControlPressed) {
      if (event.logicalKey == LogicalKeyboardKey.keyZ) {
        if (event.isShiftPressed) {
          if (types.canRedo) {
            types.redo();
          }
        } else {
          if (types.canUndo) {
            types.undo();
          }
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
        if (selectedItem != null) {
          copiedItem = selectedItem;
          // Clipboard.setData(ClipboardData(text: copiedItem.toJson))
          _messageEventsController.add(MessageEvent.typeCopied);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
        if (copiedItem != null && lastSelectedItem != null) {
          copiedItem!.when(
            classI: (c) {
              final t = lastSelectedItem!.parentType();
              t.classes.add(c.clone().copyWith(typeConfigKey: t.key));
            },
            typeI: (t) {
              selectedTypeNotifier.value = t.clone();
              types[selectedType!.key] = selectedType!;
            },
            propertyI: (p) {
              final c = lastSelectedItem!.parentClass();
              if (c != null) {
                c.properties.add(p.copyWith(classConfigKey: c.key));
              }
            },
            propertyListI: (pList) {
              final c = lastSelectedItem!.parentClass();
              if (c != null) {
                c.properties.addAll(
                  pList.map((e) => e.copyWith(classConfigKey: c.key)),
                );
              }
            },
          );
        }
      }
    }
  }

  void addType() {
    final type = TypeConfig();
    selectedTypeNotifier.value = type;
    types[selectedTypeNotifier.value!.key] = type;
    type.addVariant();
  }

  void removeType(TypeConfig type) {
    types.remove(type.key);
    // final typeFile = typeFiles.values.firstWhereOrNull((element) => false);
    if (types.isEmpty) {
      addType();
    } else if (type == selectedTypeNotifier.value) {
      selectedTypeNotifier.value = types.values.first;
    }
  }

  void selectType(TypeConfig type) {
    selectedTypeNotifier.value = type;
    setSelectedItem(TypeItem.typeI(type));
  }

  void selectClass(ClassConfig type) {
    setSelectedItem(TypeItem.classI(type));
  }

  void selectProperty(PropertyField type) {
    setSelectedItem(TypeItem.propertyI(type));
  }

  static RootStore of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<RootStoreProvider>()!
      .rootStore;

  Future<void> copySourceCode(String sourceCode) async {
    await Clipboard.setData(
      ClipboardData(text: sourceCode),
    );
    _messageEventsController.add(MessageEvent.sourceCodeCopied);
  }

  void downloadJson() {
    final json = {
      "type": selectedType!.toJson(),
      "classes": selectedType!.classes.map((e) => e.toJson()).toList(),
      "fields": selectedType!.classes
          .expand((e) => e.properties)
          .map((e) => e.toJson())
          .toList()
    };
    final jsonString = jsonEncode(json);
    downloadToClient(jsonString, "snippet_model.json", "application/json");
  }

  bool importJson(String jsonString) {
    Map<String, dynamic> json = const {};
    try {
      json = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, s) {
      print("jsonDecode error $e\n$s");
    }
    try {
      final type = TypeConfig.fromJson(json["type"] as Map<String, dynamic>);

      types[type.key] = type;
      for (final _classJson in json["classes"] as List<dynamic>) {
        final c = ClassConfig.fromJson(_classJson as Map<String, dynamic>);
        _loadItem<ClassConfig>(
          c,
          c.typeConfig.classes,
        );
      }
      for (final _propertyJson in json["fields"] as List<dynamic>) {
        final p = PropertyField.fromJson(_propertyJson as Map<String, dynamic>);
        _loadItem(
          p,
          p.classConfig?.properties,
        );
      }
      selectedTypeNotifier.value = type;
      return true;
    } catch (e, s) {
      print("error $e\n$s");
      _messageEventsController.add(MessageEvent.errorImportingTypes);
      return false;
    }
  }

  Future<void> loadHive() async {
    final typeBox = getBox<TypeConfig>();
    types.addEntries(typeBox.values.map((e) => MapEntry(e.key, e)));

    final _toDeleteClass = <String>[];
    final _toDeleteProps = <String>[];

    final classBox = getBox<ClassConfig>();
    for (final c in classBox.values) {
      if (types.containsKey(c.typeConfigKey)) {
        _loadItem(c, c.typeConfig.classes);
      } else {
        _toDeleteClass.add(c.key);
      }
    }
    final propertyBox = getBox<PropertyField>();
    for (final c in propertyBox.values) {
      if (c.classConfig != null) {
        _loadItem(c, c.classConfig!.properties);
      } else {
        _toDeleteProps.add(c.key);
      }
    }

    if (types.isEmpty) {
      addType();
    } else {
      final type = types.values.first;
      selectedTypeNotifier.value = type;
      types[selectedTypeNotifier.value!.key] = type;
    }

    await Future.wait([
      classBox.deleteAll(_toDeleteClass),
      propertyBox.deleteAll(_toDeleteProps),
    ]);
  }

  Future<void> saveHive() async {
    final typeBox = getBox<TypeConfig>();
    await typeBox.clear();
    await typeBox.addAll(types.values);

    final classBox = getBox<ClassConfig>();
    await classBox.clear();
    await classBox.addAll(types.values.expand((e) => e.classes));

    final propertyBox = getBox<PropertyField>();
    await propertyBox.clear();
    await propertyBox.addAll(
        types.values.expand((e) => e.classes).expand((e) => e.properties));

    if (directoryHandle.value != null) {
      await _saveTypeFiles(directoryHandle.value!);
    }
    _messageEventsController.add(MessageEvent.typesSaved);
  }

  void setSelectedTab(AppTabs tab) {
    this.selectedTabNotifier.value = tab;
  }
}

class _FileForType {
  final int sourceCodeHashCode;
  final TypeConfig type;
  final FileSystemFileHandle fileHandle;

  _FileForType(this.sourceCodeHashCode, this.type, this.fileHandle);
}

void _loadItem<T extends Keyed>(
  T item,
  List<T>? list,
) {
  if (list == null) {
    return;
  }
  final index = list.indexWhere((e) => e.key == item.key);
  if (index == -1) {
    list.add(item);
  } else {
    list[index] = item;
  }
}

RootStore useRootStore([BuildContext? context]) {
  return RootStore.of(context ?? useContext());
}

TypeConfig useSelectedType([BuildContext? context]) {
  final rootStore = RootStore.of(context ?? useContext());
  useListenable(rootStore.selectedTypeNotifier);
  return rootStore.selectedType!;
}

class RootStoreProvider extends InheritedWidget {
  const RootStoreProvider({
    Key? key,
    required this.rootStore,
    required Widget child,
  }) : super(child: child, key: key);
  final RootStore rootStore;

  @override
  bool updateShouldNotify(RootStoreProvider oldWidget) {
    return oldWidget.rootStore != rootStore;
  }
}

enum MessageEvent {
  typeCopied,
  typesSaved,
  sourceCodeCopied,
  errorImportingTypes,
}

extension MessageEventExtension on MessageEvent {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];
}
