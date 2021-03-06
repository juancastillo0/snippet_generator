import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
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
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: context.theme.canvasColor),
                        ),
                      ),
                      child: SelectableText(
                        "Color Scheme",
                        style: context.textTheme.headline6,
                      ),
                    ),
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
                    // RowTextField(
                    //   controller: store.primaryTextColor.controller,
                    //   label: "Primary",
                    // ),
                  ],
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

class ColorFieldRow extends StatelessWidget {
  const ColorFieldRow({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  final String name;
  final Color value;
  final void Function(Color) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 200, child: SelectableText(name)),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Container(
                    height: 200,
                    width: 650,
                    padding: const EdgeInsets.all(12),
                    child: ColorPicker(
                      pickerColor: value,
                      onColorChanged: onChanged,
                      colorPickerWidth: 100.0,
                      showLabel: true,
                      enableAlpha: true,
                      pickerAreaHeightPercent: 0.7,
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            height: 30,
            width: 40,
            color: value,
          ),
        ),
      ],
    );
  }
}
