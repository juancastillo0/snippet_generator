import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/collection_notifier/map_notifier.dart';
import 'package:snippet_generator/models/type_item.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/parsers/view/components_widget_store.dart';
import 'package:snippet_generator/themes/theme_store.dart';
import 'package:snippet_generator/utils/download_json.dart';
import 'package:snippet_generator/utils/persistence.dart';
import 'package:snippet_generator/views/globals.dart';
import 'package:dart_style/dart_style.dart';

enum AppTabs { types, ui, theme }

class RootStore {
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

  TypeItem? copiedItem;
  final selectedTabNotifier = AppNotifier(AppTabs.ui);
  AppTabs get selectedTab => selectedTabNotifier.value;

  final themeModeNotifier = AppNotifier(ThemeMode.dark);

  final componentWidgetsStore = ComponentWidgetsStore();

  final themesStore = ThemesStore(name: "themesStore");

  final MapNotifier<String, TypeConfig> types =
      MapNotifier<String, TypeConfig>();

  final selectedTypeNotifier = AppNotifier<TypeConfig?>(null);
  TypeConfig? get selectedType => selectedTypeNotifier.value;

  final isCodeGenNullSafeNotifier = AppNotifier<bool>(false);
  bool get isCodeGenNullSafe => isCodeGenNullSafeNotifier.value;

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

  bool importJson(Map<String, dynamic> json) {
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
  }

  void setSelectedTab(AppTabs tab) {
    this.selectedTabNotifier.value = tab;
  }
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
}

MessageEvent? parseMessageEvent(String rawString,
    {MessageEvent? defaultValue}) {
  for (final variant in MessageEvent.values) {
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
}

extension MessageEventExtension on MessageEvent {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  bool get isTypeCopied => this == MessageEvent.typeCopied;
  bool get isTypesSaved => this == MessageEvent.typesSaved;

  T when<T>({
    required T Function() typeCopied,
    required T Function() typesSaved,
  }) {
    switch (this) {
      case MessageEvent.typeCopied:
        return typeCopied();
      case MessageEvent.typesSaved:
        return typesSaved();
    }
  }

  T? maybeWhen<T>({
    T Function()? typeCopied,
    T Function()? typesSaved,
    T Function()? orElse,
  }) {
    T Function()? c;
    switch (this) {
      case MessageEvent.typeCopied:
        c = typeCopied;
        break;
      case MessageEvent.typesSaved:
        c = typesSaved;
        break;
    }
    return (c ?? orElse)?.call();
  }
}
