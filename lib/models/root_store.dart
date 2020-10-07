import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/collection_notifier/map_notifier.dart';
import 'package:snippet_generator/main.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/utils/download_json.dart';

class RootStore {
  final types = MapNotifier<String, TypeConfig>();
  final selectedTypeNotifier = AppNotifier<TypeConfig>(null);
  TypeConfig get selectedType => selectedTypeNotifier.value;

  RootStore() {
    GlobalKeyboardListener.addListener(_handleKeyPress);
    addType();
    types.addEventListener((event, eventType) {
      if (eventType.isApply && event is MapRemoveEvent<String, TypeConfig>) {
        if (event.value == selectedType) {
          if (types.isNotEmpty) {
            selectedTypeNotifier.value = types.values.first;
          } else {
            selectedTypeNotifier.value = null;
          }
        }
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
        final _class = ClassConfig.fromJson(_classJson as Map<String, dynamic>);
        if (_class != null) {
          final index =
              _class.typeConfig.classes.indexWhere((e) => e.key == _class.key);
          if (index == -1) {
            _class.typeConfig.classes.add(_class);
          } else {
            _class.typeConfig.classes[index] = _class;
          }
        }
      }
      for (final _propertyJson in json["fields"] as List<dynamic>) {
        final _property = PropertyField.fromJson(_propertyJson as Map<String, dynamic>);
        if (_property != null) {
          final index =
              _property.classConfig.properties.indexWhere((e) => e.key == _property.key);
          if (index == -1) {
            _property.classConfig.properties.add(_property);
          } else {
            _property.classConfig.properties[index] = _property;
          }
        }
      }
    }
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
