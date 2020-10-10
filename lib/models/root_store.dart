import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/collection_notifier/map_notifier.dart';
import 'package:snippet_generator/main.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/utils/download_json.dart';
import 'package:snippet_generator/utils/persistence.dart';

class RootStore {
  final types = MapNotifier<String, TypeConfig>();
  final selectedTypeNotifier = AppNotifier<TypeConfig>(null);
  TypeConfig get selectedType => selectedTypeNotifier.value;

  RootStore() {
    GlobalKeyboardListener.addListener(_handleKeyPress);
    types.addEventListener((event, eventType) {
      if (selectedType != null &&
          !types.containsKey(selectedType.key) &&
          types.isNotEmpty) {
        selectedTypeNotifier.value = types.values.first;
      }
    });
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyZ) {
      if (event.isShiftPressed) {
        if (types.canRedo) {
          types.redo();
        }
      } else {
        if (types.canUndo) {
          types.undo();
        }
      }
    }
  }

  void addType() {
    final type = TypeConfig();
    selectedTypeNotifier.value = type;
    types[selectedTypeNotifier.value.key] = type;
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
  }

  static RootStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RootStoreProvider>().rootStore;

  void downloadJson() {
    final json = {
      "type": selectedType.toJson(),
      "classes": selectedType.classes.map((e) => e.toJson()).toList(),
      "fields": selectedType.classes
          .expand((e) => e.properties)
          .map((e) => e.toJson())
          .toList()
    };
    final jsonString = jsonEncode(json);
    downloadToClient(jsonString, "snippet_model.json", "application/json");
  }

  void importJson(Map<String, dynamic> json) {
    final type = TypeConfig.fromJson(json["type"] as Map<String, dynamic>);
    if (type != null) {
      types[type.key] = type;
      for (final _classJson in json["classes"] as List<dynamic>) {
        final c = ClassConfig.fromJson(_classJson as Map<String, dynamic>);
        _loadItem<ClassConfig>(
          c,
          c.typeConfig?.classes,
        );
      }
      for (final _propertyJson in json["fields"] as List<dynamic>) {
        final p = PropertyField.fromJson(_propertyJson as Map<String, dynamic>);
        _loadItem(
          p,
          p.classConfig?.properties,
        );
      }
    }
  }

  void loadHive() {
    final typeBox = getBox<TypeConfig>();
    types.addEntries(typeBox.values.map((e) => MapEntry(e.key, e)));

    final classBox = getBox<ClassConfig>();
    for (final c in classBox.values) {
      if (c.typeConfig != null) {
        _loadItem(c, c.typeConfig.classes);
      }
    }
    final propertyBox = getBox<PropertyField>();
    for (final c in propertyBox.values) {
      if (c.classConfig != null) {
        _loadItem(c, c.classConfig.properties);
      }
    }

    if (types.isEmpty) {
      addType();
    } else {
      final type = types.values.first;
      selectedTypeNotifier.value = type;
      types[selectedTypeNotifier.value.key] = type;
    }
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
}

void _loadItem<T extends Keyed>(
  T item,
  List<T> list,
) {
  if (item == null || list == null) {
    return;
  }
  final index = list.indexWhere((e) => e.key == item.key);
  if (index == -1) {
    list.add(item);
  } else {
    list[index] = item;
  }
}

RootStore useRootStore([BuildContext context]) {
  return RootStore.of(context ?? useContext());
}

TypeConfig useSelectedType([BuildContext context]) {
  final rootStore = RootStore.of(context ?? useContext());
  useListenable(rootStore.selectedTypeNotifier);
  return rootStore.selectedType;
}

class RootStoreProvider extends InheritedWidget {
  const RootStoreProvider({
    Key key,
    @required this.rootStore,
    @required Widget child,
  }) : super(child: child, key: key);
  final RootStore rootStore;

  @override
  bool updateShouldNotify(RootStoreProvider oldWidget) {
    return oldWidget.rootStore != rootStore;
  }
}
