import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/fields/color_field.dart';
import 'package:snippet_generator/fields/fields.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/widgets.dart';

final Map<Type, Widget Function(BuildContext, AppNotifier<Object>)>
    _nestedThemeBuilders = {
  ElevatedButtonThemeData: (
    BuildContext context,
    AppNotifier<ElevatedButtonThemeData> notifier,
  ) {
    final primaryColor = useState(Colors.white);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFieldRow(
          name: notifier.name,
          onChanged: (color) {
            notifier.value = ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                primary: primaryColor.value,
              ),
            );
          },
          value: primaryColor.value,
        ),
      ],
    );
  } as Widget Function(BuildContext, AppNotifier<Object>),
  ColorScheme: (
    BuildContext context,
    AppNotifier<ColorScheme> notifier,
  ) {
    final primaryColor = useState(Colors.white);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFieldRow(
          name: notifier.name,
          onChanged: (color) {
            notifier.value = ColorScheme.light(
              primary: primaryColor.value,
            );
          },
          value: primaryColor.value,
        ),
      ],
    );
  } as Widget Function(BuildContext, AppNotifier<Object>)
};

class ThemesTabView extends HookWidget {
  const ThemesTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);
    final themesStore = rootStore.themesStore;
    useListenable(themesStore.isUsingDarkTheme);

    final themeCouple = themesStore.themes.first;
    final store = themesStore.isUsingDarkTheme.value
        ? themeCouple.dark
        : themeCouple.light;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 12.0, right: 8.0, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RowTextField(
                      controller: themeCouple.name.controller,
                      label: "Name",
                    ),
                    RowBoolField(
                      notifier: themesStore.isUsingDarkTheme,
                      label: "Dark Theme",
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleScrollable(
                  builder: (context, scrollController) => ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 18,
                    ),
                    children: [
                      ...store.props.whereType<AppNotifier<Color>>().map(
                            (notifier) => Observer(
                              builder: (context) => ColorFieldRow(
                                name: notifier.name,
                                onChanged: notifier.set,
                                value: notifier.value,
                              ),
                            ),
                          ),
                      const _ListTitle(title: "Color Scheme"),
                      ...store.colorScheme.props
                          .whereType<AppNotifier<Color>>()
                          .map(
                            (notifier) => Observer(
                              builder: (context) => ColorFieldRow(
                                name: notifier.name,
                                onChanged: notifier.set,
                                value: notifier.value,
                              ),
                            ),
                          ),
                      const _ListTitle(title: "Button Themes"),
                      ...[
                        store.inputDecorationTheme,
                        store.textButtonTheme,
                        store.elevatedButtonTheme,
                        store.outlinedButtonTheme,
                      ].expand((innerTheme) sync* {
                        yield _ListTitle(title: innerTheme.name);
                        yield PropsForm(props: innerTheme.props);
                      })
                      // RowTextField(
                      //   controller: store.primaryTextColor.controller,
                      //   label: "Primary",
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Observer(
            builder: (context) => Theme(
              data: store.themeData.value,
              child: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                    ),
                  ],
                ),
                body: Center(
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Card title"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text("Push me"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListTitle extends StatelessWidget {
  const _ListTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.theme.canvasColor),
        ),
      ),
      child: SelectableText(
        title,
        style: context.textTheme.headline6,
      ),
    );
  }
}
