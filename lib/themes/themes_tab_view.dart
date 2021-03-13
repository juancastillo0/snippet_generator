import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_portal/flutter_portal.dart';
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
                        vertical: 10, horizontal: 20),
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
                        store.textButtonTheme,
                        store.elevatedButtonTheme,
                        store.outlinedButtonTheme
                      ].expand((buttonTheme) sync* {
                        yield _ListTitle(title: buttonTheme.name);
                        yield buttonTheme.form();
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

class ColorFieldRow extends HookWidget {
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
    final showColorPicker = useState(false);
    final isInside = useState(false);
    const closeDuration = Duration(milliseconds: 130);
    final animationController = useAnimationController(
      duration: closeDuration,
    );
    final curvedAnimation = useMemoized(
      () => animationController.drive(CurveTween(curve: Curves.easeOut)),
      [animationController],
    );
    useValueChanged<bool, void>(showColorPicker.value, (_previous, _result) {
      if (showColorPicker.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
    useEffect(() {
      Timer? timer;
      if (isInside.value && !showColorPicker.value) {
        timer = Timer(const Duration(milliseconds: 400), () {
          showColorPicker.value = true;
        });
      } else if (!isInside.value && showColorPicker.value) {
        timer = Timer(const Duration(milliseconds: 300), () {
          showColorPicker.value = false;
        });
      }
      return timer?.cancel;
    }, [isInside.value, showColorPicker.value]);

    Widget mouseRegion(Widget child) {
      return MouseRegion(
        onEnter: (_) {
          isInside.value = true;
        },
        onExit: (_) {
          isInside.value = false;
        },
        child: child,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 200, child: SelectableText(name)),
        PortalEntry(
          childAnchor: Alignment.centerRight,
          portalAnchor: Alignment.centerLeft,
          closeDuration: closeDuration,
          visible: showColorPicker.value,
          portal: mouseRegion(
            AnimatedBuilder(
              animation: curvedAnimation,
              builder: (context, snapshot) {
                return Opacity(
                  opacity: curvedAnimation.value,
                  child: _picker(),
                );
              },
            ),
          ),
          child: mouseRegion(TextButton(
            onPressed: () => _showColorPicker(context),
            child: Container(
              height: 30,
              width: 40,
              color: value,
            ),
          )),
        ),
      ],
    );
  }

  Widget _picker() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(left: 8),
      child: Container(
        width: 274,
        height: 360,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Builder(
          builder: (context) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(size: Size(250, mq.size.height)),
              child: ColorPicker(
                pickerColor: value,
                onColorChanged: onChanged,
                colorPickerWidth: 250.0,
                displayThumbColor: true,
                paletteType: PaletteType.hsv,
                pickerAreaBorderRadius:
                    const BorderRadius.all(Radius.circular(3)),
                showLabel: true,
                enableAlpha: true,
                pickerAreaHeightPercent: 0.7,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 400,
            width: 300,
            padding: const EdgeInsets.all(12),
            child: _picker(),
          ),
        );
      },
    );
  }
}
