import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/models.dart';
import 'package:snippet_generator/templates.dart';
import 'package:super_tooltip/super_tooltip.dart';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RowTextField(
            label: "Type Name",
            controller: typeConfig.nameNotifier,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: {
              "Data Value": typeConfig.isDataValueNotifier,
              "Listenable": typeConfig.isListenableNotifier,
              "Serializable": typeConfig.isSerializableNotifier,
              "Sum Type": typeConfig.isSumTypeNotifier,
            }
                .entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(right: 15.0),
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
                            .map((e) => ClassPropertiesTable(data: e))
                            .toList(),
                      ),
                    ),
                    typeConfig.isSumTypeNotifier.rebuild(
                      (isSumType) => isSumType
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: RaisedButton.icon(
                                onPressed: () => typeConfig.classes
                                    .add(ClassConfig(typeConfig)),
                                icon: const Icon(Icons.add),
                                label: const Text("Add Class"),
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

class RowBoolField extends StatelessWidget {
  const RowBoolField({
    Key key,
    @required this.notifier,
    @required this.label,
  }) : super(key: key);

  final AppNotifier<bool> notifier;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        notifier.rebuild(
          (value) => Checkbox(
            value: value,
            onChanged: notifier.set,
          ),
        ),
      ],
    );
  }
}

class RowTextField extends StatelessWidget {
  const RowTextField({
    Key key,
    @required this.controller,
    @required this.label,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 130,
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }
}

class ClassPropertiesTable extends StatelessWidget {
  const ClassPropertiesTable({Key key, @required this.data}) : super(key: key);
  final ClassConfig data;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 10.0, bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
        child: Column(
          children: [
            data.typeConfig.isSumTypeNotifier.rebuild(
              (isSumType) => isSumType
                  ? Row(
                      children: [
                        RowTextField(
                          controller: data.nameNotifier,
                          label: "Class Name",
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: RowBoolField(
                            label: "Private",
                            notifier: data.isPrivateNotifier,
                          ),
                        ),
                        const Spacer(),
                        RaisedButton.icon(
                          onPressed: () => data.typeConfig.classes.remove(data),
                          icon: const Icon(Icons.delete),
                          label: const Text("Remove Class"),
                        )
                      ],
                    )
                  : const SizedBox(),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: data.properties.rebuild(
                    (properties) => DataTable(
                      columnSpacing: 32,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text('Field Name'),
                        ),
                        DataColumn(
                          label: Text('Type'),
                        ),
                        DataColumn(
                          label: Text('Required'),
                        ),
                        DataColumn(
                          label: Text('Positional'),
                        ),
                        DataColumn(
                          label: Text('More'),
                        ),
                      ],
                      rows: properties.map(_makeRow).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            RaisedButton.icon(
              onPressed: () => data.properties.add(PropertyField()),
              icon: const Icon(Icons.add),
              label: const Text("Add Field"),
            )
          ],
        ),
      ),
    );
  }

  DataRow _makeRow(PropertyField property) {
    const _contraints = BoxConstraints(minWidth: 100, maxWidth: 200);
    return DataRow(
      cells: <DataCell>[
        DataCell(ConstrainedBox(
          constraints: _contraints,
          child: TextField(
            controller: property.name,
          ),
        )),
        DataCell(ConstrainedBox(
          constraints: _contraints,
          child: TextField(
            controller: property.type,
          ),
        )),
        DataCell(
          Center(
            child: property.isRequired.rebuild(
              (isRequired) => Checkbox(
                value: isRequired,
                onChanged: property.isRequired.set,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: property.isPositional.rebuild(
              (isPositional) => Checkbox(
                value: isPositional,
                onChanged: property.isPositional.set,
              ),
            ),
          ),
        ),
        DataCell(
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  SuperTooltip tooltip;
                  tooltip = SuperTooltip(
                    popupDirection: TooltipDirection.up,
                    arrowLength: 10,
                    borderColor: Colors.black12,
                    borderWidth: 1,
                    hasShadow: false,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RaisedButton.icon(
                          onPressed: () {
                            tooltip.close();
                            data.properties.remove(property);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Remove Field"),
                        ),
                      ],
                    ),
                  );

                  tooltip.show(context);
                },
              );
            },
          ),
        ),
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
    if (typeConfig.isSumType) {
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
