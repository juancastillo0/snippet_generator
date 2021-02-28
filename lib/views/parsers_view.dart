import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/parsers/widget_parser.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/widgets.dart';

class ParsedState {
  final key = uuid.v4();
  final controller = TextEditingController();

  final nameNotifier = TextNotifier();
}

class ParsersView extends HookWidget {
  const ParsersView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final componentWidgetList = useMemoized(
      () => ListNotifier([ParsedState()]),
    );
    final selectedIndex = useState(0);
    useListenable(componentWidgetList);
    void addComponentWidget() {
      selectedIndex.value = componentWidgetList.length;
      final _parsedState = ParsedState();
      componentWidgetList.add(_parsedState);
      _parsedState.nameNotifier.focusNode.requestFocus();
    }

    void deleteIndex(int index) {
      componentWidgetList.removeAt(index);
      if (componentWidgetList.isEmpty) {
        addComponentWidget();
      } else if (selectedIndex.value == componentWidgetList.length) {
        selectedIndex.value--;
      }
    }

    return Column(
      children: [
        Container(
          height: 45,
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Scrollbar(
                  child: ListView(
                    itemExtent: 140.0,
                    scrollDirection: Axis.horizontal,
                    children: componentWidgetList.mapIndex(
                      (component, index) {
                        return ComponentWidgetTab(
                          onTap: () {
                            selectedIndex.value = index;
                          },
                          onDelete: () {
                            deleteIndex(index);
                          },
                          componentWidget: component,
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
              FlatButton(
                onPressed: addComponentWidget,
                child: const Text("ADD"),
              )
            ],
          ),
        ),
        Expanded(
          child: _ParsersViewBody(
            componentWidget: componentWidgetList[selectedIndex.value],
          ),
        ),
      ],
    );
  }
}

class ComponentWidgetTab extends HookWidget {
  const ComponentWidgetTab({
    Key key,
    @required this.onTap,
    @required this.onDelete,
    @required this.componentWidget,
  }) : super(key: key);

  final void Function() onTap;
  final void Function() onDelete;
  final ParsedState componentWidget;

  @override
  Widget build(BuildContext context) {
    final show = useState(false);

    return MenuPortalEntry(
      options: [
        FlatButton(
          onPressed: onDelete,
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
    Key key,
    this.componentWidget,
  }) : super(key: key);
  final ParsedState/*!*/ componentWidget;

  @override
  Widget build(BuildContext context) {
    final controller = componentWidget.controller;
    useListenable(controller);
    final selected = useState<WidgetParser>(null);

    final result = useMemoized(
      () {
        final result = WidgetParser.parser.parse(controller.text);
        if (result.isSuccess) {
          final position = controller.selection.start;

          WidgetParser getTokenAtPos(WidgetParser value) {
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
            selected.value = value;
          } else if (position == -1) {
            selected.value = result.value;
          }
        }
        return result;
      },
      [componentWidget, controller.value],
    );

    final _form = selected?.value == null ? null : selected.value.form(
      selected?.value?.tokenParsedParams,
      controller,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _form != null && result.isSuccess
                    ? _form
                    : const Center(child: Text("No widget")),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    controller: controller,
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
          child: result.isSuccess
              ? result.value.widget
              : Center(
                  child: Text(
                    "Invalid text:\n$result",
                    textAlign: TextAlign.center,
                  ),
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
