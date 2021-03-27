import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:snippet_generator/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/rebuilder.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/parsers/widget_parser.dart';
import 'package:snippet_generator/utils/download_json.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/persistence.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:snippet_generator/utils/set_up_globals.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/views/code_generated.dart';
import 'package:snippet_generator/views/globals.dart';
import 'package:snippet_generator/views/parsers_view.dart';
import 'package:snippet_generator/themes/themes_tab_view.dart';
import 'package:snippet_generator/views/type_config.dart';
import 'package:snippet_generator/views/types_menu.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<void> main() async {
  LicenseRegistry.addLicense(() async* {
    final licenseCousine =
        await rootBundle.loadString('google_fonts/LICENSE.txt');
    final licenseNunitoSans =
        await rootBundle.loadString('google_fonts/OFL.txt');

    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseCousine);
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseNunitoSans);
  });

  setUpGlobals();
  JsonTypeParser.init();
  WidgetParser.init();
  await initHive();

  final rootStore = RootStore();
  Globals.add(rootStore);
  rootStore.loadHive();
  runApp(const MyApp());
}

class MyApp extends HookWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    final rootStore = Globals.get<RootStore>();
    useListenable(rootStore.themeModeNotifier);

    return RootStoreProvider(
      rootStore: rootStore,
      child: Portal(
        child: GlobalKeyboardListener.wrapper(
          child: MaterialApp(
            title: 'Snippet Generator',
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: rootStore.themeModeNotifier.value,
            navigatorObservers: [routeObserver],
            home: const MyHomePage(),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = Globals.get<RootStore>();
    return Scaffold(
      appBar: const _HomePageAppBar(),
      body: RootStoreMessager(
        rootStore: rootStore,
        child: Rebuilder(
          builder: (context) {
            return IndexedStack(
              index: rootStore.selectedTab.index,
              children: const [
                TypesTabView(),
                ParsersView(),
                ThemesTabView(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TypesTabView extends HookWidget {
  const TypesTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Column(
            children: [
              const Expanded(
                flex: 2,
                child: TypesMenu(),
              ),
              Expanded(
                child: HistoryView(eventConsumer: rootStore.types),
              )
            ],
          ),
        ),
        const Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 600,
              child: TypeConfigView(),
            ),
          ),
        ),
        const SizedBox(
          width: 450,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TypeCodeGenerated(),
          ),
        ),
      ],
    );
  }
}

enum SnackbarType {
  error,
  info,
}

class RootStoreMessager extends HookWidget {
  const RootStoreMessager({
    Key? key,
    required this.child,
    required this.rootStore,
  }) : super(key: key);
  final Widget child;
  final RootStore rootStore;

  @override
  Widget build(BuildContext context) {
    final messager = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    useEffect(() {
      void _showSnackbar(
        String content, {
        SnackbarType type = SnackbarType.info,
      }) {
        messager.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
            backgroundColor:
                type == SnackbarType.error ? theme.colorScheme.error : null,
            content: Text(
              content,
              style: theme.textTheme.bodyText1!.copyWith(
                color: type == SnackbarType.error
                    ? theme.colorScheme.onError
                    : theme.colorScheme.onBackground,
              ),
            ),
          ),
        );
      }

      final subs = rootStore.messageEvents.listen((messageEvent) {
        switch (messageEvent) {
          case MessageEvent.sourceCodeCopied:
            return _showSnackbar("Source code copied");
          case MessageEvent.typeCopied:
            return _showSnackbar("Type copied");
          case MessageEvent.typesSaved:
            return _showSnackbar("Types saved");
          case MessageEvent.errorImportingTypes:
            return _showSnackbar("Invalid json file", type: SnackbarType.error);
        }
      });
      return subs.cancel;
    }, [rootStore]);

    return child;
  }
}

ButtonStyle _actionButton(BuildContext context) {
  final theme = Theme.of(context);
  return TextButton.styleFrom(
    primary: Colors.white,
    onSurface: Colors.white,
    disabledMouseCursor: MouseCursor.defer,
    enabledMouseCursor: SystemMouseCursors.click,
  ).copyWith(
    textStyle: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return theme.textTheme.button!.copyWith(fontWeight: FontWeight.bold);
      }
      return theme.textTheme.button;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );
}

ButtonStyle _actionButtonPadded(BuildContext context) =>
    _actionButton(context).copyWith(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 17),
      ),
    );

const appTabsTitles = {
  AppTabs.ui: "Widgets",
  AppTabs.types: "Types",
  AppTabs.theme: "Themes",
};

class TabButton extends HookWidget {
  const TabButton({
    required this.tab,
    Key? key,
  }) : super(key: key);

  final AppTabs tab;

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);

    return Observer(builder: (context) {
      final isSelected = tab == rootStore.selectedTab;
      return TextButton(
        style: _actionButton(context),
        onPressed: isSelected
            ? null
            : () {
                rootStore.setSelectedTab(tab);
              },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onBackground
                      : Colors.transparent,
                  width: 3,
                ),
                top: const BorderSide(
                  color: Colors.transparent,
                  width: 3,
                )),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(child: Text(appTabsTitles[tab]!)),
        ),
      );
    });
  }
}

class _HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomePageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = RootStore.of(context);
    // print(Platform.resolvedExecutable);

    return AppBar(
      title: Rebuilder(builder: (context) {
        return SizedBox(
          height: 46,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Center(child: Text('Flutter Snippet Generator')),
              SizedBox(width: 30),
              TabButton(tab: AppTabs.types),
              TabButton(tab: AppTabs.ui),
              TabButton(tab: AppTabs.theme),
            ],
          ),
        );
      }),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Dark Mode"),
            rootStore.themeModeNotifier.rebuild(
              (mode) => Switch(
                value: rootStore.themeModeNotifier.value == ThemeMode.dark,
                onChanged: (value) {
                  rootStore.themeModeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        TextButton.icon(
          style: _actionButtonPadded(context),
          onPressed: rootStore.saveHive,
          icon: const Icon(Icons.save),
          label: const Text("Save"),
        ),
        TextButton.icon(
          style: _actionButtonPadded(context),
          onPressed: () async {
            final jsonString = await importFromClient();
            if (jsonString != null) {
              rootStore.importJson(jsonString);
            }
          },
          icon: const Icon(Icons.file_upload),
          label: const Text("Import"),
        ),
        TextButton.icon(
          style: _actionButtonPadded(context),
          onPressed: () {
            rootStore.downloadJson();
          },
          icon: const Icon(Icons.file_download),
          label: const Text("Export"),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(46);
}

class HistoryView extends HookWidget {
  const HistoryView({Key? key, required this.eventConsumer}) : super(key: key);
  final EventConsumer<Object?> eventConsumer;

  @override
  Widget build(BuildContext context) {
    useListenable(eventConsumer);
    final history = eventConsumer.history;
    return Column(
      children: [
        Text("Position: ${history.position}"),
        Text("canUndo: ${history.canUndo}"),
        Text("canRedo: ${history.canRedo}"),
        Expanded(
          child: ListView(
            children: history.events
                .map(
                  (event) => Text(event.runtimeType.toString()),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
