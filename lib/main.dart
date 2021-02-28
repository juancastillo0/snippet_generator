import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:snippet_generator/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/rebuilder.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/parsers/widget_parser.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';
import 'package:snippet_generator/templates/templates.dart';
import 'package:snippet_generator/utils/download_json.dart';
import 'package:snippet_generator/utils/persistence.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/views/globals.dart';
import 'package:snippet_generator/views/parsers_view.dart';
import 'package:snippet_generator/views/type_config.dart';
import 'package:snippet_generator/views/types_menu.dart';
import 'package:snippet_generator/widgets.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<void> main() async {
  JsonTypeParser.init();
  WidgetParser.init();
  await initHive();

  final rootStore = RootStore();
  Globals.add(rootStore);
  rootStore.loadHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: GlobalKeyboardListener.wrapper(
        child: MaterialApp(
          title: 'Snippet Generator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: const Color(0xfff5f8fa),
          ),
          navigatorObservers: [routeObserver],
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = Globals.get<RootStore>();
    return RootStoreProvider(
      rootStore: rootStore,
      child: Scaffold(
        appBar: const _HomePageAppBar(),
        body: RootStoreMessager(
          rootStore: rootStore,
          child: Rebuilder(
            builder: (context) {
              int index = 0;
              switch (rootStore.selectedTab) {
                case AppTabs.types:
                  index = 0;
                  break;
                case AppTabs.ui:
                  index = 1;
                  break;
              }
              return IndexedStack(
                index: index,
                children: const [
                  TypesTabView(),
                  ParsersView(),
                ],
              );
            },
          ),
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
    useEffect(() {
      final subs = rootStore.messageEvents.listen((messageEvent) {
        messageEvent.when(
          typeCopied: () => messager.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              width: 350,
              content: const Text("Type copied"),
            ),
          ),
          typesSaved: () {},
        );
      });
      return subs.cancel;
    }, [rootStore]);

    return child;
  }
}

ButtonStyle _actionButton(BuildContext context) => TextButton.styleFrom(
      primary: Colors.white,
      onSurface: Colors.white,
      disabledMouseCursor: MouseCursor.defer,
      enabledMouseCursor: SystemMouseCursors.click,
      padding: const EdgeInsets.symmetric(horizontal: 17),
    );

class _HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomePageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = RootStore.of(context);
    // print(Platform.resolvedExecutable);

    return AppBar(
      title: Rebuilder(builder: (context) {
        return SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: Text('Flutter Snippet Generator')),
              const SizedBox(width: 30),
              TextButton(
                style: _actionButton(context),
                onPressed: AppTabs.types == rootStore.selectedTab
                    ? null
                    : () {
                        rootStore.setSelectedTab(AppTabs.types);
                      },
                child: const Text("Types"),
              ),
              TextButton(
                style: _actionButton(context),
                onPressed: AppTabs.ui == rootStore.selectedTab
                    ? null
                    : () {
                        rootStore.setSelectedTab(AppTabs.ui);
                      },
                child: const Text("Widgets"),
              ),
            ],
          ),
        );
      }),
      actions: [
        TextButton.icon(
          style: _actionButton(context),
          onPressed: () async {
            await rootStore.saveHive();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                width: 350,
                content: const Text("The types where saved correctly"),
              ),
            );
          },
          icon: const Icon(Icons.save),
          label: const Text("Save"),
        ),
        TextButton.icon(
          style: _actionButton(context),
          onPressed: () async {
            final jsonString = await importFromClient();
            if (jsonString != null) {
              bool success = false;
              try {
                final json = jsonDecode(jsonString);
                success = rootStore.importJson(json as Map<String, dynamic>);
              } catch (e, s) {
                print("jsonDecode error $e\n$s");
              }
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text("Invalid json file"),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.file_upload),
          label: const Text("Import"),
        ),
        TextButton.icon(
          style: _actionButton(context),
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

class CodeGenerated extends HookWidget {
  final String sourceCode;

  const CodeGenerated({
    Key? key,
    required this.sourceCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: sourceCode)),
              style: elevatedStyle(context),
              icon: const Icon(Icons.copy),
              label: const Text("Copy Source Code"),
            ),
            RowBoolField(
              label: "Null Safe",
              notifier: rootStore.isCodeGenNullSafeNotifier,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
                bottom: 12.0,
                left: 12.0,
              ),
              child: SingleScrollable(
                child: SelectableText(
                  sourceCode,
                  style: GoogleFonts.cousine(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TypeCodeGenerated extends HookWidget {
  const TypeCodeGenerated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);
    final TypeConfig typeConfig = useSelectedType(context);
    useListenable(typeConfig.deepListenable);
    useListenable(rootStore.isCodeGenNullSafeNotifier);

    return Observer(builder: (context) {
      String sourceCode;
      if (typeConfig.isEnum) {
        sourceCode = typeConfig.templateEnum();
      } else if (typeConfig.isSumType) {
        sourceCode = typeConfig.templateSumType();
      } else {
        final _class = typeConfig.classes[0];
        sourceCode = _class.templateClass();
      }
      try {
        sourceCode = rootStore.formatter.format(sourceCode);
      } catch (_) {}
      return CodeGenerated(sourceCode: sourceCode);
    });
  }
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
