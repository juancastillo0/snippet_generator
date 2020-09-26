import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/models/type_models.dart';
import 'package:snippet_generator/templates.dart';
import 'package:snippet_generator/utils/type_parser.dart';
import 'package:snippet_generator/views/type_config.dart';

void main() {
  JsonTypeParser.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snippet Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xfff5f8fa),
      ),
      home: const MyHomePage(title: 'Flutter Snippet Generator'),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final rootStore = useMemoized(() => RootStore());

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 150,
            child: TypesMenu(rootStore: rootStore),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 600,
                child: rootStore.selectedTypeNotifier.rebuild(
                  (typeConfig) => TypeConfigView(typeConfig: typeConfig),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: rootStore.selectedTypeNotifier.rebuild(
                (typeConfig) => CodeGenerated(typeConfig: typeConfig),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypesMenu extends HookWidget {
  const TypesMenu({
    Key key,
    @required this.rootStore,
  }) : super(key: key);

  final RootStore rootStore;

  @override
  Widget build(BuildContext context) {
    useListenable(rootStore.types);
    useListenable(rootStore.selectedTypeNotifier);

    return ListView(
      children: [
        ...rootStore.types.value.map(
          (type) => DecoratedBox(
            decoration: BoxDecoration(
              color: type == rootStore.selectedType
                  ? Colors.black.withOpacity(0.06)
                  : Colors.white,
            ),
            child: FlatButton(
              onPressed: () {
                rootStore.selectType(type);
              },
              child: AnimatedBuilder(
                animation: type.nameNotifier,
                builder: (context, _) {
                  return Text(type.name);
                },
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
    );
  }
}

class CodeGenerated extends HookWidget {
  const CodeGenerated({
    Key key,
    @required this.typeConfig,
  }) : super(key: key);
  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    useListenable(typeConfig.deepListenable);
    final scrollController = useScrollController();

    String sourceCode;
    if (typeConfig.isEnum) {
      sourceCode = typeConfig.templateEnum();
    } else if (typeConfig.isSumType) {
      sourceCode = typeConfig.templateSumType();
    } else {
      final _class = typeConfig.classes.value[0];
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
