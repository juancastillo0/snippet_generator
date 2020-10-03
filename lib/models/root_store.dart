import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/main.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/type_models.dart';

class RootStore {
  final types = ListNotifier<TypeConfig>([]);
  final selectedTypeNotifier = AppNotifier<TypeConfig>(null);
  TypeConfig get selectedType => selectedTypeNotifier.value;

  RootStore() {
    GlobalKeyboardListener.addListener(_handleKeyPress);
    addType();
    types.addEventListener((event, eventType) {
      if (eventType.isApply && event is RemoveListEvent<TypeConfig>) {
        if (event.value == selectedType) {
          if (types.isNotEmpty) {
            selectedTypeNotifier.value = types.first;
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
    selectedTypeNotifier.value = TypeConfig();
    types.add(selectedTypeNotifier.value);
  }

  void removeType(TypeConfig type) {
    types.remove(type);
    if (types.isEmpty) {
      addType();
    } else if (type == selectedTypeNotifier.value) {
      selectedTypeNotifier.value = types[0];
    }
  }

  void selectType(TypeConfig type) {
    selectedTypeNotifier.value = type;
  }

  static RootStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RootStoreProvider>().rootStore;
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
