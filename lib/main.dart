import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/class_properties.dart';
import 'package:snippet_generator/formatters.dart';
import 'package:snippet_generator/models.dart';
import 'package:snippet_generator/templates.dart';
import 'package:snippet_generator/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class TypeConfigView extends HookWidget {
  const TypeConfigView({
    Key key,
    this.typeConfig,
  }) : super(key: key);
  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RowTextField(
              label: "Type Name",
              controller: typeConfig.nameNotifier,
              inputFormatters: Formatters.variableName,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: {
                "Data Value": typeConfig.isDataValueNotifier,
                "Listenable": typeConfig.isListenableNotifier,
                "Serializable": typeConfig.isSerializableNotifier,
                "Sum Type": typeConfig.isSumTypeNotifier,
                "Enum": typeConfig.isEnumNotifier,
              }
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                      child: RowBoolField(
                        label: e.key,
                        notifier: e.value,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final typeConfig = useMemoized(() => TypeConfig());

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 150,
            child: ListView(
              children: [
                FlatButton(
                  onPressed: () {},
                  child: const Text("Class"),
                )
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 600,
                child: Column(
                  children: <Widget>[
                    TypeConfigView(typeConfig: typeConfig),
                    const SizedBox(height: 15),
                    typeConfig.classes.rebuild(
                      (classes) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: classes
                            .map(
                              (e) => typeConfig.isEnumNotifier.rebuild(
                                (isEnum) => isEnum
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          RowTextField(
                                            controller: e.nameNotifier,
                                            label: "Variant",
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              typeConfig.classes.remove(e);
                                            },
                                            icon: const Icon(Icons.delete),
                                          ),
                                        ],
                                      )
                                    : ClassPropertiesTable(data: e),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    typeConfig.hasVariants.rebuild(
                      (hasVariants) => hasVariants
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: RaisedButton.icon(
                                onPressed: () => typeConfig.classes
                                    .add(ClassConfig(typeConfig)),
                                icon: const Icon(Icons.add),
                                label: typeConfig.isEnum
                                    ? const Text("Add Variant")
                                    : const Text("Add Class"),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CodeGenerated(
                typeConfig: typeConfig,
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => properties.add,
      //   tooltip: 'Add',
      //   child: const Icon(Icons.add),
      // ),
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
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Scrollbar(
              isAlwaysShown: true,
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SelectableText(sourceCode),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
