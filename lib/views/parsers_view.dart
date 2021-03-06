import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/parsers/widget_parser.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/widgets.dart';

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
        _selectedWidget.value = result.value;
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

class ParsersView extends HookWidget {
  const ParsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);
    final store = rootStore.componentWidgetsStore;

    return Column(
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            border: Border(
              bottom: BorderSide(
                color: context.theme.canvasColor,
                width: 2,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Scrollbar(
                  child: Observer(
                    builder: (context) => ListView(
                      itemExtent: 140.0,
                      scrollDirection: Axis.horizontal,
                      children: store.componentWidgets.mapIndex(
                        (component, index) {
                          return ComponentWidgetTab(
                            onTap: () {
                              store.selectedIndex.value = index;
                            },
                            onDelete: () {
                              store.deleteIndex(index);
                            },
                            componentWidget: component,
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: store.addComponentWidget,
                style: menuStyle(context),
                child: const Text("ADD"),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 12.0, right: 8.0),
                child: Center(child: Text("Theme")),
              ),
              Observer(
                builder: (context) => DropdownButton<int>(
                  onChanged: (index) {
                    if (index != null) {
                      store.selectedThemeIndex.value = index;
                    }
                  },
                  value: store.selectedThemeIndex.value,
                  items: rootStore.themesStore.themes
                      .mapIndex(
                        (e, index) => DropdownMenuItem(
                          value: index,
                          child: Observer(
                            builder: (context) => Text(e.name.value),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 12),
              RowBoolField(
                notifier: store.useDarkTheme,
                label: "Dark",
              ),
            ],
          ),
        ),
        const Expanded(
          child: _ParsersViewBody(),
        ),
      ],
    );
  }
}

class ComponentWidgetTab extends HookWidget {
  const ComponentWidgetTab({
    Key? key,
    required this.onTap,
    required this.onDelete,
    required this.componentWidget,
  }) : super(key: key);

  final void Function() onTap;
  final void Function() onDelete;
  final ParsedState componentWidget;

  @override
  Widget build(BuildContext context) {
    final show = useState(false);

    return MenuPortalEntry(
      options: [
        TextButton(
          onPressed: onDelete,
          style: menuStyle(context),
          child: const Text("delete"),
        )
      ],
      onClose: () {
        show.value = false;
      },
      isVisible: show.value,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (event.buttons == 2) {
            show.value = true;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(isDense: true),
            onTap: onTap,
            controller: componentWidget.nameNotifier.controller,
            focusNode: componentWidget.nameNotifier.focusNode,
          ),
        ),
      ),
    );
  }
}

class _ParsersViewBody extends HookWidget {
  const _ParsersViewBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);
    final store = rootStore.componentWidgetsStore;
    final themesStore = rootStore.themesStore;
    final componentWidget = store.componentWidgets[store.selectedIndex.value];

    useEffect(() {
      if (themesStore.themes.length <= store.selectedThemeIndex.value) {
        store.selectedThemeIndex.value = 0;
      }
    }, [themesStore.themes.length]);
    useListenable(store.selectedIndex);

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    final selected = componentWidget.selectedWidget;
                    return selected?.form != null
                        ? selected!.form!.call(
                            selected.tokenParsedParams,
                            componentWidget.controller,
                          )
                        : const Center(child: Text("No widget"));
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    style: GoogleFonts.cousine(fontSize: 12),
                    controller: componentWidget.controller,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Observer(
            builder: (context) {
              final themeCouple =
                  rootStore.themesStore.themes[store.selectedThemeIndex.value];
              return MaterialApp(
                theme: themeCouple.light.themeData.value,
                darkTheme: themeCouple.dark.themeData.value,
                debugShowCheckedModeBanner: false,
                debugShowMaterialGrid: false,
                themeMode:
                    store.useDarkTheme.value ? ThemeMode.dark : ThemeMode.light,
                builder: (context, _) => Material(
                  child: Observer(
                    builder: (context) {
                      final result = componentWidget.parsedWidget;
                      return result.isSuccess
                          ? Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("dwd"),
                                ),
                                Expanded(
                                  child: Center(child: result.value.widget),
                                )
                              ],
                            )
                          : Center(
                              child: Text(
                                "Invalid text:\n$result",
                                textAlign: TextAlign.center,
                              ),
                            );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        // SizedBox(
        //   width: 300,
        //   child: Rebuilder(
        //     builder: (context) {
        //       return CodeGenerated(sourceCode: "");
        //     },
        //   ),
        // ),
      ],
    );
  }
}
