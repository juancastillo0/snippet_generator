import 'package:flutter/material.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/notifiers/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/types/type_models.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/parsers/widget_parsers/widget_parser.dart';

const _initialWidgetText = """
Center()
SizedBox(width: 400.0)
Container(
  height: 90,
  padding: (horizontal: 10),
  decoration: (
    color: white, borderRadius: 15,
    boxShadow: [ (color:black12 , offset: (0, 2), spreadRadius: 1, blurRadius: 3) ],
  ),
)
Row()
[
  Expanded()
  Text(text: "dw dw"),
  Padding(padding: 20)
  Text(text: "kk")
]
""";

class ParsedState {
  ParsedState() {
    controller.addListener(_onControllerChange);
    _onControllerChange();
  }

  Result<WidgetParser> get parsedWidget => _parsedWidget.value;
  late final AppNotifier<Result<WidgetParser>> _parsedWidget = AppNotifier(
    WidgetParser.parser.parse(controller.text),
    name: "parsedWidget",
  );

  WidgetParser? get selectedWidget => _selectedWidget.value;
  late final AppNotifier<WidgetParser?> _selectedWidget = AppNotifier(
    null,
    name: "selectedWidget",
  );

  final key = uuid.v4();
  final controller = TextEditingController(text: _initialWidgetText);
  final nameNotifier = TextNotifier();

  WidgetParser? _onControllerChange() {
    if (controller.text != _parsedWidget.value.buffer) {
      print("dwda");
      _parsedWidget.value = WidgetParser.parser.parse(controller.text);
    }

    final result = _parsedWidget.value;
    if (!result.isSuccess) {
      _selectedWidget.value = null;
    } else {
      final position = controller.selection.start;

      WidgetParser? getTokenAtPos(WidgetParser value) {
        final Token<List<dynamic>> token = value.token;
        if (!(token.start <= position && token.stop >= position)) {
          return null;
        }
        while (token.value.length == 3) {
          final v = token.value.last?.value;
          if (v is WidgetParser) {
            return getTokenAtPos(v) ?? value;
          } else if (v is List<WidgetParser>) {
            return v
                .map(getTokenAtPos)
                .firstWhere((e) => e != null, orElse: () => value);
          } else {
            return value;
          }
        }
        return value;
      }

      final value = getTokenAtPos(result.value);
      if (value?.form != null) {
        _selectedWidget.value = value;
      } else if (position == -1) {
        // _selectedWidget.value = result.value;
      }
    }
  }
}

class ComponentWidgetsStore {
  final componentWidgets = ListNotifier<ParsedState>([ParsedState()]);
  final selectedThemeIndex = AppNotifier(0, name: "selectedThemeIndex");
  final useDarkTheme = AppNotifier(false, name: "useDarkTheme");

  final selectedIndex = AppNotifier(0, name: "selectedIndex");

  void addComponentWidget() {
    selectedIndex.value = componentWidgets.length;
    final _parsedState = ParsedState();
    componentWidgets.add(_parsedState);
    _parsedState.nameNotifier.focusNode.requestFocus();
  }

  void deleteIndex(int index) {
    componentWidgets.removeAt(index);
    if (componentWidgets.isEmpty) {
      addComponentWidget();
    } else if (selectedIndex.value == componentWidgets.length) {
      selectedIndex.value--;
    }
  }
}
