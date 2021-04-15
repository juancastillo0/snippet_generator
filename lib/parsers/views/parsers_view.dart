import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/parsers/views/components_widget_store.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/widgets/context_menu_portal.dart';
import 'package:snippet_generator/widgets/row_fields.dart';

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
                    style: GoogleFonts.cousine(fontSize: 13),
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
                title: "Snippet Generator",
                theme: themeCouple.light.themeData.value,
                darkTheme: themeCouple.dark.themeData.value,
                debugShowCheckedModeBanner: false,
                debugShowMaterialGrid: false,
                themeMode:
                    store.useDarkTheme.value ? ThemeMode.dark : ThemeMode.light,
                builder: (context, _) => Material(
                  child: ParsedWidgetView(componentWidget: componentWidget),
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

class ParsedWidgetView extends StatelessWidget {
  const ParsedWidgetView({
    Key? key,
    required this.componentWidget,
  }) : super(key: key);

  final ParsedState componentWidget;

  @override
  Widget build(BuildContext context) {
    print("ddw1");
    return Observer(
      builder: (context) {
        final result = componentWidget.parsedWidget;
        print("ddw2");
        return result.isSuccess
            ? Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("dwd"),
                  ),
                  Expanded(
                    child: Center(
                      child: Builder(
                        builder: (context) => result.value.widget,
                      ),
                    ),
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
    );
  }
}
