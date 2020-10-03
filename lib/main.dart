import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/collection_notifier/collection_notifier.dart';
import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/templates.dart';
import 'package:snippet_generator/utils/type_parser.dart';
import 'package:snippet_generator/views/type_config.dart';

void main() {
  JsonTypeParser.init();
  runApp(MyApp());
}

class GlobalKeyboardListener {
  static final focusNode = FocusNode();
  static final Set<void Function(RawKeyEvent event)> _listeners = {};

  static void addListener(void Function(RawKeyEvent event) callback) {
    _listeners.add(callback);
  }

  static void removeListener(void Function(RawKeyEvent event) callback) {
    _listeners.remove(callback);
  }

  static void onKey(RawKeyEvent event) {
    for (final callback in _listeners) {
      callback(event);
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: GlobalKeyboardListener.focusNode,
      onKey: GlobalKeyboardListener.onKey,
      child: MaterialApp(
        title: 'Snippet Generator',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: const Color(0xfff5f8fa),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = useMemoized(() => RootStore());

    return RootStoreProvider(
      rootStore: rootStore,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Snippet Generator'),
        ),
        body: Row(
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
                child: CodeGenerated(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  MediaQueryData get mq => MediaQuery.of(this);

  Size get size => mq.size;
}

class TypesMenu extends HookWidget {
  const TypesMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = RootStore.of(context);
    useListenable(rootStore.types);
    useListenable(rootStore.selectedTypeNotifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 6.0),
          child: Text(
            "Types",
            style: context.textTheme.headline5,
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ...rootStore.types.map(
                (type) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: type == rootStore.selectedType
                        ? context.theme.primaryColor
                        : Colors.white,
                  ),
                  child: TextButton(
                    onPressed: () {
                      rootStore.selectType(type);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: type.nameNotifier.rebuild((_) {
                              return Text(
                                type.name,
                                style: context.textTheme.button.copyWith(
                                  color: type == rootStore.selectedType
                                      ? Colors.white
                                      : null,
                                ),
                              );
                            }),
                          ),
                          IconButton(
                            onPressed: () {
                              rootStore.removeType(type);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FlatButton.icon(
                onPressed: rootStore.addType,
                icon: const Icon(Icons.add),
                label: const Text("Add Type"),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class CodeGenerated extends HookWidget {
  const CodeGenerated({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TypeConfig typeConfig = useSelectedType(context);
    useListenable(typeConfig.deepListenable);
    final scrollController = useScrollController();

    String sourceCode;
    if (typeConfig.isEnum) {
      sourceCode = typeConfig.templateEnum();
    } else if (typeConfig.isSumType) {
      sourceCode = typeConfig.templateSumType();
    } else {
      final _class = typeConfig.classes[0];
      sourceCode = _class.templateClass();
    }
    return Column(
      children: [
        RaisedButton.icon(
          onPressed: () => Clipboard.setData(ClipboardData(text: sourceCode)),
          icon: const Icon(Icons.copy),
          label: const Text("Copy Source Code"),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 12.0),
              child: Scrollbar(
                isAlwaysShown: true,
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: SelectableText(
                      sourceCode,
                      style: GoogleFonts.cousine(),
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

class HistoryView extends HookWidget {
  const HistoryView({Key key, @required this.eventConsumer}) : super(key: key);
  final EventConsumer<Object> eventConsumer;

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
