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
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 8.0,
                  bottom: 5,
                  top: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RowTextField(
                      controller: themeCouple.name.controller,
                      label: "Name",
                    ),
                    RowBoolField(
                      notifier: themesStore.debugShowMaterialGrid,
                      label: "Show Grid",
                    ),
                    RowBoolField(
                      notifier: themesStore.showSemanticsDebugger,
                      label: "Show Semantics",
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  ...store.props
                                      .whereType<AppNotifier<Color>>()
                                      .map(
                                        (notifier) => Observer(
                                          builder: (context) => ColorFieldRow(
                                            name: notifier.name,
                                            onChanged: notifier.set,
                                            value: notifier.value,
                                          ),
                                        ),
                                      )
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
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
                                ],
                              ),
                            )
                          ]),
                      GlobalFields.get(store.textTheme)!,
                      const _ListTitle(title: "Color Scheme"),
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
            builder: (context) => MaterialApp(
              theme: store.themeData.value,
              debugShowMaterialGrid: themesStore.debugShowMaterialGrid.value,
              showSemanticsDebugger: themesStore.showSemanticsDebugger.value,
              debugShowCheckedModeBanner: false,
              builder: (context, _) => const ThemePreviewScaffold(),
            ),
          ),
        ),
      ],
    );
  }
}

class ThemePreviewScaffold extends StatelessWidget {
  const ThemePreviewScaffold({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "List",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              late final ScaffoldFeatureController _c;
              _c = ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "You pushed the FloatingActionButton!",
                  ),
                  action: SnackBarAction(
                    label: "Great",
                    onPressed: () {
                      _c.close();
                    },
                  ),
                ),
              );
            },
            child: const Icon(Icons.message),
          );
        },
      ),
      body: const ThemePreviewScaffoldBody(),
    );
  }
}

class ThemePreviewScaffoldBody extends StatelessWidget {
  const ThemePreviewScaffoldBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
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
            Card(
              margin: const EdgeInsets.all(32.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Form title",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Optio occaecati dolor ut illo provident inventore. Itaque accusamus dolore."
                      " Ut praesentium officiis sint laborum tenetur vero. Omnis at sint dignissimos eum quia corrupti sed."
                      " Unde distinctio amet non. Minima similique qui voluptates et.",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Name",
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.close),
                        ),
                        const SizedBox(width: 100),
                        TextButton(
                          onPressed: () {},
                          // child: const Text("Show Dialog"),
                          child: const Text("Show Dialog"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 100,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Content",
                        ),
                        maxLines: null,
                        minLines: null,
                        expands: true,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("Send"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
